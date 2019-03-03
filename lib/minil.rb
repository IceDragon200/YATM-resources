require 'minil'
require 'minil/image'
require 'minil/color'

class Minil::Image
  def blend_multiply_fill_rect(x, y, w, h, color)
    cr, cg, cb, ca = Minil::Color.cast_to_channels(color)
    h.times do |row|
      w.times do |col|
        dx, dy = x + col, y + row
        pixel = get_pixel(dx, dy)
        r, g, b, a = Minil::Color.decode(pixel)
        next if a == 0
        c = Minil::Color.encode(
          r * cr / 255,
          g * cg / 255,
          b * cb / 255,
          a * ca / 255
        )
        set_pixel(dx, dy, c)
      end
    end
  end

  private def blend_colorf(r, g, b, a, r2, g2, b2, a2, &blend)
    return (blend.call(r / 255.0, r2 / 255.0) * 255).to_i,
      (blend.call(g / 255.0, g2 / 255.0) * 255).to_i,
      (blend.call(b / 255.0, b2 / 255.0) * 255).to_i,
      a * a2 / 255
  end

  def blend_overlay_fill_rect(x, y, w, h, color)
    cr, cg, cb, ca = Minil::Color.cast_to_channels(color)
    h.times do |row|
      w.times do |col|
        dx, dy = x + col, y + row
        pixel = get_pixel(dx, dy)
        r, g, b, a = Minil::Color.decode(pixel)
        next if a == 0
        c = Minil::Color.encode(*blend_colorf(r, g, b, a, cr, cg, cb, ca) do |n, n2|
          if n < 0.5
            2 * (n * n2)
          else
            1 - 2 * (1 - n) * (1 - n2)
          end
        end)
        set_pixel(dx, dy, c)
      end
    end
  end
end
