require 'fileutils'
require_relative '../../compose_context'

tiers = [
  "tier0",
  "tier1",
  "tier2",
  "tier3",
]

types = ["fluid", "item", "ele"]

ctx = Compose::Context.new('compose_base/items/gen_inventory_drives')
ctx.add_reference(nil, __FILE__)

Dir.glob(File.join(__dir__, "keys", "*.json")) do |filename|
  ctx.add_reference(nil, filename)
end

if ctx.modified
  ctx.save_file()
  puts "Inventory Drives have changed"
  target_dirname = File.join(__dir__, "../../compose_src/generated_items/inventory_drives")

  FileUtils.rm_rf target_dirname
  FileUtils.mkdir_p target_dirname

  Dir.glob(File.join(__dir__, "inventory_drives", "*.json")) do |filename|
    contents = File.read(filename)
    basename = File.basename(filename)
    types.each do |type|
      tiers.each do |tier|
        new_contents = contents.gsub("$tier$", tier).gsub("$type$", type)
        target_filename = File.join(target_dirname, "#{type}_#{tier}_" + basename)
        puts "WRITE: #{target_filename}"
        File.write(target_filename, new_contents)
      end
    end
  end
else
  puts "Nothing to do."
end
