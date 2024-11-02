# This class calculates the scale and offset of a viewport relative to a dimension,
# keeping the aspect ratio of the content.
# @note I'm not familiar with screen resolution handling so this may be iffy. Plus it's missing
#       other functionality.
class Resizer
  # The current virtual width.
  # @return [Integer]
  attr_accessor :virtual_width

  # The current virtual height.
  # @return [Integer]
  attr_accessor :virtual_height

  # Get the scale of the width.
  # @return [Float]
  attr_reader :scale_w

  # Get the scale of the height.
  # @return [Float]
  attr_reader :scale_h

  # Get the horizontal offset.
  # @return [Integer]
  attr_reader :off_x

  # Get the vertical offset.
  # @return [Integer]
  attr_reader :off_y

  # @param virtual_width [Integer, #to_i]
  # @param virtual_height [Integer, #to_i]
  # @return [Resizer]
  def initialize(virtual_width, virtual_height)
    @virtual_width = virtual_width.to_i
    @virtual_height = virtual_height.to_i

    @scale_w = 1.0
    @scale_h = 1.0
    @off_x = 0
    @off_y = 0
  end

  # Update the scaling and offset in real time. You'd want to call this
  # on your update loop.
  # @param new_width [Integer] The new width.
  # @param new_height [Integer] The new height.
  # @return [void]
  def update(new_width, new_height)
    scale_x = new_width / @virtual_width.to_f
    scale_y = new_height / @virtual_height.to_f
    scale = [scale_x, scale_y].min

    @off_x = (scale_x - scale) * (@virtual_width / 2)
    @off_y = (scale_y - scale) * (@virtual_height / 2)

    @scale_w = scale
    @scale_h = scale
  end

  # Utility function to transpose one set of coordinates
  # into an absolute position (i.e. Disregarding the scaling and offset).
  # @param x [Integer] The x position.
  # @param y [Integer] The y position.
  # @return [Array<Integer>] Array with the two transposed coordinates.
  def transpose_position(x, y)
    transposed_x = (x - @off_x) / @scale_w
    transposed_y = (y - @off_y) / @scale_h

    [transposed_x, transposed_y]
  end
end
