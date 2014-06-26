require 'minitest/autorun'
require 'debugger'
require File.expand_path("../counter", __FILE__)

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

describe Counter do
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
        counter = Counter.new(duration, 'something/100', cache)
        counter.add
        counter.add
        counter.count.must_equal 2

        counter = Counter.new(duration, 'something/100', cache)
        counter.add
        counter.add
        counter.count.must_equal 4
      end
    end

    it "counts differently for different periods" do
      counter = Counter.new(:hourly, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = Counter.new(:daily, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end

    it "counts differently for different contexts" do
      counter = Counter.new(:hourly, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = Counter.new(:hourly, 'something/200', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end
  end

  describe "numerical periods" do
    it "counts for custom numerical periods" do
      counter = Counter.new(2, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      sleep 1

      counter = Counter.new(2, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 4
    end

    it "should expire numerical periods" do
      counter = Counter.new(1, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      sleep 1

      counter = Counter.new(1, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end

    it "counts different for different contexts" do
      counter = Counter.new(5, 'something/100', cache)
      counter.add
      counter.add
      counter.count.must_equal 2

      counter = Counter.new(5, 'something/200', cache)
      counter.add
      counter.add
      counter.count.must_equal 2
    end
  end
end

