require 'minil/image'
require 'fileutils'

Dir.glob("../textures/blocks/docking_crate/*.png").each do |filename|
  basename = File.basename(filename, ".png")

  if basename.start_with?("side_")
    type = basename.split("_")[1]
    base = Minil::Image.load_file("../textures/blocks/overhead_docking_station/base/side.#{type}.png")
    image = Minil::Image.load_file(filename)
    base.blit(image, 2, 0, 2, 4, 12, 12)

    base.save_file("../textures/blocks/overhead_docking_station/side.#{type}.wcrate.png")
  elsif basename.start_with?("top_")
    type = basename.split("_")[1]
    image = Minil::Image.load_file(filename)
    base = Minil::Image.load_file("../textures/blocks/overhead_docking_station/base/top.blank.png")
    base.blit(image, 2, 2, 2, 2, 12, 12)

    base.save_file("../textures/blocks/overhead_docking_station/top.#{type}.wcrate.png")
  else
    raise "unexpected basename #{basename}"
  end
end
