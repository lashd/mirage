module Mirage
  # module WaitMethods - contains methods for waiting
  module WaitMethods
    # Wait until a the supplied block returns true
    # @example
    #   wait_until do
    #     (rand % 2) == 0
    #   end
    def wait_until(timeout_after: 5, retry_every: 1, &_block)
      start_time = Time.now
      until Time.now > start_time + timeout_after
        return true if yield == true
        sleep retry_every
      end
      fail TimeoutException, 'Action took to long'
    end
  end
end
