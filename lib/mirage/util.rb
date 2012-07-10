require 'optparse'
module Mirage
  module Util



    def windows?
      ENV['OS'] == 'Windows_NT'
    end
  end

end