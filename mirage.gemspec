Gem::Specification.new do |s|
  s.name = 'mirage'
  s.version = '0.1.2'
  s.authors = ["Leon Davis"]
  s.homepage = 'https://github.com/lashd/Mirage'
  s.description = 'Mirage is an application for hosting responses to fool your applications into thinking that they are talking to real endpoints whilst you are developing them. Its accessible via HTTP has a RESful interface so is easy to interact with.'
  s.summary = "mirage-#{s.version}"

  s.platform = Gem::Platform::RUBY
  s.default_executable = "mirage"
  s.post_install_message = %{
===============================================================================
Thanks you for installing mirage-#{s.version}.   

Run Mirage with:

mirage start
===============================================================================
}
  
  s.has_rdoc = 'true' 

  s.add_dependency 'rack', "~> 1.1.0"
  s.add_dependency 'ramaze', ">= 2011.01.30"
  s.add_dependency "mechanize", ">= 1.0.0"

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
