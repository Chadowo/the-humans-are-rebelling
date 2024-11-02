$: << File.dirname(File.realpath(__FILE__))

require 'gosu' unless RUBY_ENGINE == 'mruby'

require 'exts/fsm'
require 'exts/state'
require 'exts/resizer'

require 'states/game'

# The Humans Are Rebelling window
class THARWindow < Gosu::Window
  WIDTH = 854
  HEIGHT = 480

  def initialize
    super(WIDTH, HEIGHT, resizable: true)
    self.caption = 'The Humans Are Rebelling!'

    @dt = 0.0
    @last_ms = 0.0

    @fsm = FSM.new(self)
    @fsm.add(:start, StateStart.new)
    @fsm.add(:menu, StateMenu.new)
    @fsm.add(:game, StateGame.new)

    @fsm.go(:game)

    @resizer = Resizer.new(WIDTH, HEIGHT)
  end

  def update
    update_delta

    @fsm.update(@dt)
    @resizer.update(self.width, self.height)
  end

  def update_delta
    current_time = Gosu.milliseconds / 1000.0
    @dt = [current_time - @last_ms, 0.25].min
    @last_ms = current_time
  end

  def draw
    Gosu.translate(@resizer.off_x, @resizer.off_y) do
      Gosu.scale(@resizer.scale_w, @resizer.scale_h, 0.5, 0.5) do
        @fsm.draw
      end
    end
  end
end

THARWindow.new.show
