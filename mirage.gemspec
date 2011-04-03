Gem::Specification.new do |s|

  windows = ENV['OS'] == 'Windows_NT'
  s.name = 'mirage'
  s.version = '1.2.0'
  s.authors = ["Leon Davis"]
  s.homepage = 'https://github.com/lashd/mirage'
  s.description = 'Mirage aids testing of your applications by hosting mock responses so that your applications do not have to talk to real endpoints. Its accessible via HTTP and has a RESTful interface.'
  s.summary = "mirage-#{s.version}"

  s.platform = Gem::Platform::RUBY
  s.default_executable = "mirage"
  s.post_install_message = %{
===============================================================================
Thanks you for installing mirage-#{s.version}.   

Run Mirage with:

mirage start                                   

For more information go to: https://github.com/lashd/mirage/wiki
===============================================================================
}
  
  s.has_rdoc = 'true' 

  s.add_dependency 'rack', "~> 1.1.0"
  s.add_dependency 'ramaze', ">= 2011.01.30"
  s.add_dependency "mechanize", ">= 1.0.0"

  s.add_dependency 'childprocess'
  s.add_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'


  s.add_development_dependency 'rake'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'

  s.rubygems_version = "1.3.7"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- features/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = "lib"
  
  
      
end
