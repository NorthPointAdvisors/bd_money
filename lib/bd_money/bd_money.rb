require 'bigdecimal'

class Money

  ROUND_MODES = {
    :ceiling   => BigDecimal::ROUND_CEILING,
    :down      => BigDecimal::ROUND_DOWN,
    :floor     => BigDecimal::ROUND_FLOOR,
    :half_down => BigDecimal::ROUND_HALF_DOWN,
    :half_even => BigDecimal::ROUND_HALF_EVEN,
    :half_up   => BigDecimal::ROUND_HALF_UP,
    :up        => BigDecimal::ROUND_UP,
  } unless const_defined?(:ROUND_MODES)

  FORMATS = {
    :default   => { :unit => "$", :spacer => " ", :delimiter => ",", :separator => ".", :precision => 2 },
    :no_cents  => { :unit => "$", :spacer => " ", :delimiter => ",", :separator => ".", :precision => 0 },
    :no_commas => { :unit => "$", :spacer => " ", :delimiter => "", :separator => ".", :precision => 2 },
  } unless const_defined?(:FORMATS)

  REMOVE_RE = %r{[$,_ ]} unless const_defined?(:REMOVE_RE)
  VALID_RE = %r{^(-)?(\d)+(\.\d{1,12})?$} unless const_defined?(:VALID_RE)

  include Comparable

  class MoneyError < StandardError # :nodoc:
  end

  def initialize(value, precision = nil, round_mode = nil, format = nil)
    self.amount = value
    self.precision = precision if precision
    self.round_mode = round_mode if round_mode
    self.format = format if format
  end

  def amount=(value)
    if value.is_a?(BigDecimal)
      @amount = value
    else
      str = self.class.clean value
      raise MoneyError, "Invalid value [#{str}] (#{value.class.name})" unless self.class.valid?(str)
      @amount = BigDecimal.new str.gsub REMOVE_RE, ''
    end
  end

  def amount
    @amount
  end

  def precision=(value)
    raise "Unknown precision [#{value}]" unless value.is_a?(Integer)
    @precision = value
  end

  def precision
    @precision || self.class.precision
  end

  def round_mode=(value)
    raise "Unknown rounding mode [#{value}]" unless ROUND_MODES.key?(value)
    @round_mode = value
  end

  def round_mode
    @round_mode || self.class.round_mode
  end

  def format=(value)
    raise "Unknown format options [#{value}]" unless FORMATS.key?(value)
    @format = value
  end

  def format
    @format || self.class.format
  end

  def convert(value)
    self.class.convert value
  end

  def eql?(other)
    amount == convert(other).amount
  end

  def <=>(other)
    amount <=> convert(other).amount
  end

  def +(other)
    convert amount + convert(other).amount
  end

  def -(other)
    convert amount - convert(other).amount
  end

  def *(other)
    convert amount * convert(other).amount
  end

  def /(other)
    convert amount / convert(other).amount
  end

  def **(other)
    convert amount ** convert(other).amount.to_i
  end

  def %(other)
    convert amount % convert(other).amount
  end

  def ^(other)
    convert amount ^ convert(other).amount
  end

  def to_credit
    convert amount.abs
  end

  def to_credit!
    self.amount = amount.abs
    self
  end

  def credit?
    amount >= 0
  end

  def to_debit
    convert amount.abs * -1
  end

  def to_debit!
    self.amount = amount.abs * -1
    self
  end

  def debit?
    amount < 0
  end

  def zero?
    amount == 0
  end

  def round_amount(this_precision = precision, this_round_mode = round_mode)
    this_round_mode = BigDecimal.const_get("ROUND_#{this_round_mode.to_s.upcase}") if this_round_mode.is_a?(Symbol)
    amount.round this_precision, this_round_mode
  end

  def round(this_precision = precision, this_round_mode = round_mode)
    convert round_amount(this_precision, this_round_mode)
  end

  def to_i(this_round_mode = round_mode)
    round_amount(0, this_round_mode).to_i
  end

  def to_f(this_precision = precision, this_round_mode = round_mode)
    round_amount(this_precision, this_round_mode).to_f
  end

  def to_s(this_precision = precision, this_round_mode = round_mode)
    amount_str     = round_amount(this_precision, this_round_mode).to_s('F')
    dollars, cents = amount_str.split('.')
    return dollars if this_precision == 0
    if cents.size >= this_precision
      "#{dollars}.#{cents[0, this_precision]}"
    else
      "#{dollars}.#{cents}#{'0' * (this_precision - cents.size)}"
    end
  end

  alias :inspect :to_s

  def formatted(*args)
    defaults = args.first.is_a?(::Symbol) ? FORMATS[args.shift] : FORMATS[:default]
    options = args.last.is_a?(::Hash) ? args.pop : { }

    unit      = options[:unit] || defaults[:unit]
    spacer    = options[:spacer] || defaults[:spacer]
    delimiter = options[:delimiter] || defaults[:delimiter]
    separator = options[:separator] || defaults[:separator]
    precision = options[:precision] || defaults[:precision]
    separator = '' if precision == 0

    number = to_s precision
    begin
      parts = number.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      number = parts.join(separator)
      "#{unit}#{spacer}#{number}"
    rescue
      number
    end
  end

  def respond_to?(meth)
    amount.respond_to?(meth) || super
  end

  def method_missing(meth, *args, &blk)
    if amount.respond_to? meth
      result = amount.send meth, *args, &blk
      result.is_a?(::BigDecimal) ? convert(result) : result
    else
      super
    end
  end

  class << self

    def precision=(value)
      raise "Unknown precision [#{value}]" unless value.is_a?(Integer)
      @precision = value
    end

    def precision
      @precision || 2
    end

    def round_mode=(value)
      raise "Unknown rounding mode [#{value}]" unless ROUND_MODES.key?(value)
      @round_mode = value
    end

    def round_mode
      @round_mode || :half_up
    end

    def format=(value)
      raise "Unknown format options [#{value}]" unless FORMATS.key?(value)
      @format = value
    end

    def format
      @format || :default
    end

    def convert(value)
      return value if value.is_a?(Money)
      new value
    end

    def clean(value)
      value.to_s.gsub REMOVE_RE, ''
    end

    def valid?(value)
      !!value.to_s.match(VALID_RE)
    end

  end

end