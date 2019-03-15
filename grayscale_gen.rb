# Generates a GIMP palette list for 16 grayscale values
stages = 8
(stages - 1).downto(0).each_with_index do |i, index|
  delta = i / (stages - 1).to_f
  channel = (255 * delta * delta).to_i
  puts "%\s4d %\s4d %\s4d RampMask.3 %X" % [channel, channel, channel, index]
end
