require 'exts/timer'
require 'exts/random'

require 'game_objects/bullet'

require 'libs/aniruby/aniruby'

class Human
  include RandomExtension

  attr_reader :x, :y, :w, :h, :death_sfx
  attr_writer :alive, :start_death
  attr_accessor :bullet

  WIDTH = 32
  HEIGHT = 32
  SPEED = 40

  # In seconds
  MAX_MOVEMENT_TIME = 5
  THOUGHT_TIME = 3
  SHOOT_TIME = 2

  CHANCE_OF_MOVEMENT = 8.5

  DIRECTIONS = {
    north: [0, 1],
    ne: [1, 1],
    east: [1, 0],
    se: [1, -1],
    south: [0, -1],
    sw: [-1, -1],
    west: [-1, 0],
    nw: [-1, 1]
  }

  # @param x [Integer] The x position.
  # @param y [Integer] The y position.
  # @param color [Color] The human color.
  # @param bullet_speed [Integer] The speed of the bullet
  # @param level [Room] A reference to the current level.
  # @param player [Player] A reference to that pesky player.
  def initialize(x, y, color, bullet_speed, level, player)
    @x = x
    @y = y
    @w = WIDTH
    @h = HEIGHT

    @direction = nil
    @bullet = nil

    @map = level
    @player = player

    @color = color
    @bullet_speed = bullet_speed

    @start_death = false
    @alive = true

    @moving = false
    @can_shoot = false

    # Timers
    @tought = Timer.every(rand(1..THOUGHT_TIME), -> { check_move })
    @movement = Timer.new(rand(1..MAX_MOVEMENT_TIME))
    @shoot = Timer.after(SHOOT_TIME, -> { @can_shoot = true })

    # Animations
    @idle_anim = AniRuby::Animation.new('../assets/human_idle.png', 32, 32, retro: true)
    @walk_anim = AniRuby::Animation.new('../assets/human_walking.png', 32, 32, retro: true)
    @death_anim = AniRuby::Animation.new('../assets/human_death.png', 32, 32, retro: true, loop: false)
    @current_anim = @idle_anim

    @shot_sfx = Gosu::Sample.new('../assets/sounds/shoot.wav')
    @death_sfx = Gosu::Sample.new('../assets/sounds/kill.wav')
  end

  # @todo Use alive? instead of dead? for more uniform naming.
  # Is this human alive?
  # @return [Boolean]
  def dead?
    true unless @alive
  end

  def die!
    @current_anim = @death_anim
    @alive = false
    @start_death = true
  end

  def update(dt)
    return unless @alive # Don't update if death

    update_bullet(dt) # Do update bullets as long as possible

    @current_anim.update # Do update animation because of death animation

    # Kill ourselves if we're touching a wall
    if @map.tiles[:walls].any? { |wall| intersect?(wall, self) }
      die!
      @death_sfx.play
    end
    # TODO: Die if colliding with another human.

    update_movement(dt)
    update_timers(dt)
    update_shooting
  end

  def update_timers(dt)
    @tought.update(dt)

    unless @can_shoot
      @shoot.update(dt)
    end

    if @shoot.done? && @can_shoot
      @shoot.reset
      @shoot.time = rand(1..SHOOT_TIME)
    end
  end

  def update_bullet(dt)
    # Kill bullet if it's colliding with a wall
    if @bullet && @map.tiles[:walls].any? { |wall| intersect?(wall, @bullet) }
      @bullet.alive = false
    end

    @bullet&.update(dt)
    @bullet = nil unless @bullet&.alive?
  end

  def update_movement(dt)
    if @moving && !@movement.done?
      @current_anim = @walk_anim
      @movement.update(dt)

      dx, dy = * @direction

      @x += dx * SPEED * dt
      @y += dy * SPEED * dt
    elsif @movement.done? && @moving
      @current_anim = @idle_anim
      @moving = false

      @movement.reset
      @movement.time = rand(0..MAX_MOVEMENT_TIME)
    end
  end

  def update_shooting
    dir = check_player_pos
    shoot(dir) if dir
  end

  def check_move
    srand
    chance = rand

    if chance < CHANCE_OF_MOVEMENT
      @moving = true

      # NOTE: For now let's not make the humans move diagonally
      @direction = DIRECTIONS.fetch_values(:north, :east, :south, :west).sample
    end
  end

  def check_player_pos
    if @player.x + @player.w < @x &&
       @player.y <= @y &&
       @player.y + @player.h < @y + @h
    then
      return DIRECTIONS[:west]
    end

    if @player.x > @x + @w &&
       @player.y <= @y &&
       @player.y + @player.h < @y + @h
    then
      return DIRECTIONS[:east]
    end

    if @player.y + @player.h < @y &&
       @player.x >= @x &&
       @player.x <= @x + @w
    then
      return DIRECTIONS[:south]
    end

    if @player.y + @player.h > @y &&
       @player.x >= @x &&
       @player.x <= @x + @w
    then
      return DIRECTIONS[:north]
    end

    nil
  end

  def shoot(direction)
    if @can_shoot && !@bullet
      @bullet = Bullet.new(@x, @y, @bullet_speed, @color, direction)
      @shot_sfx.play(0.2)
    end

    @can_shoot = false
  end

  def draw
    return unless @alive

    dx, dy = *@direction
    if dx&.negative?
      @current_anim.draw(@x + 32, @y, 0, -1, 1, @color)
    else
      @current_anim.draw(@x, @y, 0, 1, 1, @color)
    end

    @bullet&.draw
  end

  # AABB collision detection.
  # Both boxes must have defined the `#x`, `#y`, `#w` and `#h` methods.
  # @param box1 [Object]
  # @param box2 [Object]
  # @return [Boolean]
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
end
