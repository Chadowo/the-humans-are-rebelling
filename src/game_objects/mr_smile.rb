class MrSmile
  attr_reader :x, :y, :w, :h
  SPEED = 150

  def initialize(player)
    @x = 0
    @y = 0
    @w = 32
    @h = 32

    @player = player

    @sprite = Gosu::Image.new('../assets/mr_smile.png', retro: true)
  end

  def update(dt)
    if @x < @player.x
      @x += SPEED * dt
    elsif @x > @player.x
      @x -= SPEED * dt
    end

    if @y < @player.y
      @y += SPEED * dt
    elsif @y > @player.y
      @y -= SPEED * dt
    end
  end

  def draw
    @sprite.draw(@x, @y, 0)
  end
end
