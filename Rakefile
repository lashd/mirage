$LOAD_PATH.unshift('lib')
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rspec/core/rake_task'

task :specs

%w(client server).each do |type|
  public_task_name = "#{type}_specs"
  private_task_name = "_#{public_task_name}"

  RSpec::Core::RakeTask.new(private_task_name) do |task|
    task.pattern = "spec/#{type}/**/*_spec.rb"
  end

  desc "specs for: #{type}"
  task public_task_name do
    ENV['coverage'] = type
    Rake::Task[private_task_name].invoke
  end

  Rake::Task["specs"].prerequisites << public_task_name
end


require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "mirage"
  gem.homepage = "https://github.com/lashd/mirage"
  gem.license = "MIT"
  gem.summary = "Mirage is a easy mock server for testing your applications"
  gem.description = 'Mirage aids testing of your applications by hosting mock responses so that your applications do not have to talk to real endpoints. Its accessible via HTTP and has a RESTful interface.'
  gem.authors = ["Leon Davis"]
  gem.executables = ['mirage']
  gem.post_install_message = %{
===============================================================================
Mirage v3:

Mirage has just gone up a major version from 2 to 3. If your project uses
a previous version take a look at https://github.com/lashd/mirage to see
what's changed
===============================================================================
}
end
Jeweler::RubygemsDotOrgTasks.new


require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "mode=regression features --format pretty"
end

task :clean do |task|
  if system "gem list -i mirage"
    puts "cleaning"
    system "gem uninstall -x mirage"
  end
  Dir['*.gem'].each { |gem| FileUtils.rm_f(gem) }
  task.reenable
end

task :start do
  `RACK_ENV='development' && ruby ./bin/mirage start`
end

task :stop do
  `RACK_ENV='development' && ruby ./bin/mirage stop`
end

task :default => [:specs, :install, :features, :clean]
