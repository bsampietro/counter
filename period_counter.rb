class PeriodCounter
  # duration: an integer representing the number of passed seconds,
  #   or any of: :hourly, :daily, :monthly, :yearly
  # context: any string that uniquely identifys different counters
  # cache: any key value store that has read and write methods
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
      if @init_time && @duration > time_now - @init_time
        @count += 1
      else
        @count = 1
        @init_time = time_now
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


  private

  def time_now
    current_time = Time.now
    case @duration
      when Symbol
        case @duration
          when :hourly then current_time.hour
          when :daily then current_time.day
          when :monthly then current_time.month
          when :yearly then current_time.year
          else
            raise "Not supported duration"
        end
      when Integer
        current_time
      else
        raise "Not supported duration type"
    end
  end
end
