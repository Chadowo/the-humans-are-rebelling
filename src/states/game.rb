require 'exts/room_parser'
require 'exts/timer'
require 'exts/random'

require 'game_objects/player'
require 'game_objects/human'

class StateGame < State
  include RandomExt

  TILE_WIDTH = 32
  TILE_HEIGHT = 32

  # Grab all the room files except special paths
  ROOMS = Dir.entries("../assets/rooms/").reject! { |e| e == '..' || e == '.' ||
                                                    e == 'start.dat'}

  def initialize
    @level = Room.load_file('../assets/rooms/start.dat')
    @player = Player.new(@level)
    @humans = []

    @font = Gosu::Font.new(34, name: '../assets/fonts/unifont.ttf')
    @live_sprite = Gosu::Image.new('../assets/live.png', retro: true)

    @score = 0
    @lives = 3

    @fade_out_timer = Timer.after(1, -> { @fade_out = true })
    @reset_timer = Timer.after(2, -> { reset })

    @next_level_sfx = Gosu::Sample.new('../assets/sounds/next_level.wav')

    @transition = false
    @fade_out = false
    @transition_w = 0
    @transition_x = 0

    generate_humans(8, @level, @humans)
  end

  # Generate humans on the level.
  # @param quantity [Integer] How many to generate.
  # @param level [Room] The level to use as reference for the walls.
  # @param holder [Array] Where to insert the human
  def generate_humans(quantity, level, holder)
    quantity.times do
      x = rand(0..THARWindow::WIDTH - Human::WIDTH)
      y = rand(0..THARWindow::HEIGHT - Human::HEIGHT)

      # Select randomly the type of humans
      srand
      chance = rand(0)
      type = :yellow
      case chance
      when 0.0..0.3
        type = :yellow
      when 0.3..0.6
        type = :red
      when 0.6..0.9
        type = :white
      end

      color = case type
              when :yellow
                Gosu::Color::YELLOW
              when :red
                Gosu::Color::RED
              when :white
                Gosu::Color::WHITE
              end

      bullet_speed = case type
                     when :yellow
                       90
                     when :red
                       130
                     when :white
                       180
                     end

      current_human = Human.new(x, y, color, bullet_speed, @level, @player)

      # Redo if the human's colliding with a wall, another human or the player spawn
      if level.tiles[:walls].any? { |wall| intersect?(wall, current_human) } ||
         holder.any? { |human| intersect?(human, current_human) } ||
         intersect?(level.tiles[:spawn], current_human)
      then
        redo
      end

      holder << current_human
    end
  end

  def update(dt)
    transitions(dt)

    return if @fade_out

    @player.update(dt)
    if @player.dead
      @reset_timer.update(dt)
    end

    return if @fade_out || @player.dead

    @humans.each { |human| human.update(dt) }
    @humans.delete_if(&:dead?)

    start_transition if out_of_bounds?(@player)

    collisions
  end

  def collisions
    # Collision human and bullet
    @humans.each do |human|
      break unless @player.bullets.first # Unless the player has fired a bullet

      next unless intersect?(@player.bullets&.first, human)

      human.death_sfx.play
      human.die!

      @player.bullets.shift

      @score += 50
    end

    # Collision between humans bullets and player, player bullet and between human and player
    # and screen bound check
    @humans.each do |human|
      if intersect?(@player, human)
        human.death_sfx.play
        human.die!

        @player.death_sfx.play
        @player.dead = true
      end

      next unless human.bullet

      if intersect?(human.bullet, @player)
        @player.death_sfx.play
        @player.dead = true
      end

      next unless @player.bullets.first

      if intersect?(human.bullet, @player.bullets.first)
        @player.bullets.first.alive = false
        human.bullet.alive = false
      end

      human.die! if out_of_bounds?(human)
    end
  end

  def transitions(dt)
    @transition_w += 1500 * dt if @transition
    @transition_x += 1000 * dt if @fade_out

    if @transition_w >= THARWindow::WIDTH && @transition
      new_level
      @transition = false
    end

    if @transition_w >= THARWindow::WIDTH && !@transition
      @fade_out_timer.update(dt)
    end

    if @transition_x >= THARWindow::WIDTH
      @fade_out = false
      @transition_x = 0
      @transition_w = 0
      @fade_out_timer.reset
    end
  end

  def start_transition
    @transition = true
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

  # Check if the object has gone out of the screen bounds (i.e. It can't be seen on the
  # screen anymore).
  # @return [Boolean]
  def out_of_bounds?(obj)
    if obj.x > THARWindow::WIDTH || (obj.x + obj.w).negative? ||
       obj.y > THARWindow::HEIGHT || (obj.y + obj.h).negative?
    then
      true
    end
  end

  # Reset the game.
  # @return [void]
  def reset
    @player = Player.new(@level)
    @humans.clear
    @lives -= 1

    if @lives.zero?
      @score = 0
      @lives = 3

      @level = Room.load_file('../assets/rooms/start.dat')
      @player = Player.new(@level)
    end

    generate_humans(8, @level, @humans)
    @reset_timer.reset
  end

  # Select a new room at random and use it.
  def new_level
    @next_level_sfx.play

    @humans.clear

    @level = Room.load_file("../assets/rooms/#{ROOMS.sample}")
    @player = Player.new(@level)

    generate_humans(8, @level, @humans)
  end

  def draw
    @level.room_data.each_with_index do |row, y|
      row.each_with_index do |column, x|
        case column.to_i
        when 0 # Nothing
          next
        when 1 # Wall
          Gosu.draw_rect(x * TILE_WIDTH,
                         y * TILE_HEIGHT,
                         TILE_WIDTH,
                         TILE_HEIGHT,
                         Gosu::Color.rgba(91, 110, 225, 255))
        end
      end
    end

    @player.draw
    @humans&.each(&:draw)

    @font.draw_text(@score.to_s, 5, 0, 0)
    t_w = @font.text_width(@score.to_s)
    @lives.times do |i|
      i += 1
      @live_sprite.draw(40 * i + t_w, 0, 0)
    end

    Gosu.draw_rect(@transition_x, 0, @transition_w, THARWindow::HEIGHT, Gosu::Color::BLACK)
  end
end
