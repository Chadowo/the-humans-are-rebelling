require 'game_objects/bullet'
require 'libs/aniruby/aniruby'

class Player
  attr_reader :x, :y, :w, :h, :bullets, :death_sfx
  attr_accessor :dead

  WIDTH = 32
  HEIGHT = 32
  SPEED = 120

  # Create a new robotic exterminator to eliminate the pesky humans >:).
  # @param map [Room] The player needs to be aware of the map.
  def initialize(map)
    @x = map.tiles[:spawn].x
    @y = map.tiles[:spawn].y
    @dx = 0
    @dy = 0

    @w = WIDTH
    @h = HEIGHT

    @dead = false
    @shooting = false
    @map = map

    # Animations
    @idle_anim = AniRuby::Animation.new('../assets/player_idle.png', 32, 32, 0.03)
    @walk_anim = AniRuby::Animation.new('../assets/player_walking.png', 32, 32)
    @shoot_anim = AniRuby::Animation.new('../assets/player_firing.png', 32, 32)
    @shoot_up_anim = AniRuby::Animation.new('../assets/player_firing_up.png', 32, 32)
    @shoot_down_anim = AniRuby::Animation.new('../assets/player_firing_down.png', 32, 32)
    @death_anim = AniRuby::Animation.new('../assets/player_death.png', 32, 32)
    @current_anim = @idle_anim

    @shoot_sfx = Gosu::Sample.new('../assets/sounds/shoot.wav')
    @death_sfx = Gosu::Sample.new('../assets/sounds/death.wav')

    @bullets = []
  end

  def update(dt)
    @current_anim = @death_anim if @dead
    @current_anim.update

    return if @dead

    movement(dt)
    shooting

    # Kill ourselves if we're touching a wall
    if @map.tiles[:walls].any? { |wall| intersect?(wall, self) }
      @dead = true
      @death_sfx.play
    end

    # Kill bullet if it's colliding with a wall
    if !@bullets.empty? && @map.tiles[:walls].any? { |wall| intersect?(wall, @bullets.first) }
      @bullets.first.alive = false
    end

    @bullets.shift unless @bullets.first&.alive?
    @bullets.each { |bul| bul.update(dt) }
  end

  def movement(dt)
    # TODO: Normalize diagonal movement
    if Gosu.button_down?(Gosu::KB_LEFT)
      unless @shooting
        @x -= SPEED * dt
        @current_anim = @walk_anim
      end

      @dx = -1
    elsif Gosu.button_down?(Gosu::KB_RIGHT)
      unless @shooting
        @x += SPEED * dt
        @current_anim = @walk_anim
      end

      @dx = 1
    else
      @dx = 0
    end

    if Gosu.button_down?(Gosu::KB_UP)
      unless @shooting
        @y -= SPEED * dt
        @current_anim = @walk_anim
      end

      @dy = -1
    elsif Gosu.button_down?(Gosu::KB_DOWN)
      unless @shooting
        @y += SPEED * dt
        @current_anim = @walk_anim
      end

      @dy = 1
    else
      @dy = 0
    end

    @current_anim = @idle_anim if @dx.zero? && @dy.zero?
  end

  def shooting
    if Gosu.button_down?(Gosu::KB_SPACE)
      @shooting = true

      if @bullets.empty? && ![@dx, @dy].all?(&:zero?)
        @bullets << Bullet.new(@x, @y, [@dx, @dy])
        @shoot_sfx.play
      end

      @current_anim = @shoot_anim unless @dx.zero?
      @current_anim = @shoot_up_anim if @dy == -1 && @dx.zero?
      @current_anim = @shoot_down_anim if @dy == 1 && @dx.zero?
    else
      @shooting = false
    end
  end

  # AABB collision detection.
  # Both boxes must have defined the `#x`, `#y`, `#w` and `#h` methods.
  def intersect?(box1, box2)
    if (box1.x < box2.x + box2.w) &&
       (box1.x + box1.w > box2.x) &&
       (box1.y < box2.y + box2.h) &&
       (box1.y + box1.h > box2.y)
      true
    else
      false
    end
  end

  def draw
    if @dx.negative?
      @current_anim.draw(@x + WIDTH, @y, 0, -1.0, 1.0)
    else
      @current_anim.draw(@x, @y, 0)
    end

    @bullets.each(&:draw)
  end
end
