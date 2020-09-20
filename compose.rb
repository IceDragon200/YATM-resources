#!/usr/bin/env ruby
require 'bundler'
Bundler.require
require 'dragontk/thread_pool'
require 'dragontk/thread_safe'
require 'active_support/core_ext/hash'
require 'moon-logfmt/logger'
require 'json'
require 'pathname'
require 'fileutils'
require 'optparse'
require_relative 'compose_context'
require_relative 'lib/minil'

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

  def initialize(project, data, context:, logger:)
    @logger = logger
    @context = context
    @project = project
    @data = data
    @frame_layers = @data.fetch('layers')
  end

  protected def render_layer(layer)
    texture = layer.fetch('texture')
    src_frame = if layer.has_key?('mask')
      mask_texture = layer['mask']
      blit_frame = Minil::Image.create(@buffer_frame.width, @buffer_frame.height)
      blit_frame.mask_blit(texture, mask_texture, 0, 0, 0, 0, mask_texture.width, mask_texture.height)
      blit_frame
    else
      texture
    end
    src_frame = if layer.has_key?('blend')
      # frame layers are composed on before being drawn to the buffer
      blit_frame = Minil::Image.create(@buffer_frame.width, @buffer_frame.height)
      blend = layer.fetch('blend')
      type = blend.fetch('type')
      case type
      when 'multiply_color'
        blit_frame.blit_r(src_frame, 0, 0, src_frame.rect)
        blit_frame.blend_multiply_fill_rect(0, 0, blit_frame.width, blit_frame.height, blend.fetch('value'))
      when 'overlay_color'
        blit_frame.blit_r(src_frame, 0, 0, src_frame.rect)
        blit_frame.blend_overlay_fill_rect(0, 0, blit_frame.width, blit_frame.height, blend.fetch('value'))
      when 'hard_light_color'
        blit_frame.blit_r(src_frame, 0, 0, src_frame.rect)
        blit_frame.blend_hard_light_fill_rect(0, 0, blit_frame.width, blit_frame.height, blend.fetch('value'))
      else
        raise ArgumentError, "unsupported blend mode #{type}"
      end
      blit_frame
    else
      src_frame
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
      src_frame = render_layer(layer)
      src_rect = calculate_frame_src_rect(layer, frame_layer)
      transform = calculate_frame_transform(layer, frame_layer)
      opacity = calculate_frame_opacity(layer, frame_layer)
      blend_mode = frame_layer.fetch('blend', 'normal')
      case blend_mode
      when 'normal'
        @buffer_frame.alpha_blit_r(src_frame,
          transform.translate.x,
          transform.translate.y,
          src_rect,
          opacity)
      when 'overlay', 'multiply', 'hard_light'
        @buffer_frame.blend_blit_r(blend_mode.to_sym, src_frame,
          transform.translate.x,
          transform.translate.y,
          src_rect,
          opacity)
      else
        raise "unexpected blend mode requested for layer #{blend_mode}"
      end
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

  def initialize(env, data, context:, logger:)
    @context = context
    @logger = logger
    @env = env
    @data = data
    @source_layers = data.fetch('layers')
    @source_frames = data.fetch('frames')
  end

  def preload_texture(texture_basename)
    texture_filename = @env.texture_dir.join(texture_basename).to_s
    @env.texture_cache[texture_filename] ||= Minil::Image.load_file(texture_filename)
    @context.add_reference(nil, texture_filename)
    return @env.texture_cache[texture_filename]
  end

  protected def preload_layers
    @layers = {}
    @source_layers.each_pair do |layer_name, layer|
      new_layer = layer.merge({
        'texture' => preload_texture(layer.fetch('texture'))
      })
      if new_layer['mask'] then
        new_layer['mask'] = preload_texture(new_layer.fetch('mask'))
      end
      @layers[layer_name] = new_layer
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
      compositor = Compose::FrameCompositor.new(self, frame,
        context: @context, logger: @logger.new(frame: index)
      )
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

  def initialize()
    @logger = Moon::Logfmt.new
    @logger.io = STDOUT.thread_safe
    @logger.level = :info
    @texture_cache = {}
    @project_counter = 0
  end

  def load_json(filename)
    begin
      JSON.parse(File.read(filename))
    rescue => ex
      @logger.error filename: filename
      raise ex
    end
  end

  private def replace_with_variables(vt, data, **options)
    case data
    when Hash
      if data.has_key?('$variable')
        return vt.fetch(data['$variable'])
      end
      result = {}
      data.each_pair do |key, value|
        result[key] = replace_with_variables(vt, value, **options)
      end
      return result
    when Array
      return data.map { |value| replace_with_variables(vt, value, **options) }
    end
    data
  end

  def proprocess_includes(data, **options)
    case data
    when Hash
      result = {}
      data.each_pair do |key, value|
        if key == '$includes'
          value.each do |file|
            filename = @src_dir.join(file + '.json').to_s
            partial = load_composer_file(filename, options)
            result = result.deep_merge(partial)
          end
        else
          proprocessed_result = proprocess_includes(value, **options)
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
        proprocess_includes(value, **options)
      end
    else
      data
    end
  end

  def preprocess_data(data, **options)
    result = proprocess_includes(data, **options)
    if options.fetch(:load_variables, true)
      if result.has_key?('variables')
        vt = result['variables']
        # evaluate variables
        vt = replace_with_variables(vt, vt, **options)
        # and then evaluate the rest of the data
        return replace_with_variables(vt, result, **options)
      end
    end
    result
  end

  def load_composer_file(filename, context:, **options)
    case File.extname(filename)
    when ".json"
      context.add_reference(options[:active_filename], filename)
      preprocess_data(load_json(filename), options.merge(context: context, active_filename: filename))
    else
      raise "unexpected compose file #{filename}"
    end
  end

  def compose_file(filename)
    log = @logger.new thread: Thread.current.__id__, filename: filename
    context = Compose::Context.new(filename.to_s.gsub(@root_dir.to_s, ""))
    if context.modified
      log.info filename: filename, msg: "Loading Compose file"
      data = load_composer_file(filename, context: context)
      unless data.has_key?('output')
        log.info filename: filename, msg: "Compose file has no output, skipping"
        return :error
      end
      log.info filename: filename, msg: "Loaded Compose file"
      output_basename = data.fetch('output')
      target_filename = @output_dir.join(output_basename)
      FileUtils.mkdir_p File.dirname(target_filename)

      project = Compose::Project.new(self, data, context: context, logger: log.new(project: @project_counter += 1))
      project.perform

      image_filename = target_filename.to_s + '.png'
      log.info target_filename: image_filename, msg: "Saving File"

      project.result.save_file image_filename
      context.add_reference(nil, image_filename)

      if data.key?('meta')
        meta_filename = image_filename + '.mcmeta'
        File.write(meta_filename, JSON.dump(data.fetch('meta')))
        context.add_reference(nil, meta_filename)
      end

      context.save_file()
      GC.start
      :modified
    else
      log.warn msg: "Sources haven't been modified"
      :unmodified
    end
  end

  def run(argv)
    root = __dir__

    time_started = Time.now
    thread_limit = 1
    optparse = OptionParser.new do |opts|
      opts.on '-j', '--jobs NUM', Integer, 'Number of worker threads to use' do |v|
        thread_limit = v
      end

      opts.on '-r', '--root DIRNAME', String, 'Set root' do |v|
        root = File.expand_path(v)
      end
    end
    files = optparse.parse(argv)

    @root_dir = Pathname.new(root)
    @texture_dir = @root_dir.join('textures')
    @src_dir  = @root_dir.join('compose_src')
    @output_dir = @root_dir.join('build')

    thread_limit = [thread_limit, 1].max

    tp = DragonTK::ThreadPool.new thread_limit: thread_limit, abort_on_exception: true

    project_count = 0
    project_modified = 0
    project_unmodified = 0
    project_error = 0

    projects_with_errors = []

    begin
      if files.empty?
        files = Dir.glob(@src_dir.join("**/*.json").to_s)
      end

      files =
        files.map do |filename|
          if File.directory?(filename)
            Dir.glob(File.join(filename, "**/*.json"))
          else
            filename
          end
        end.flatten

      files.each do |filename|
        tp.spawn do
          project_count += 1
          case compose_file(filename)
          when :error
            project_error += 1
            projects_with_errors.push(filename)
          when :modified
            project_modified += 1
          when :unmodified
            project_unmodified += 1
          end
        end
      end
    ensure
      tp.await
      time_ended = Time.now
      logs = [
        "",
        "Composed in #{time_ended - time_started} seconds",
        "",
        "Projects #{project_modified} modified / #{project_unmodified} unmodified / #{project_error} errors / #{project_count} total",
        "",
      ]

      unless projects_with_errors.empty?
        logs.push("Errors:")
        projects_with_errors.each do |filename|
          logs.push "\t#{filename}"
        end
      end
      @logger.io.puts logs
    end
  end
end

Compose::Application.new().run(ARGV.dup)
