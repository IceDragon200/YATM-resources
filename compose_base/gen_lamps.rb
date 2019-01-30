require 'fileutils'

colors = [
  "white",
  "grey",
  "dark_grey",
  "black",
  "violet",
  "blue",
  "cyan",
  "dark_green",
  "green",
  "yellow",
  "brown",
  "orange",
  "red",
  "magenta",
  "pink",
]

sizes = ["small", "large"]
target_dirname = File.join(__dir__, "../compose_src/blocks/lamp")

FileUtils.rm_rf target_dirname
FileUtils.mkdir_p target_dirname

Dir.glob(File.join(__dir__, "lamp", "*.json")) do |filename|
  contents = File.read(filename)
  basename = File.basename(filename)
  sizes.each do |size|
    colors.each do |color|
      new_contents = contents.gsub("$color$", color).gsub("$size$", size)
      target_filename = File.join(target_dirname, "#{size}_#{color}_" + basename)
      puts "WRITE: #{target_filename}"
      File.write(target_filename, new_contents)
    end
  end
end
