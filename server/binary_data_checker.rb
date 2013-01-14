require 'ptools'
module Mirage
  module BinaryDataChecker
      class << self
        def contains_binary_data? string
          tmpfile = Tempfile.new("binary_check")
          tmpfile.write(string)
          tmpfile.close
          binary = File.binary?(tmpfile.path)
          FileUtils.rm(tmpfile.path)
          binary
        end
      end
  end
end