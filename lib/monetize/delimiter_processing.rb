class Delimiter
  attr_reader :input, :integer_part, :fractional_part
  def initialize(input, currency = nil)
    @input = input
  end
end

class NoDelimiters < Delimiter
  def integer_part
    input.absolute_number
  end

  def fractional_part
    "0"
  end
end

class TwoDelimiters < Delimiter
  attr_reader :delimiters
  def initialize(input, currency = nil)
    super
    @delimiters = Delimiters.new(input.absolute_number)
    process
  end

  def process
    @integer_part, @fractional_part = 
      input.absolute_number.gsub(thousands_separator, '').split(decimal_mark)
  end

  private
  def thousands_separator
    delimiters.unique.first
  end

  def decimal_mark
    delimiters.unique.last
  end
end

class OneDelimiter < Delimiter
  attr_reader :delimiters, :currency
  def initialize(input, currency)
    super
    @currency = currency
    @delimiters = Delimiters.new(input.absolute_number)
    process
  end

  def absolute_number
    input.absolute_number
  end

  def process
    delimiter = delimiters.first

    if currency.decimal_mark == delimiter
      major, minor = absolute_number.split(currency.decimal_mark)
    elsif absolute_number.scan(delimiter).length > 1
      major, minor = absolute_number.gsub(delimiter, ''), "0"
    else
      possible_major, possible_minor = absolute_number.split(delimiter)
      possible_major ||= "0"
      possible_minor ||= "00"

      if possible_minor.length != 3 # thousands_separator
        major, minor = possible_major, possible_minor
      elsif possible_major.length > 3
        major, minor = possible_major, possible_minor
      elsif delimiter == '.'
        major, minor = possible_major, possible_minor
      else
        major, minor = "#{possible_major}#{possible_minor}", "0"
      end
    end
    @integer_part, @fractional_part = major, minor
  end
end
