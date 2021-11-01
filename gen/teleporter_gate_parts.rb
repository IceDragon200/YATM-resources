require 'minil/image'
require 'fileutils'

begin
  image = Minil::Image.load_file("../textures/blocks/teleporter_gate/spritesheet_full.png")

  corner_front = image.subimage(32, 64, 16, 16)
  corner_outer_side = image.subimage(16, 64, 16, 16)
  corner_inner_side = image.subimage(0, 64, 16, 16)

  body_front = image.subimage(48, 64, 16, 16)
  body_outer_side = image.subimage(48, 80, 16, 16)
  body_inner_side = image.subimage(48, 96, 16, 16)

  dirname = "../textures/blocks/teleporter_gate/part"
  FileUtils.mkdir_p dirname

  corner_front.save_file(File.join(dirname, "corner.front.png"))
  corner_outer_side.save_file(File.join(dirname, "corner.outer_side.png"))
  corner_inner_side.save_file(File.join(dirname, "corner.inner_side.png"))

  body_front.save_file(File.join(dirname, "body.front.png"))
  body_outer_side.save_file(File.join(dirname, "body.outer_side.png"))
  body_inner_side.save_file(File.join(dirname, "body.inner_side.png"))
end
