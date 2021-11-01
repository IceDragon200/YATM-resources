require 'minil/image'
require 'minil/color'
require 'fileutils'

image = Minil::Image.load_file("../textures/texture/noise_gaussian.png")

min_value = nil
max_value = nil

image.height.times do |y|
  image.width.times do |x|
    pixel = image.get_pixel(x, y)
    r, g, b, a = *Minil::Color.decode(pixel)

    if min_value
      if r < min_value
        min_value = r
      end
    else
      min_value = r
    end

    if max_value
      if r > max_value
        max_value = r
      end
    else
      max_value = r
    end
  end
end

variance = max_value - min_value

max_frames = 16

frames =
  max_frames.times.map do |i|
    frame = image.dup

    frame.height.times do |y|
      frame.width.times do |x|
        pixel = frame.get_pixel(x, y)
        r, g, b, a = *Minil::Color.decode(pixel)

        d = variance * i / max_frames
        r = r + (r - min_value + d) % variance
        g = g + (g - min_value + d) % variance
        b = b + (b - min_value + d) % variance
        frame.set_pixel(x, y, Minil::Color.encode(r, g, b, a))
      end
    end

    frame
  end

dest = Minil::Image.create(image.width, image.height * frames.size)
frames.each_with_index do |frame, i|
  dest.blit(frame, 0, i * image.height, 0, 0, frame.width, frame.height)
end

dest.save_file("phase_test.png")
