task :specs

%w(mirage/client server).each do |type|
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


require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "mode=regression features --format pretty"
end
