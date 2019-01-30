#!/usr/bin/env ruby
require 'minil/color'
require 'minil/image'

Dir.chdir __dir__ do
  base = Minil::Image.load_file("build/blocks/teleporter/top.off.png")
  frame = Minil::Image.create(base.width * 4, base.height * 4)

  base.width.times do |col|
    begin
      h = col / 2

      rx = col + base.width
      lx = base.width - 1 - col
      rc = col # right column
      lc = base.width - 1 - col # left column
      y = frame.height - base.height - h
      frame.blit(base, rx, y, rc, 0, 1, base.height)
      frame.blit(base, lx, y, lc, 0, 1, base.height)
    end
  end

  base.height.times do |row|
    w = ((row + 1) * 2)
    w.times do |col|
      x = base.width - row + col
      y = base.height + row / 2
      y2 = base.height * 2 - 1 - row / 2
      frame.set_pixel(x, y, base.get_pixel([col, base.width].min, [row - col, 0].max))
      frame.set_pixel(x, y2, base.get_pixel([base.width - 1 - col, 0].max, [base.height - 1 - row + col, base.height - 1].min))
    end
  end
  #base.height.times do |row|
  #  base.width.times do |col|
  #    x = base.width + col - row * 2
  #    y = base.height + row / 2 + col / 2
  #    frame.set_pixel(x, y, base.get_pixel(col, row))
  #  end
  #end

  frame.save_file("iso_test.png")
end
