class Mirage
  module Util
    def wait_until time=30
      start_time = Time.now
      until Time.now >= start_time + time
        sleep 0.1
        return if yield
      end
      raise 'timeout waiting'
    end
  end

end