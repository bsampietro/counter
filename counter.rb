class Counter
  # duration: an integer representing the number of passed seconds,
  #   or any of: :hourly, :daily, :monthly, :yearly
  # context: any string that identifys different counters
  # cache: any store that has read and write methods
  def initialize(duration, context, cache)
    @duration = duration
    @cache = cache

    @count_key = "counter/count/#{duration.to_s}/#{context}"
    @init_time_key = "counter/time/#{duration.to_s}/#{context}"

    @count = @cache.read(@count_key) || 0
    @init_time = @cache.read(@init_time_key)
  end

  def add
    case @duration
    when Symbol
      if @init_time == time_now
        @count += 1
      else
        @count = 1
        @init_time = time_now
        @cache.write(@init_time_key, @init_time)
      end
    when Integer
      if @init_time && @duration > Time.now - @init_time
        @count += 1
      else
        @count = 1
        @init_time = Time.now
        @cache.write(@init_time_key, @init_time)
      end
    else
      raise "Not supported duration type"
    end
    @cache.write(@count_key, @count)

    @count
  end

  def count
    @count
  end

  def time_now
    raise "Not supported call" if !@duration.is_a?(Symbol)
    current_time = Time.now
    case @duration
    when :hourly
      current_time.hour
    when :daily
      current_time.day
    when :monthly
      current_time.month
    when :yearly
      current_time.year
    end
  end

end
