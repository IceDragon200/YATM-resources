require 'fileutils'
require_relative '../../compose_context'
require_relative '../colors'

colors = Gen.colors

ctx = Compose::Context.new('compose_base/blocks/gen_packages')
ctx.add_reference(nil, __FILE__)

Dir.glob(File.join(__dir__, "packages", "*.json")) do |filename|
  ctx.add_reference(nil, filename)
end

if ctx.modified
  ctx.save_file()
  puts "Concrete have changed"
  target_dirname = File.join(__dir__, "../../compose_src/generated_blocks/packages")

  FileUtils.rm_rf target_dirname
  FileUtils.mkdir_p target_dirname

  Dir.glob(File.join(__dir__, "packages", "*.json")) do |filename|
    contents = File.read(filename)
    basename = File.basename(filename)
    colors.each do |color|
      new_contents = contents.gsub("$color$", color)
      target_filename = File.join(target_dirname, "#{color}_" + basename)
      puts "WRITE: #{target_filename}"
      File.write(target_filename, new_contents)
    end
  end
else
  puts "Nothing to do."
end
