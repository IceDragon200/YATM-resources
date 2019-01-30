#!/usr/bin/env ruby
require 'bundler'
Bundler.require
require 'dragontk/thread_pool'
require 'dragontk/thread_safe'
require 'active_support/core_ext/hash'
require 'minil/image'
require 'minil/color'
require 'moon-logfmt/logger'
require 'oj'
require 'pathname'
require 'fileutils'
require 'optparse'

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

  private def blend_colorf(r, g, b, a, r2, g2, b2, a2, &blend)
    return (blend.call(r / 255.0, r2 / 255.0) * 255).to_i,
      (blend.call(g / 255.0, g2 / 255.0) * 255).to_i,
      (blend.call(b / 255.0, b2 / 255.0) * 255).to_i,
      a * a2 / 255
  end

  def blend_overlay_fill_rect(x, y, w, h, color)
    cr, cg, cb, ca = Minil::Color.cast_to_channels(color)
    h.times do |row|
      w.times do |col|
        dx, dy = x + col, y + row
        pixel = get_pixel(dx, dy)
        r, g, b, a = Minil::Color.decode(pixel)
        next if a == 0
        c = Minil::Color.encode(*blend_colorf(r, g, b, a, cr, cg, cb, ca) do |n, n2|
          if n < 0.5
            2 * (n * n2)
          else
            1 - 2 * (1 - n) * (1 - n2)
          end
        end)
        set_pixel(dx, dy, c)
      end
    end
  end
end

module Compose
end

class Compose::Transform
  class Vec2 < Struct.new(:x, :y)
  end

  attr_reader :translate
  attr_reader :scale
  attr_reader :rotation

  def initialize(data = nil)
    @translate = [0, 0]
    @scale = [1.0, 1.0]
    @rotation = 0.0
    if data
      @translate = Vec2.new(*data.fetch('translate', @translate))
      @scale = Vec2.new(*data.fetch('scale', @scale))
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

  def initialize(project, data, logger:)
    @logger = logger
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
      when 'overlay_color'
        blit_frame.blit_r(texture, 0, 0, texture.rect)
        blit_frame.blend_overlay_fill_rect(0, 0, blit_frame.width, blit_frame.height, blend.fetch('value'))
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
    texture = layer.fetch('texture')
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
    frame_transform = Compose::Transform.new(frame_layer['transform'])
    layer_transform + frame_transform
  end

  protected def calculate_frame_opacity(layer, frame_layer)
    layer_opacity = layer.fetch('opacity', 255)
    frame_opacity = frame_layer.fetch('opacity', 255)
    layer_opacity * frame_opacity / 255
  end

  def perform
    @logger.debug msg: "Creating Buffer Frame"
    # buffer frame
    @buffer_frame = Minil::Image.create(@project.w, @project.h)
    @frame_layers.each_with_index do |frame_layer, index|
      @logger.debug frame_layer: index, msg: "Rendering Frame Layer"
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
    @logger.info msg: "Frame Rendered"
    @result = @buffer_frame
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

  def initialize(env, data, logger:)
    @logger = logger
    @env = env
    @data = data
    @source_layers = data.fetch('layers')
    @source_frames = data.fetch('frames')
  end

  protected def preload_layers
    @layers = {}
    @source_layers.each_pair do |layer_name, layer|
      texture_filename = @env.texture_dir.join(layer.fetch('texture')).to_s
      @env.texture_cache[texture_filename] ||= Minil::Image.load_file texture_filename
      @layers[layer_name] = layer.merge({
        'texture' => @env.texture_cache[texture_filename]
      })
    end
    @logger.debug msg: "Preloaded Layers"
  end

  protected def calculate_resolution
    @w, @h = 0, 0
    @layers.each do |_, layer|
      texture = layer.fetch('texture')
      @w = texture.width if texture.width > @w
      @h = texture.height if texture.height > @h
    end
    @logger.debug w: @w, h: @h, msg: "Resolution Calculated"
  end

  def perform
    preload_layers
    calculate_resolution
    @logger.info msg: "Composing Frames"
    index = 0
    @frames = @source_frames.map do |frame|
      compositor = Compose::FrameCompositor.new(self, frame, logger: @logger.new(frame: index))
      index += 1
      compositor.perform
      compositor.result
    end
    result_height = h * frames.size
    @result = Minil::Image.create(w, result_height)
    @frames.each_with_index do |frame, index|
      @result.blit_r(frame, 0, index * h, frame.rect)
    end
    @logger.info msg: "Project Rendered"
  end
end

class Compose::Application
  attr_reader :texture_cache
  attr_reader :root_dir
  attr_reader :texture_dir
  attr_reader :src_dir
  attr_reader :output_dir
  attr_reader :logger

  def initialize
    @logger = Moon::Logfmt.new
    @logger.io = STDOUT.thread_safe
    @logger.level = :info
    @texture_cache = {}
    @root_dir = Pathname.new(__dir__)
    @texture_dir = @root_dir.join('textures')
    @src_dir  = @root_dir.join('compose_src')
    @output_dir = @root_dir.join('build')
    @project_counter = 0
  end

  def load_json(filename)
    begin
      Oj.load(File.read(filename))
    rescue Oj::ParseError => ex
      @logger.error filename: filename
      raise ex
    end
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
    case File.extname(filename).downcase
    when ".json"
      preprocess_data(load_json(filename), options)
    end
  end

  def compose_file(filename)
    log = @logger.new thread: Thread.current.__id__, filename: filename
    log.info filename: filename, msg: "Loading Compose file"
    data = load_composer_file(filename)
    unless data.has_key?('output')
      log.info filename: filename, msg: "Compose file has not output, skipping"
      return
    end
    log.info filename: filename, msg: "Loaded Compose file"
    output_basename = data.fetch('output')
    target_filename = @output_dir.join(output_basename)
    FileUtils.mkdir_p File.dirname(target_filename)
    project = Compose::Project.new(self, data, logger: log.new(project: @project_counter += 1))
    project.perform
    log.info target_filename: target_filename.to_s + '.png', msg: "Saving File"
    project.result.save_file target_filename.to_s + '.png'
    if data.key?('meta')
      File.write(target_filename.to_s + '.png.mcmeta', Oj.dump(data.fetch('meta')))
    end
    GC.start
  end

  def run(argv)
    thread_limit = 1
    optparse = OptionParser.new do |opts|
      opts.on '-j', '--jobs NUM', Integer, 'Number of worker threads to use' do |v|
        thread_limit = v
      end
    end
    files = optparse.parse(argv)
    thread_limit = [thread_limit, 1].max

    tp = DragonTK::ThreadPool.new thread_limit: thread_limit

    begin
      if files.empty?
        files = Dir.glob(@src_dir.join("**/*.json").to_s)
      end

      files.each do |filename|
        tp.spawn do
          compose_file filename
        end
      end
    ensure
      tp.await
    end
  end
end

Compose::Application.new.run(ARGV)
