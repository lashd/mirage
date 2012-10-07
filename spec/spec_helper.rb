ROOT_DIR = "#{File.dirname(__FILE__)}/.."
$LOAD_PATH.unshift "#{ROOT_DIR}/lib"
$LOAD_PATH.unshift "#{ROOT_DIR}/server"

require 'simplecov' if ENV['coverage']
require 'rspec'

shared_context :windows do
  def process_string_for_mirage(mirage_port, pid)
    %Q{ruby.exe                      #{pid} Console                    1      6,076 K Running         WIN-ATPGMMC0218\\\\leon        0:01:58 mirage server port #{mirage_port}}
  end

  before :each do
    ChildProcess.should_receive(:windows?).any_number_of_times.and_return(true)
  end
end

shared_context :linux do
  def process_string_for_mirage(mirage_port, pid)
    "team     #{pid}  6.2  0.4  84328 20760 pts/1    Sl   22:15   0:00 Mirage Server port #{mirage_port}"
  end

  before :each do
    ChildProcess.should_receive(:windows?).any_number_of_times.and_return(false)
  end
end
shared_context :resources do
  let(:resources_dir){"#{File.dirname(__FILE__)}/resources"}
end

shared_context :rack_test do |options|
  options = {:disable_sinatra_error_handling => false}.merge(options||{})
  require 'sinatra'
  require 'app'
  require 'rack/test'
  include Rack::Test::Methods

  def app
    @app_expectations ||= proc{}
    Mirage::Server.new do |app|
      @app_expectations.call app
    end
  end

  def application_expectations &block
    @app_expectations = proc do |app|
      app.stub(:dup).and_return(app)
      block.call app
    end
  end

  if options[:disable_sinatra_error_handling]
    module Mirage
      class Server < Sinatra::Base
        configure do
          set :show_exceptions, false
        end
      end
    end

    module Sinatra
      class Base
        def handle_exception! boom
          raise boom
        end
      end
    end
  end
end

