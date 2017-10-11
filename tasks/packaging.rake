task :clean do |task|
  if system "gem list -i mirage"
    puts "cleaning"
    system "gem uninstall -x mirage"
  end
  Dir['*.gem'].each { |gem| FileUtils.rm_f(gem) }
  task.reenable
end

Jeweler::Tasks.new do |gem|
  gem.name = "mirage"
  gem.homepage = "https://github.com/lashd/mirage"
  gem.license = "MIT"
  gem.summary = "Mirage is a easy mock server for testing your applications"
  gem.description = 'Mirage aids testing of your applications by hosting mock responses so that your applications do not have to talk to real endpoints. Its accessible via HTTP and has a RESTful interface.'
  gem.authors = ["Leon Davis"]
  gem.files = Dir.glob(%w(mirage_server.rb lib/**/*.rb bin/* server/**/*.rb views/**/*.*))
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