require 'minil/image'
require 'fileutils'

target_dir = File.join(__dir__, '../../textures/blocks/pylon/top.mask')
FileUtils.rm_rf(target_dir)
FileUtils.mkdir_p(target_dir)

vecs = [[1, 0], [0, 1], [-1, 0], [0, -1]]
ox = 3
oy = 3
w = 9
h = 9

cx = ox
cy = oy

cells = [[cx, cy]]
vecs.each do |(vx, vy)|
  l = if vx != 0
    w
  else
    h
  end
  l.times do
    cx += vx
    cy += vy
    cells << [cx, cy]
  end
end

cells.pop
# 255 255 255 Mask 0
# 227 227 227 Mask 1
# 199 199 199 Mask 2
# 171 171 171 Mask 3
# 143 143 143 Mask 4
# 115 115 115 Mask 5
#  87  87  87 Mask 6
#  59  59  59 Mask 7
color_stages = [
  [255, 255, 255, 255],
  [199, 199, 199, 255],
  [171, 171, 171, 255],
].reverse
cells.size.times do |i|
  image = Minil::Image.new
  image.create(16, 16)
  cells.size.times do |j|
    i2 = (i + j) % cells.size
    color = color_stages[(j / 4) % color_stages.size]
    (x, y) = cells[i2]
    image.set_pixel(x, y, color)
  end
  image.save_file(File.join(target_dir, "%02d.png" % i))
end

p cells
