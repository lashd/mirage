Gem::Specification.new do |s|
  s.name = 'mirage'
  s.version = '1.0'
  s.authors = ["Leon Davis"]
  s.description = 'Mirage is a stub server for stubbing out an applications endpoints to aid testing'
  s.summary = "mirage-#{s.version}"

  s.platform = Gem::Platform::RUBY
  s.default_executable = "mirage"
  s.post_install_message = %{
===============================================================================
Thanks you for installing mirage-#{s.version}.
===============================================================================
}

  s.add_dependency 'rack', "~> 1.1.0"
  s.add_dependency 'ramaze', ">= 2011.01.30"
  s.add_dependency "mechanize", ">= 1.0.0"
  s.add_dependency "bundler"


  s.add_development_dependency 'rake'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rspec'

  s.rubygems_version = "1.3.7"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- features/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = "lib"
end
