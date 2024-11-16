# Simple monkeypatch to make MRuby's rand support Ranges
module RandomExtension
  # @param max [Numeric, Range]
  # @return [Integer, Float]
  def rand(max = 0)
    if max.is_a? Range
      super(max.max - max.min) + max.min
    else
      super(max)
    end
  end
end
