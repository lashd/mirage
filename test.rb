$LOAD_PATH.unshift("/home/team/Projects/mirage/lib")
require 'rubygems'
require 'mirage/client'

Dir.chdir "/home/team/Projects/mirage/scratch" do
  Mirage.stop :port => 9001
  Mirage.start :port => 9001, :defaults => './custom_responses_location'
end
