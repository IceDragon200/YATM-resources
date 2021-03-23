require 'minil/image'
require 'fileutils'

['top', 'side', 'bottom'].each do |side|
  start = Minil::Image.load_file("../textures/blocks/data_lamp/#{side}.on.png")
  final = Minil::Image.load_file("../textures/blocks/data_lamp/#{side}.off.png")

  #source = Minil::Image.load_file('../build/blocks/auto_crafter/top.on.png')
  #start = source.subimage(0, 0, source.width, source.width)
  #final = source.subimage(0, source.width, source.width, source.width)

  frames = []

  max_frames = 14
  frames_norm = max_frames - 1
  max_frames.times do |i|
    d = i / frames_norm.to_f
    dest = start.lerp(final, d)
    frames.push(dest)
  end

  FileUtils.rm_rf "../textures/blocks/data_lamp/#{side}"
  FileUtils.mkdir_p "../textures/blocks/data_lamp/#{side}"

  frames.each_with_index do |frame, i|
    frame.save_file("../textures/blocks/data_lamp/#{side}/%02d.png" % (frames_norm - i))
  end

  #dest = Minil::Image.create(start.width, start.height * frames.size)
  #frames.each_with_index do |frame, i|
  #  dest.blit(frame, 0, i * frame.height, 0, 0, frame.width, frame.height)
  #end

  #dest.save_file('../textures/blocks/data_lamp/top/.png')
end
