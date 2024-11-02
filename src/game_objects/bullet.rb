# The bullet is a projectile used to kill by both robots and humans.
# Like other game objects it has a position, dimension, plus a direction.
class Bullet
  attr_reader :x, :y, :w, :h
  attr_writer :alive

  # The speed of the bullet.
  SPEED = 400

  # @param x [Integer] The initial x position of the bullet.
  # @param y [Integer] The initial y position of the bullet.
  # @param speed [Integer] The speed of the bullet.
  # @param color [Color] The color of the bullet
  # @param direction [Array<Integer>] The direction of the bullet.
  def initialize(x, y, speed = SPEED, color = Gosu::Color::GREEN, direction)
    @x = x
    @y = y
    @w = 20
    @h = 3

    @speed = speed
    @color = color

    @direction = direction

    @alive = true
  end

  # Is the bullet alive (i.e. Still active)?
  # @return [Boolean]
  def alive?
    @alive
  end

  def update(dt)
    return unless @alive

    # In case direction is north or south, adjust the bullet's dimensions so it
    # faces down
    if @direction == [0, 1] || @direction == [0, -1]
      @h = 20
      @w = 3
    else
      @h = 3
      @w = 20
    end

    dx, dy = *@direction

    @x += dx * @speed * dt
    @y += dy * @speed * dt

    @alive = false if out_of_bounds?
  end

  # Check if the bullet has gone out of the screen bounds (i.e. It can't be seen on the
  # screen anymore).
  # @return [Boolean]
  def out_of_bounds?
    if @x > THARWindow::WIDTH || (@x + @w).negative? ||
       @y > THARWindow::HEIGHT || (@y + @h).negative?
    then
      true
    end
  end

  def draw
    return unless @alive

    Gosu.draw_rect(@x, @y, @w, @h, @color)
  end
end
