require 'minitest/autorun'
require 'debugger'
require File.expand_path("../period_counter", __FILE__)

class Cache
  def initialize
    @store = {}
  end

  def read(key)
    @store[key]
  end

  def write(key, value)
    @store[key] = value
  end
end

describe PeriodCounter do
  # before do
  #   # code
  # end

  # after do
  #   # code
  # end

  let(:cache) { Cache.new }

  describe "symbol periods" do
    it "counts" do
      [:hourly, :daily, :monthly, :yearly].each do |duration|
        counter = PeriodCounter.new(duration, 'something/100', cache)
        counter.add
        counter.add
        counter.count.must_equal 2

        counter = PeriodCounter.new(duration, 'something/100', cache)
        counter.add
        counter.add
        counter.count.must_equal 4
      end
    end

    it "counts differently for different periods" do
      counter = PeriodCounter.new(:hourly, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = PeriodCounter.new(:daily, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end

    it "counts differently for different contexts" do
      counter = PeriodCounter.new(:hourly, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = PeriodCounter.new(:hourly, 'something/200', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end
  end

  describe "numerical periods" do
    it "counts for custom numerical periods" do
      counter = PeriodCounter.new(2, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      sleep 1

      counter = PeriodCounter.new(2, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 4
    end

    it "should expire numerical periods" do
      counter = PeriodCounter.new(1, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      sleep 1

      counter = PeriodCounter.new(1, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end

    it "counts different for different contexts" do
      counter = PeriodCounter.new(5, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = PeriodCounter.new(5, 'something/200', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end
  end
end

