# Finite State Machine
class FSM
  attr_reader :states, :current_state, :window

  # @param window [Gosu::Window] A refence to the current window.
  def initialize(window)
    @states = {}
    @current_state = nil
    @window = window
  end

  def update(dt)
    return unless @current_state

    @current_state.update(dt)
  end

  def draw
    return unless @current_state

    @current_state.draw
  end

  # Go to the specified State.
  # @param id [Symbol, #to_sym] The ID of the state.
  def go(id)
    state = @states[id.to_sym]

    raise "Invalid State, perhaps the ID is wrong. ID=#{id}" unless state

    @current_state&.leave(state)
    previous = @current_state

    @current_state = state
    @current_state.enter(previous)
  end

  # Add a State.
  # @param id [Symbol, #to_sym] The ID of the new state.
  # @param state [State] Any State based object.
  # @note Use this instead of adding the state to the states array IV.
  def add(id, state)
    return if @states[id]

    @states.store(id, state)
    state.activate(self)
  end

  # Remove a State.
  # @param id [Symbol] The ID of the state.
  # @note Use this instead of removing the state to the states array IV.
  def remove(id)
    state = @states[id]
    return unless state

    if @current_state == state
      @current_state.leave
      @current_state = nil
    end

    state.destroy
    @states.delete(id)
  end

  # Are we in this State?
  # @param id [Symbol] The ID of the State to check for.
  def at?(id)
    @states[id] == @current_state
  end
end
