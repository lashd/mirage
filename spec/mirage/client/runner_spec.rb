require 'spec_helper'
require 'mirage/client'


describe Mirage do

  describe 'starting' do
    before(:each) do
      @runner = double
      expect(Runner).to receive(:new).and_return(@runner)
    end

    it 'should start Mirage on port 7001 by default' do
      expect(@runner).to receive(:invoke).with(:start, [], {:port => 7001})
      client = Mirage.start
      expect(client).to eq(Mirage::Client.new)
    end

    it 'should start mirage on the given port' do
      options = {:port => 9001}
      expect(@runner).to receive(:invoke).with(:start, [], options)
      Mirage.start options
    end
  end

  describe 'stopping' do
    before(:each) do
      @runner = double
      allow(Runner).to receive(:new).and_return(@runner)
    end

    it 'should supply single port argument in an array to the runner' do
      port = 7001
      expect(@runner).to receive(:invoke).with(:stop, [], :port => [port])
      expect(@runner).to receive(:invoke).with(:stop, [], :port => [:all])
      Mirage.stop(:port => port)
      Mirage.stop(:all)
    end

    it 'should stop multiple instances of Mirage' do
      ports = 7001, 7002
      expect(@runner).to receive(:invoke).with(:stop, [], :port => ports)
      Mirage.stop(:port => ports)
    end

  end

  describe Mirage::Runner do
    it 'should stop the running instance of Mirage' do
      options = {:port => []}
      runner = Mirage::Runner.new
      runner.options = options

      allow(runner).to receive(:mirage_process_ids).with([]).and_return({"7001" => "18901"})


      expect(runner).to receive(:kill).with("18901") do
        RSpec.reset
        allow(runner).to receive(:mirage_process_ids).with([]).and_return({})
      end

      expect(Mirage::Runner).to receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should not stop any instances when more than one is running' do
      options = {:port => []}
      runner = Mirage::Runner.new
      runner.options = options

      allow(runner).to receive(:mirage_process_ids).with([]).and_return({"7001" => "18901", "7002" => "18902", "7003" => "18903"})
      expect(runner).not_to receive(:kill)
      expect(Mirage::Runner).to receive(:new).and_return(runner)

      expect{ runner.invoke(:stop, [], options) }.to raise_error(Mirage::ClientError)
    end


    it 'should stop the instance running on the given port' do
      options = {:port => [7001]}
      runner = Mirage::Runner.new
      runner.options = options

      expect(runner).to receive(:mirage_process_ids).with([7001]).and_return({"7001" => "18901"})
      expect(runner).to receive(:kill).with("18901") do
        RSpec.reset
        allow(runner).to receive(:mirage_process_ids).with([7001]).and_return({})
      end

      expect(Mirage::Runner).to receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should stop the instance running on the given ports' do
      options = {:port => [7001, 7002]}
      runner = Mirage::Runner.new
      runner.options = options

      expect(runner).to receive(:mirage_process_ids).with([7001, 7002]).and_return({"7001" => "18901", "7002" => "18902"})
      expect(runner).to receive(:kill).with("18901")
      expect(runner).to receive(:kill).with("18902") do
        RSpec.reset
        allow(runner).to receive(:mirage_process_ids).with([7001, 7002]).and_return({})
      end

      expect(Mirage::Runner).to receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)
    end

    it 'should stop all running instances' do
      options = {:port => [:all]}
      runner = Mirage::Runner.new
      runner.options = options

      expect(runner).to receive(:mirage_process_ids).with([:all]).and_return({"7001" => "18901", "7002" => "18902"})
      expect(runner).to receive(:kill).with("18901")
      expect(runner).to receive(:kill).with("18902") do
        RSpec.reset
        allow(runner).to receive(:mirage_process_ids).with([:all]).and_return({})
      end

      expect(Mirage::Runner).to receive(:new).and_return(runner)
      runner.invoke(:stop, [], options)

    end

    it 'should not error when asked to stop Mirage on a port that it is not running on' do
      options = {:port => [7001]}
      runner = Mirage::Runner.new
      runner.options = options
      allow(runner).to receive(:mirage_process_ids).with([7001]).and_return({})

      expect(Mirage::Runner).to receive(:new).and_return(runner)
      expect { runner.invoke(:stop, [], options) }.not_to raise_error
    end

  end
end