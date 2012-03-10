class Numeric
  # Convert the number to a +Money+ object.
  #
  #   100.to_money      #=> 100.00
  #
  # Takes an optional precision, which defaults to 2
  # Takes an optional round_mode which defaults to :half_up
  def to_money(precision = nil, round_mode = nil)
    Money.new self, precision, round_mode
  end
end

class Float
  # Convert the float to a +Money+ object.
  #
  #   3.75.to_money     #=> 3.75
  #
  # Takes an optional precision, which defaults to 2
  # Takes an optional round_mode which defaults to :half_up
  def to_money(precision = nil, round_mode = nil)
    Money.new self, precision, round_mode
  end
end

class String
  # Convert the String to a +Money+ object.
  #
  #   '100'.to_money        #=> 100.00
  #   '100.37'.to_money     #=> 100.37
  #   '.37'.to_money        #=> 0.37
  #   '$ 4.25'.to_money     #=> 4.25
  #   '3,550.55'.to_money   #=> 3550.55
  #
  # Takes an optional precision, which defaults to 2
  # Takes an optional round_mode which defaults to :half_up
  def to_money(precision = nil, round_mode = nil)
    Money.new self, precision, round_mode
  end
end
