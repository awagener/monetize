require "monetize/money_string"
require "monetize/delimiters"

class ToCents
  attr_reader :input, :currency

  def self.convert(input, currency = Money.default_currency)
    new(input, currency).cents_value
  end

  def initialize(input, currency)
    @input = MoneyString.new(input)
    @currency = currency
  end

  def absolute_cents_value
    major + minor
  end

  def cents_value
    negative? ? absolute_cents_value * -1 : absolute_cents_value
  end

  def negative?
    input.negative?
  end

  def major
    integer_part.to_i * currency.subunit_to_unit
  end

  def insufficient_decimal_places(num)
    num.size < currency.decimal_places
  end

  def excess_decimal_places(num)
    num.size > currency.decimal_places
  end

  def pad_decimal_places(num)
    (num + ("0" * currency.decimal_places))[0,currency.decimal_places].to_i
  end

  def round_if_necessary(num)
    if num[currency.decimal_places,1].to_i >= 5
      num[0,currency.decimal_places].to_i+1
    else
      num[0,currency.decimal_places].to_i
    end
  end

  def minor
    minor = fractional_part
    if insufficient_decimal_places(minor)
      pad_decimal_places(minor)
    elsif excess_decimal_places(minor)
      round_if_necessary(minor)
    else
      minor.to_i
    end
  end

  private

  def delimiter_processing_scheme
    @dps ||= Delimiters.new(@input.absolute_number).
                        processing_scheme.new(input, currency)
  end

  def integer_part
    delimiter_processing_scheme.integer_part
  end

  def fractional_part
    delimiter_processing_scheme.fractional_part
  end
end
