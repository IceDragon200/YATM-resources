#!/usr/bin/env ruby
require 'minil'
require 'minil/image'
require 'fileutils'

# paintings use a 32px cell size to keep some level of detail
@cell_size = 32
@paintings_dir = File.expand_path("textures/paintings", __dir__)
@build_dir = File.expand_path("build/paintings", __dir__)

FileUtils.mkdir_p @build_dir

buffer_image = Minil::Image.create(@cell_size, @cell_size)
Dir.children(@paintings_dir).each do |child|
  filename = File.join(@paintings_dir, child)

  image = Minil::Image.load_file(filename)

  cols = image.width / @cell_size
  rows = image.height / @cell_size

  puts "#{filename} #{cols}x#{rows}"
  extname = File.extname(filename)
  basename = File.basename(filename, extname)
  rows.times do |row|
    cols.times do |col|
      buffer_image.blit(image, 0, 0, col * @cell_size, row * @cell_size, @cell_size, @cell_size)

      new_filename = File.join(@build_dir, basename + "_#{col}_#{row}" + extname)
      buffer_image.save_file(new_filename)
    end
  end
end
#buffer_image.destroy
