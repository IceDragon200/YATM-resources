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

@texture_cache = {}
@root_dir = Pathname.new(__dir__)
@texture_dir = @root_dir.join('textures')
@src_dir  = @root_dir.join('compose_src')
@output_dir = @root_dir.join('composed')

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
      if key == '$include'
        data = load_composer_file(@src_dir.join(value + '.json').to_s, options: { load_variables: false })
        result = result.deep_merge(data)
      else
        result[key] = proprocess_includes(value)
      end
    end
    result
  when Array
    data.map do |value|
      proprocess_includes(value)
    end
  end
  data
end

def preprocess_data(data, **options)
  result = preprocess_includes(data)
  if options.fetch(:load_variables, true)
    if result.has_key?('variables')
      return replace_with_variables(result['variables'], result)
    end
  end
  result
end

def load_composer_file(filename, **options)
  preprocess_data(load_json(filename), options)
end

Dir.chdir src_dir.to_s do
  Dir.glob("**/*.json") do |filename|
    puts filename
    data = load_composer_file(filename)
    output_basename = data.fetch('output')
    target_filename = @output_dir.join(output_basename)
    FileUtils.mkdir_p File.dirname(target_filename)
    src_layers = data.fetch('layers')
    layers = {}
    src_layers.each_pair do |layer_name, layer|
      texture_filename = @texture_dir.join(layer.fetch('texture')).to_s
      @texture_cache[texture_filename] ||= Minil::Image.load_file texture_filename
      layers[layer_name] = layer.merge({
        'texture' => @texture_cache[texture_filename]
      })
    end
    w, h = 0, 0
    layers.each do |_, layer|
      texture = layer.fetch('texture')
      w = texture.width if texture.width > w
      h = texture.height if texture.height > h
    end
    # buffer frame
    buffer_frame = Minil::Image.create(w, h)
    # frame layers are composed on before being drawn to the buffer
    blit_frame = Minil::Image.create(w, h)
    src_frames = data.fetch('frames')
    frames = src_frames.map do |frame|
      buffer_frame.clear
      frame_layers = frame.fetch('layers')
      frame_layers.each do |layer_name|
        layer = layers.fetch(layer_name)
        texture = layer.fetch('texture')
        src_frame = if layer.has_key?('blend')
          blit_frame.clear
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
        buffer_frame.alpha_blit_r(src_frame, 0, 0, texture.rect, layer.fetch('alpha', 255))
      end
      buffer_frame.dup
    end
    result_height = h * frames.size
    result = Minil::Image.create(w, result_height)
    frames.each_with_index do |frame, index|
      result.blit_r(frame, 0, index * h, frame.rect)
    end
    frames.clear
    result.save_file target_filename.to_s + '.png'
    GC.start
  end
end
