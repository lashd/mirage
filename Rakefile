$LOAD_PATH.unshift('lib')
require 'bundler/setup'

Bundler.setup(:default, :development)
Bundler.require(:test, :development)

Dir["#{File.dirname(__FILE__)}/tasks/**/*.rake"].each do |tasks|
  import tasks
end

task :default => [:specs, :install, :features, :clean]