#!/usr/bin/env ruby
require 'active_support/core_ext/hash'
require 'minil'
require 'minil/image'
require 'minil/color'
require 'oj'
require 'pathname'
require 'fileutils'

class Minil::Image
  def blend_multiply_fill_rect(x, y, w, h, color)
    cr, cg, cb, ca = Minil::Color.cast_to_channels(color)
    h.times do |row|
      w.times do |col|
        dx, dy = x + col, y + row
        pixel = get_pixel(dx, dy)
        r, g, b, a = Minil::Color.decode(pixel)
        next if a == 0
        c = Minil::Color.encode(
          r * cr / 255,
          g * cg / 255,
          b * cb / 255,
          a * ca / 255
        )
        set_pixel(dx, dy, c)
      end
    end
  end
end

module Compose
end

class Compose::Transform
  class Tuple < Struct.new(:x, :y)
  end

  attr_reader :translate
  attr_reader :scale
  attr_reader :rotation

  def initialize(data = nil)
    @translate = [0, 0]
    @scale = [1.0, 1.0]
    @rotation = 0.0
    if data
      @translate = Tuple.new(*data.fetch('translate', @translate))
      @scale = Tuple.new(*data.fetch('scale', @scale))
      @rotation = data.fetch('rotation', @rotation)
    end
  end

  def +(other)
    Compose::Transform.new(
      'translate' => [translate[0] + other.translate[0], translate[1] + other.translate[1]],
      'scale' => [scale[0] * other.scale[0], scale[1] * other.scale[1]],
      'rotation' => rotation + other.rotation
    )
  end
end

class Compose::FrameCompositor
  attr_reader :project
  attr_reader :result

  def initialize(project, data)
    @project = project
    @data = data
    @frame_layers = @data.fetch('layers')
  end

  protected def render_layer(layer)
    texture = layer.fetch('texture')
    src_frame = if layer.has_key?('blend')
      # frame layers are composed on before being drawn to the buffer
      blit_frame = Minil::Image.create(@buffer_frame.width, @buffer_frame.height)
      blend = layer.fetch('blend')
      type = blend.fetch('type')
      case type
      when 'multiply_color'
        blit_frame.blit_r(texture, 0, 0, texture.rect)
        blit_frame.blend_multiply_fill_rect(0, 0, blit_frame.width, blit_frame.height, blend.fetch('value'))
      else
        raise ArgumentError, "unsupported blend mode #{type}"
      end
      blit_frame
    else
      texture
    end
    src_frame
  end

  protected def calculate_frame_src_rect(layer, frame_layer)
    layer_src_rect = if layer.has_key?('src_rect')
      Minil::Rect.new(*layer['src_rect'])
    else
      texture.rect
    end
    frame_src_rect = if frame_layer.has_key?('src_rect')
      frame_layer.fetch('src_rect')
    else
      texture.rect
    end
    layer_src_rect.sub_rect(frame_src_rect)
  end

  protected def calculate_frame_transform(layer, frame_layer)
    layer_transform = Compose::Transform.new(layer['transform'])
    frame_transform = Compose::Transform.new(layer_item['transform'])
    layer_transform + frame_transform
  end

  protected def calculate_frame_opacity(layer, frame_layer)
    layer_opacity = layer['opacity']
    frame_opacity = layer_item['opacity']
    layer_opacity * frame_opacity / 255
  end

  def perform
    # buffer frame
    @buffer_frame = Minil::Image.create(@project.w, @project.h)
    @frame_layers.each do |frame_layer|
      if frame_layer.is_a?(String)
        frame_layer = { 'source' => frame_layer }
      end
      layer = @project.layers.fetch(frame_layer.fetch('source'))
      texture = layer.fetch('texture')
      src_frame = render_layer(layer)
      src_rect = calculate_frame_src_rect(layer, frame_layer)
      transform = calculate_frame_transform(layer, frame_layer)
      opacity = calculate_frame_opacity(layer, frame_layer)
      @buffer_frame.alpha_blit_r(src_frame,
        transform.translate.x,
        transform.translate.y,
        src_rect,
        opacity)
    end
    @result = buffer_frame
  end
end

class Compose::Project
  attr_reader :result
  attr_reader :source_layers
  attr_reader :source_frames
  attr_reader :layers
  attr_reader :frames
  attr_reader :w
  attr_reader :h

  def initialize(data)
    @data = data
    @source_layers = data.fetch('layers')
    @source_frames = data.fetch('frames')
  end

  protected def preload
    @layers = {}
    @source_layers.each_pair do |layer_name, layer|
      texture_filename = @texture_dir.join(layer.fetch('texture')).to_s
      @texture_cache[texture_filename] ||= Minil::Image.load_file texture_filename
      @layers[layer_name] = layer.merge({
        'texture' => @texture_cache[texture_filename]
      })
    end
  end

  protected def calculate_resolution
    @w, @h = 0, 0
    @layers.each do |_, layer|
      texture = layer.fetch('texture')
      @w = texture.width if texture.width > @w
      @h = texture.height if texture.height > @h
    end
  end

  def perform
    calculate_resolution
    @frames = @source_frames.map do |frame|
      compositor = Compose::FrameCompositor.new(self, frame)
      compositor.perform
      compositor.result
    end
    result_height = h * frames.size
    @result = Minil::Image.create(w, result_height)
    @frames.each_with_index do |frame, index|
      @result.blit_r(frame, 0, index * h, frame.rect)
    end
  end
end

class Compose::Application
  def initialize
    @texture_cache = {}
    @root_dir = Pathname.new(__dir__)
    @texture_dir = @root_dir.join('textures')
    @src_dir  = @root_dir.join('compose_src')
    @output_dir = @root_dir.join('composed')
  end

  def load_json(filename)
    Oj.load(File.read(filename))
  end

  private def replace_with_variables(vt, data)
    case data
    when Hash
      if data.has_key?('$variable')
        return vt.fetch(data['$variable'])
      end
      result = {}
      data.each_pair do |key, value|
        result[key] = replace_with_variables(vt, value)
      end
      return result
    when Array
      return data.map { |value| replace_with_variables(vt, value) }
    end
    data
  end

  def proprocess_includes(data)
    case data
    when Hash
      result = {}
      data.each_pair do |key, value|
        if key == '$includes'
          value.each do |file|
            partial = load_composer_file(@src_dir.join(file + '.json').to_s, options: { load_variables: false })
            result = result.deep_merge(partial)
          end
        else
          proprocessed_result = proprocess_includes(value)
          target = result[key]
          result[key] = case target
          when Array
            target.concat(proprocessed_result)
            target
          when Hash
            target.deep_merge(proprocessed_result)
          else
            proprocessed_result
          end
        end
      end
      result
    when Array
      data.map do |value|
        proprocess_includes(value)
      end
    else
      data
    end
  end

  def preprocess_data(data, **options)
    result = proprocess_includes(data)
    if options.fetch(:load_variables, true)
      if result.has_key?('variables')
        vt = result['variables']
        # evaluate variables
        vt = replace_with_variables(vt, vt)
        # and then evaluate the rest of the data
        return replace_with_variables(vt, result)
      end
    end
    result
  end

  def load_composer_file(filename, **options)
    preprocess_data(load_json(filename), options)
  end

  def compose_file(filename)
    data = load_composer_file(filename)
    return unless data.has_key?('output')
    puts filename
    output_basename = data.fetch('output')
    target_filename = @output_dir.join(output_basename)
    FileUtils.mkdir_p File.dirname(target_filename)
    project = Compose::Project.new(data)
    project.perform
    project.result.save_file target_filename.to_s + '.png'
    GC.start
  end

  def run
    Dir.chdir @src_dir.to_s do
      Dir.glob("**/*.json") do |filename|
        compose_file filename
      end
    end
  end
end

Compose::Application.new.run
