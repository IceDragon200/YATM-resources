#!/usr/bin/env ruby
require 'minil'
require 'minil/image'
require 'oj'
require 'fileutils'
require 'set'
require 'dragontk/thread_pool'
require 'scrapyard/file_formats/png'

def get_png_dimensions(filename)
  File.open(filename, 'rb') do |file|
    buf = Scrapyard::ByteBuf.new(file, endian: :big)
    png_head = Scrapyard::FileFormat::PNG::PNGSignature.read(buf)
    loop do
      break if buf.eof?
      head = Scrapyard::FileFormat::PNG::ChunkHead.read(buf)
      case head[:name]
      when 'IHDR'
        return Scrapyard::FileFormat::PNG::IHDRChunk.read(buf)
      else
        #puts "Skipping header"
        #Scrapyard::FileFormat::PNG.skip_chunk buf, head
        raise "unexpected header #{head[:name]}"
      end
    end
  end
  return nil
end

def calc_lcm(set)
  max = set.max || 1
  lcm = max

  loop do
    if set.all? { |n| lcm % n == 0 }
      break
    else
      lcm += max
    end
    if lcm > 200
      raise "Cannot find LCM!"
    end
  end
  lcm
end

def from_tiles(dirname)
  16.times.map do |i|
    File.join(dirname, "#{i}.png")
  end
end

requested_stitching = if ARGV.empty?
  :all
else
  ARGV
end

source_groups =
  case requested_stitching
  when :all
    [[:all, Dir.glob("build/blocks/**/*.png") + Dir.glob("build/tiles/**/*.png")]]
  else
    requested_stitching.reduce([]) do |acc, name|
      case name
      when ":all"
        acc.push([[:all, Dir.glob("build/blocks/**/*.png") + Dir.glob("build/tiles/**/*.png")]])
        acc
      when ":blocks"
        acc.push([[:blocks, Dir.glob("build/blocks/**/*.png")]])
        acc
      when ":each_block"
        parent_dir = {}
        Dir.glob("build/blocks/**/*.png").each do |filename|
          next if filename.include?(".legacy/")
          next if filename.include?("/common/")
          (parent_dir[File.basename(File.dirname(filename))] ||= []).push(filename)
        end
        acc.concat(parent_dir.to_a)
      when ":tiles"
        acc.push([[:tiles, Dir.glob("build/tiles/**/*.png")]])
        acc
      else
        acc.push([name, Dir.glob("build/blocks/#{name}/*.png") + Dir.glob("build/tiles/#{name}/*.png")])
        acc
      end
    end
  end.map do |(name, sources)|
    [name, sources.reject do |filename|
      filename.include?(".legacy/") or filename.include?("/common/")
    end.sort]
  end

puts "Found #{source_groups.size} groups"
cache = {}
cached_meta = {}
frame_index_filename = {}
total_item_count = source_groups.reduce(0) do |acc, (_, sources)|
  acc + sources.reduce(0) do |acc2, source|
    puts "Loading png header for #{source}"
    head = get_png_dimensions(source)
    acc2 + head[:height] / head[:width]
  end
end
pow = 1
while pow * pow < total_item_count do
  pow += 1
end
w = h = 16 * pow
puts "Creating atlas of size #{w}x#{h}"
atlas = Minil::Image.create(w, h)
cell_w, cell_h = 16, 16
cols = atlas.width / cell_w

thread_pool = DragonTK::ThreadPool.new thread_limit: 8

begin
  i = 1
  source_groups.each do |(source_group, sources)|
    sources.each do |source|
      source_image = cache[source] ||= Minil::Image.load_file(source)
      if File.exist?(source + '.mcmeta')
        cached_meta[source] ||= Oj.load(File.read(source + '.mcmeta'))
      end

      rows = source_image.height / source_image.width
      rows.times do |row|
        x = (i % cols) * cell_w
        y = (i / cols) * cell_h
        puts "#{source} (#{row}) (#{x},#{y})"
        thread_pool.spawn do
          atlas.blit(source_image, x, y, 0, row * cell_h, cell_w, cell_h)
        end
        frame_index_filename[i] = [source_group, source]
        i += 1
        print '.'
      end
    end
  end
  puts
ensure
  thread_pool.await
end
FileUtils.mkdir_p 'build'

atlas.save_file('build/atlas_texture.png')

source_groups.each do |(source_group_name, sources)|
  puts "Creating animated texture atlas for #{source_group_name}"
  item_count = sources.size
  frame_counts = Set.new
  sources.each do |source|
    meta = cached_meta[source]
    if meta
      animation = meta["animation"]
      frametime = animation['frametime']
      frame_count = if animation.key?('frames')
        frametime * animation['frames'].size
      else
        frametime * (cache[source].height / cache[source].width)
      end
      puts "#{source} : #{frame_count}"
      frame_counts.add(frame_count)
    end
  end

  p frame_counts
  lcm = calc_lcm frame_counts
  puts "Maximum Frames: #{lcm}"

  atlas_texture_dirname = File.join(__dir__, "build/animations/#{source_group_name}")
  if File.exist?(atlas_texture_dirname)
    FileUtils::Verbose.rm_rf atlas_texture_dirname
    system('sync')
  end
  FileUtils::Verbose.mkdir_p atlas_texture_dirname
  FileUtils::Verbose.mkdir_p File.join(atlas_texture_dirname, 'x1')
  system('sync')

  pow = 1
  while pow * pow < item_count do
    pow += 1
  end
  frame_w = 16 * pow
  frame_h = 16 * pow
  puts "Creating animation frame of size #{frame_w}x#{frame_h}"
  frames = Array.new(thread_pool.thread_limit) do
    Minil::Image.create(frame_w, frame_h)
  end
  cols = frame_w / cell_w
  lcm.times do |frame_index|
    begin
      thread_pool.spawn do |index:,**_opts|
        frame = frames[index]
        frame.clear
        sources.each_with_index do |source, source_index|
          img = cache[source]
          meta = cached_meta[source]
          #puts "ANIM: #{source} (#{source_index})"
          current_img_index = if meta
            animation = meta['animation']
            frametime = animation['frametime']
            max_keyframes = if animation.key?('frames')
              animation['frames'].size
            else
              # all fframes are square, and are arranged vertically
              # therefore to calculate the number of frames it only needs to divide the height by the width
              (img.height / img.width)
            end

            current_img_index = (frame_index / frametime) % max_keyframes
            if animation.key?('frames')
              animation['frames'][current_img_index]
            else
              current_img_index
            end
          else
            0
          end
          x = (source_index % cols) * cell_w
          y = (source_index / cols) * cell_h
          frame.alpha_blit(img, x, y, 0, current_img_index * cell_h, cell_w, cell_h)
        end
        output_filename = File.join(atlas_texture_dirname, 'x1', 'frame%04d.png' % frame_index)
        puts "SAVE #{output_filename}"
        frame.save_file(output_filename)
      end
    ensure
      thread_pool.await
    end
  end
  frames = Dir.glob(File.join(atlas_texture_dirname, 'x1', "frame*.png")).sort
  [1, 2, 4, 8].each do |scale|
    if frame_h > 512
      if scale > 2 then
        puts "Frame exceeds 512 pixels, skipping scale #{scale}"
        next
      end
    end
    apng_atlas = atlas_texture_dirname + "/x#{scale}" + ".apng"
    FileUtils::Verbose.mkdir_p File.join(atlas_texture_dirname, "x#{scale}")
    begin
      frames.each do |frame_name|
        basename = File.basename(frame_name)
        scaled_frame_name = File.join(atlas_texture_dirname, "x#{scale}", basename)
        unless File.exist?(scaled_frame_name)
          thread_pool.spawn do |index:,**_opts|
            puts "Scaling frame #{basename} by #{scale}x"
            system("convert", frame_name, "-scale", "#{scale * 100}%", scaled_frame_name)
          end
        end
      end
    ensure
      thread_pool.await
    end
    system("sync")
    scaled_frames = Dir.glob(File.join(atlas_texture_dirname, "x#{scale}", "frame*.png")).sort
    system("apngasm", "-F", "-d", "100", "-o", apng_atlas, *scaled_frames)
    system("apng2gif", apng_atlas)
  end
end
