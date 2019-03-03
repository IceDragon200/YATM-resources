#
# A modified version of line_tracer
#
require_relative 'minil'

class LineTracer2
  class Path
    attr_reader :id
    attr_reader :reference_id
    attr_accessor :points
    attr_accessor :wrapped

    def initialize(reference_id, id)
      @id = id
      @reference_id = reference_id
      @points = []
      @wrapped = false
    end

    def add_point(x, y, data = {})
      @points << [x, y, data]
    end

    def [](index)
      @points[index]
    end

    def []=(index, point)
      @points[index] = point
    end

    def size()
      @points.size
    end

    def lerp_value(a, b, time)
      case a
      when Hash
        a.reduce({}) do |acc, (key, value)|
          acc[key] = lerp_value(a[key], b[key], time)
          acc
        end
      when Array
        a.each_index do |index|
          lerp_value(a[index], b[index], time)
        end
      when Integer
        a + ((b - a) * time).floor
      when Float
        a + (b - a) * time
      else
        raise
      end
    end

    def lerp(time)
      rel_time = (time * size.to_f) - (time * size).floor
      index = (time * size).floor
      next_index = index + 1

      if @wrapped
        next_index %= size
      else
        next_index = [next_index, size - 1].min
      end
      a = @points[index]
      b = @points[next_index]
      d = a.size.times.map do |i|
        lerp_value(a[i], b[i], rel_time)
      end
      return rel_time, d, a, b
    end
  end

  def initialize()
    @path_g_id = 0
    @paths = []
  end

  def add_path(reference_id)
    @path_g_id += 1
    path = Path.new(reference_id, @path_g_id)
    @paths << path
    path
  end

  def delete_path(reference_id)
    @paths = @paths.reject do |path|
      path.reference_id == reference_id
    end
    self
  end

  def lerp(time)
    @paths.map do |path|
      [path.reference_id, path.lerp(time)]
    end
  end
end

lt = LineTracer2.new
path = lt.add_path(:main)
path.wrapped = true
path.add_point(0, 0)
path.add_point(7, 0)
path.add_point(7, 7)
path.add_point(0, 7)

trail_steps = 2 # how steps additional steps should be rendered per frame?
steps = 16 # how many steps/frames total are present?filename
sub_steps = 4 # how many sub steps are present per step? - this further divides a step down into smaller steps, though all the changes will be rendered to the same frame

image = Minil::Image.create(8, 8)
atlas = Minil::Image.create(image.width, image.height * steps)
steps.times do |step|
  image.fill(0xFF_00_00_00)
  trail_steps.downto(0) do |trail_step|
    time_step = step - trail_step
    previous_time_step = time_step - 1
    0.upto(sub_steps) do |sub_step|
      s = previous_time_step + (time_step - previous_time_step) * (sub_step.to_f / sub_steps.to_f)
      t = s / steps.to_f
      p [t, s]
      lt.lerp(t % 1).each do |(_reference_id, (time, d, a, b))|
        x, y, _ = d
        p [x, y]
        image.set_pixel(x, y, [0xFF, 0xFF, 0xFF, 0xFF * trail_step / trail_steps])
      end
    end
  end
  atlas.blit(image, 0, step * image.height, 0, 0, image.width, image.height)
end
atlas.save_file("out.png")
