require "monetize/delimiter_processing"

class Delimiters
  NON_NUMBERS = /[^\d]/
  attr_accessor :delimiters

  def initialize(string)
    @delimiters = string.scan(NON_NUMBERS)
  end

  def processing_scheme
    case unique_count
    when 0
      NoDelimiters
    when 2
      TwoDelimiters
    when 1
      OneDelimiter
    else
      raise ArgumentError, "Invalid currency amount"
    end
  end

  def first
    delimiters.first
  end

  def unique
    delimiters.uniq
  end

  def unique_count
    unique.length
  end
end
