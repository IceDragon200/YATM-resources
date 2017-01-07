#!/usr/bin/env ruby
require 'minil'
require 'minil/image'

sources = [
  'build/blocks/fluid_replicator/front.off.png',
  'build/blocks/fluid_replicator/front.on.png',
  'build/blocks/fluid_replicator/front.idle.png',
  'build/blocks/fluid_replicator/front.error.png',

  'build/blocks/item_replicator/front.off.png',
  'build/blocks/item_replicator/front.on.png',
  'build/blocks/item_replicator/front.idle.png',
  'build/blocks/item_replicator/front.error.png',
]

cache = {}
image = Minil::Image.create(256, 256)
cols = image.width / 16

i = 1
sources.each do |source|
  source_image = cache[source] ||= Minil::Image.load_file(source)
  rows = source_image.height / 16
  rows.times do |row|
    x = (i % cols) * 16
    y = (i / cols) * 16
    image.blit(source_image, x, y, 0, row * 16, 16, 16)
    i += 1
  end
end

image.save_file('texture.png')
