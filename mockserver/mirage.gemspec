require 'bundler/setup'
require 'rake'
Gem::Specification.new do |s|
  s.name        = 'mirage'
  s.version     = '1.0'
  s.authors     = ["Leon Davis"]
  s.description = 'Mirage is a stub server for stubbing out an applications endpoints to aid testing'
  s.summary     = "mirage-#{s.version}"

  s.platform    = Gem::Platform::RUBY
  s.default_executable = "mirage"
  s.post_install_message = %{
===============================================================================
Thanks you for installing mirage-#{s.version}.
===============================================================================
}

  bundler = Bundler.load

  bundler.dependencies_for(:default).each do |dependency|
    s.add_dependency dependency.name, dependency.requirement.to_s
  end

  bundler.dependencies_for(:test).each do |dependency|
    s.add_development_dependency dependency.name, dependency.requirement.to_s
  end

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- features/*`.split("\n")
  s.require_path     = "lib"
end
