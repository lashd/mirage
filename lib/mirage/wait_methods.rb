module Mirage

  class TimeoutException < Exception
  end


  # module WaitMethods - contains methods for waiting
  module WaitMethods
    # Wait until a the supplied block returns true
    # @example
    #   wait_until do
    #     (rand % 2) == 0
    #   end
    def wait_until(opts = {})
      opts = {timeout_after: 5, retry_every: 0.1}.merge(opts)
      start_time = Time.now
      until Time.now > start_time + opts[:timeout_after]
        return true if yield == true
        sleep opts[:retry_every]
      end
      fail TimeoutException, 'Action took to long'
    end
  end
end
