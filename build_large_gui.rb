#!/usr/bin/env ruby
require 'fileutils'
require 'minil/image'
require_relative 'compose_context'
require_relative 'lib/minil'

@textures = File.join(__dir__, 'textures')
@build = File.join(__dir__, 'build')

Dir.glob(File.join(@textures, "gui/*.9s.png")).each do |filename|
  image = Minil::Image.load_file(filename)

  cw = image.width / 3
  ch = image.height / 3

  dest_image = Minil::Image.create(512, 512)

  new_cols = dest_image.width / cw
  new_rows = dest_image.height / ch

  new_cols.times do |y|
    sy =
      case y
      when 0
        0
      when new_rows-1
        ch * 2
      else
        ch
      end

    new_rows.times do |x|
      sx =
        case x
        when 0
          0
        when new_cols-1
          cw * 2
        else
          cw
        end

      dest_image.blit(image, x * cw, y * ch, sx, sy, cw, ch)
    end
  end

  target_filename = File.join(@build, 'gui', File.basename(filename).gsub(".9s", ""))
  FileUtils.mkdir_p File.dirname(target_filename)
  puts "WRITE\t#{target_filename}"
  dest_image.save_file(target_filename)
end
