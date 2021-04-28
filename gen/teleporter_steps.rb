require 'minil/image'
require 'fileutils'

stages =
  (0..3).map do |i|
    Minil::Image.load_file("../textures/blocks/teleporter/top.mask/#{i}.png")
  end

frames = []

max_frames = 16

frames_per_stage = max_frames / stages.size
frames_norm = frames_per_stage - 1

stages.size.times do |stage_index|
  start = stages[stage_index]
  final = stages[(stage_index + 1) % stages.size]
  frames_per_stage.times do |i|
    d = i / frames_norm.to_f

    dest = start.lerp(final, d)
    frames.push(dest)
  end
end

output = Minil::Image.create(stages[0].width, stages[0].height * max_frames)
frames.each_with_index do |frame, i|
  output.blit(frame, 0, frame.height * i, 0, 0, frame.width, frame.height)
end

output.save_file("teleport_anim.png")
