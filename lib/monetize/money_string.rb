class MoneyString
  attr_reader :string
  def initialize(string)
    @string = string
    raise ArgumentError, "Invalid currency amount (hyphen)" if absolute_number.include?('-')
  end

  def absolute_number
    @absolute ||= strip_trailing_characters( strip_negative_symbol(number) )
  end

  def negative?
    number =~ /^-|-$/  ? true : false
  end

  private

  def number
    @number ||= string.gsub(/[^\d.,'-]/, '')
  end

  def strip_negative_symbol(number)
    number.sub(/^-|-$/, '')
  end

  def strip_trailing_characters(number)
    number.gsub(/[\.|,]$/, '')
  end
end
