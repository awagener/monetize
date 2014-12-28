# encoding: utf-8

require "spec_helper"
require "monetize"

describe Monetize do

  let(:usd) { Money::Currency.wrap("USD") }
  let(:eur) { Money::Currency.wrap("EUR") }
  let(:jpy) { Money::Currency.wrap("JPY") }
  let(:gbp) { Money::Currency.wrap("GBP") }
  let(:tnd) { Money::Currency.wrap("TND") }

  it "correctly treats pipe marks '|' in input (regression test)" do
    expect(Monetize.extract_cents('100|0')).to eq Monetize.extract_cents('100!0')
  end

  it "raises an error when too many delimiters are used" do
    expect { Monetize.extract_cents("100,000.000-00") }.to raise_error(ArgumentError)
  end

  it "raises an error when too many delimiters are used" do
    expect { Monetize.extract_cents("100,000.000'00") }.to raise_error(ArgumentError)
  end

  it "defaults to USD" do
    expect(Monetize.extract_cents("20")).to eq Monetize.extract_cents("20", usd)
  end

  it "handles cents" do
    expect(Monetize.extract_cents("10.10 USD")).to eq 1010
  end

  it "handles dollars without cents" do
    expect(Monetize.extract_cents("20")).to eq 2000
  end

  it "extracts numbers from mixed strings" do
    expect(Monetize.extract_cents("hello 2000 world")).to eq 200000
  end

  it "extracts multiple numbers from mixed strings" do
    expect(Monetize.extract_cents("10 print 20 goto")).to eq 102000
  end

  it "accepts ',' as decimal mark" do
    expect(Monetize.extract_cents("100,37")).to eq 10037
  end

  it "accepts ' ' as thousands delimiter" do
    expect(Monetize.extract_cents("100 000")).to eq 10000000
  end

  it "accepts thousands and decimal delimiters together" do
    expect(Monetize.extract_cents("100,000.00")).to eq 10000000
  end
  
  context "it rounds numbers with excess decimal places" do
    it "up for 5 or greater" do
      expect(Monetize.extract_cents("1,000.505")).to eq 100051
    end
  
    it "down for less than 5" do
      expect(Monetize.extract_cents("1,000.504")).to eq 100050
    end
   
    it "with thousands and decimal marks" do
      expect(Monetize.extract_cents("1,000.5000")).to eq 100050
    end
  end

  it "handles a decimal mark without decimal places" do
    expect(Monetize.extract_cents("25.")).to eq 2500
  end

  it "handles a string without dollars" do
    expect(Monetize.extract_cents(".75")).to eq 75
  end

  it "handles other currencies" do
    expect(Monetize.extract_cents("100 EUR", eur)).to eq 10000
  end

  it "handles european currency formatting" do
    expect(Monetize.extract_cents("100.000,00 EUR", eur)).to eq 10000000
  end

  it "handles currency symbols" do
    expect(Monetize.extract_cents("$1,194.59 USD")).to eq 119459
  end
 
  context "handles negative symbols" do
    it "without a currency symbol" do
      expect(Monetize.extract_cents("-1,000")).to eq -100000
    end

    it "after the currency symbol" do
      expect(Monetize.extract_cents("$-1,955 USD")).to eq -195500
    end

    it "before the currency symbol" do
      expect(Monetize.extract_cents("-$1,955 USD")).to eq -195500
    end

    it "after the value" do
      expect(Monetize.extract_cents("$5.95-")).to eq -595
    end
  end

  context "handles currencies with differing decimal places:" do
    it "two" do
      expect(Monetize.extract_cents("1", usd)).to eq 100
    end

    it "three" do
      expect(Monetize.extract_cents("1", tnd)).to eq 1000
    end

    it "none" do
      expect(Monetize.extract_cents("1", jpy)).to eq 1
    end
  end

  it "handles large numbers" do
    expect(Monetize.extract_cents("1,111,234,567.89")).to eq 111123456789
  end

  it "treats an empty string as zero" do
    expect(Monetize.extract_cents("")).to eq 0
  end

  it "treats a string with no numbers as zero" do
    expect(Monetize.extract_cents("hellothere")).to eq 0
  end

  # TODO ascertain these are desired:
  it "a string with '-' anywhere before it is negative" do
    expect(Monetize.extract_cents("- hello 1,000")).to eq -100000
  end

  it "a string with '-' anywhere after it is negative" do
    expect(Monetize.extract_cents(" hello 1,000 how are you? -")).to eq -100000
  end

  it "a string with a '-' and a negative symbol is invalid" do
    expect { Monetize.extract_cents("yes-hello -1,000") }.to raise_error(ArgumentError)
  end

  it "ignores currencies within the string" do
    expect(Monetize.extract_cents("10.10 USD")).to eq Monetize.extract_cents("10.10", gbp)
  end
end
