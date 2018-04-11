require 'spec_helper'
require 'mirage/client'


describe Mirage do

  describe 'starting' do
    before(:each) do
      @runner = double
      Runner.should_receive(:new).and_return(@runner)
    end

    it 'should start Mirage on port 7001 by default' do
      @runner.should_receive(:invoke).with(:start, [], {:port => 7001})
      client = Mirage.start
      client.should == Mirage::Client.new
    end

    it 'should start mirage on the given port' do
      options = {:port => 9001}
      @runner.should_receive(:invoke).with(:start, [], options)
      Mirage.start options
    end
  end

  describe 'stopping' do
    before(:each) do
      @runner = double
      Runner.stub(:new).and_return(@runner)
    end

    it 'should supply single port argument in an array to the runner' do
      port = 7001
      @runner.should_receive(:invoke).with(:stop, [], :port => [port])
      @runner.should_receive(:invoke).with(:stop, [], :port => [:all])
      Mirage.stop(:port => port)
      Mirage.stop(:all)
    end

    it 'should stop multiple instances of Mirage' do
      ports = 7001, 7002
      @runner.should_receive(:invoke).with(:stop, [], :port => ports)
      Mirage.stop(:port => ports)
    end
  end

  describe '.running?' do
    before(:each) do
      HTTParty.stub(:get)
    end

    it 'should check running app if you do not pass params' do
      url = 'http://localhost:7001'
      HTTParty.should_receive(:get).with(url).and_return(true)
      Mirage.running?
    end

    it 'should check running app if you pass url as string' do
      url = 'http://my.url:9000'
      HTTParty.should_receive(:get).with(url).and_return(true)
      Mirage.running?(url)
    end

    it 'should check running app if you pass url in hash' do
      url = 'http://my.url:9000'
      HTTParty.should_receive(:get).with(url).and_return(true)
      Mirage.running?({:url => url})
    end

    it 'should check running app if you pass port in hash' do
      url = 'http://localhost:1234'
      port = 1234
      HTTParty.should_receive(:get).with(url).and_return(true)
      Mirage.running?({:port => port})
    end
  end

  describe Mirage::Runner do
    it 'should stop the running instance of Mirage' do
      options = {:port => []}
      runner = Mirage::Runner.new
      runner.options = options

      runner.stub(:mirage_process_ids).with([]).and_return({"7001" => "18901"})


      runner.should_receive(:kill).with("18901") do
        RSpec.reset
        runner.stub(:mirage_process_ids).with([]).and_return({})
      end

      Mirage::Runner.should_receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should not stop any instances when more than one is running' do
      options = {:port => []}
      runner = Mirage::Runner.new
      runner.options = options

      runner.stub(:mirage_process_ids).with([]).and_return({"7001" => "18901", "7002" => "18902", "7003" => "18903"})
      runner.should_not_receive(:kill)
      Mirage::Runner.should_receive(:new).and_return(runner)

      expect{ runner.invoke(:stop, [], options) }.to raise_error(Mirage::ClientError)
    end


    it 'should stop the instance running on the given port' do
      options = {:port => [7001]}
      runner = Mirage::Runner.new
      runner.options = options

      runner.should_receive(:mirage_process_ids).with([7001]).and_return({"7001" => "18901"})
      runner.should_receive(:kill).with("18901") do
        RSpec.reset
        runner.stub(:mirage_process_ids).with([7001]).and_return({})
      end

      Mirage::Runner.should_receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should stop the instance running on the given ports' do
      options = {:port => [7001, 7002]}
      runner = Mirage::Runner.new
      runner.options = options

      runner.should_receive(:mirage_process_ids).with([7001, 7002]).and_return({"7001" => "18901", "7002" => "18902"})
      runner.should_receive(:kill).with("18901")
      runner.should_receive(:kill).with("18902") do
        RSpec.reset
        runner.stub(:mirage_process_ids).with([7001, 7002]).and_return({})
      end

      Mirage::Runner.should_receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should stop all running instances' do
      options = {:port => [:all]}
      runner = Mirage::Runner.new
      runner.options = options

      runner.should_receive(:mirage_process_ids).with([:all]).and_return({"7001" => "18901", "7002" => "18902"})
      runner.should_receive(:kill).with("18901")
      runner.should_receive(:kill).with("18902") do
        RSpec.reset
        runner.stub(:mirage_process_ids).with([:all]).and_return({})
      end

      Mirage::Runner.should_receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)

    end

    it 'should not error when asked to stop Mirage on a port that it is not running on' do
      options = {:port => [7001]}
      runner = Mirage::Runner.new
      runner.options = options
      runner.stub(:mirage_process_ids).with([7001]).and_return({})

      Mirage::Runner.should_receive(:new).and_return(runner)
      expect { runner.invoke(:stop, [], options) }.not_to raise_error
    end
  end
end