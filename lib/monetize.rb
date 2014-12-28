# encoding: utf-8

require "money"
require "monetize/core_extensions"
require "monetize/version"
require "monetize/to_cents"

module Monetize

  CURRENCY_SYMBOLS = {
    "$"    => "USD",
    "€"    => "EUR",
    "£"    => "GBP",
    "R$"   => "BRL",
    "R"    => "ZAR"
  }

  # Class methods
  class << self
    # @attr_accessor [true, false] assume_from_symbol Use this to enable the
    #   ability to assume the currency from a passed symbol
    attr_accessor :assume_from_symbol
  end

  def self.parse(input, currency = Money.default_currency, options = {})
    input = input.to_s.strip

    computed_currency = if options.fetch(:assume_from_symbol) { assume_from_symbol }
                          compute_currency(input)
                        else
                          input[/[A-Z]{2,3}/]
                        end

    currency = computed_currency || currency || Money.default_currency
    currency = Money::Currency.wrap(currency)

    fractional = extract_cents(input, currency)

    Money.new(fractional, currency)
  end

  def self.from_string(value, currency = Money.default_currency)
    value = BigDecimal.new(value.to_s)
    from_bigdecimal(value, currency)
  end

  def self.from_fixnum(value, currency = Money.default_currency)
    currency = Money::Currency.wrap(currency)
    value = value * currency.subunit_to_unit
    Money.new(value, currency)
  end

  def self.from_float(value, currency = Money.default_currency)
    value = BigDecimal.new(value.to_s)
    from_bigdecimal(value, currency)
  end

  def self.from_bigdecimal(value, currency = Money.default_currency)
    currency = Money::Currency.wrap(currency)
    value = value * currency.subunit_to_unit
    value = value.round unless Money.infinite_precision
    Money.new(value, currency)
  end

  def self.from_numeric(value, currency = Money.default_currency)
    case value
    when Fixnum
      from_fixnum(value, currency)
    when Numeric
      value = BigDecimal.new(value.to_s)
      from_bigdecimal(value, currency)
    else
      raise ArgumentError, "'value' should be a type of Numeric"
    end
  end

  def self.extract_cents(input, currency = Money.default_currency)
    ToCents.convert(input, currency)
  end

  private

  def self.contains_currency_symbol?(amount)
    currency_symbol_regex === amount
  end

  def self.compute_currency(amount)
    if contains_currency_symbol?(amount)
      matches = amount.match(currency_symbol_regex)
      CURRENCY_SYMBOLS[matches[:symbol]]
    else
      amount[/[A-Z]{2,3}/]
    end
  end

  def self.regex_safe_symbols
    CURRENCY_SYMBOLS.keys.map { |key|
      Regexp.escape(key)
    }.join('|')
  end

  def self.currency_symbol_regex
    /\A[\+|\-]?(?<symbol>#{regex_safe_symbols})/
  end
end
