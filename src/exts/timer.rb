# A timer can be used to do something after some time has passed or
# do something periodically. This class uses the delta time between
# frames, so you must update the timer in your loop.
class Timer
  attr_accessor :time

  # Create a new timer.
  # @param time [Integer] The max time.
  # @param periodic [Boolean] Whether the timer should reset when done.
  # @param action [Lambda] The code to call when done.
  # @return [Timer]
  def initialize(time, periodic = false, action = nil)
    @time = time
    @current_time = 0.0

    @periodic = periodic
    @action = action
  end

  # After certain time has passed.
  # @param time [Integer]
  # @param action [Lambda]
  # @return [Timer]
  def self.after(time, action)
    Timer.new(time, false, action)
  end

  # Every time
  # @param time [Integer]
  # @param action [lambda]
  # @return [Timer]
  def self.every(time, action)
    Timer.new(time, true, action)
  end

  # Update the timer
  # @param dt [Float] The delta time.
  # @return [void]
  def update(dt)
    if @current_time >= @time
      @action&.call
      reset if @periodic
    end

    @current_time += dt
  end

  # Reset the timer
  # @return [Void]
  def reset
    @current_time = 0.0
  end

  # Is this timer done?
  # @return [Boolean]
  def done?
    true if @current_time >= @time
  end
end
