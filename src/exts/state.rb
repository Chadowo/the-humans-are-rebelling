class State
  attr_reader :fsm

  def initialize; end

  def update(dt); end

  def draw; end

  def enter(from); end

  def leave(to); end

  def activate(fsm)
    @fsm = fsm
  end

  def destroy; end
end
