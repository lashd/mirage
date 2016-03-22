source 'https://rubygems.org'

gem 'sinatra'
gem 'childprocess'
gem "thor"
gem "ptools"
gem "httparty"
gem "haml"
gem 'hashie'

group :test do
  gem 'cucumber'
  gem 'rspec', require: 'rspec/core/rake_task'
  gem 'rack-test'
  gem 'simplecov', require: false
end

group :development do
  gem 'rake'
  gem "jeweler"
  gem 'sinatra-contrib'

  platform :jruby do
    gem "jruby-openssl"
  end
end
  
