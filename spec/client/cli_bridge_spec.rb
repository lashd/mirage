require 'spec_helper'
require 'mirage/client'

describe Mirage::CLIBridge do


  before :each do
    @bridge = Object.new
    @bridge.extend(Mirage::CLIBridge)
  end

  describe 'Windows' do

    include_context :windows

    it 'should find the pids of mirage instances for given ports' do

      tasklist_output = "#{process_string_for_mirage(7001, 18903)}
      #{process_string_for_mirage(7002, 18904)}
      #{process_string_for_mirage(7003, 18905)}"

      @bridge.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(tasklist_output)
      @bridge.mirage_process_ids([7001, 7002]).should == {"7001" => "18903", "7002" => "18904"}
    end

    it 'should find the pids of mirage instances for all ports' do
      tasklist_output = "#{process_string_for_mirage(7001, 18903)}
      #{process_string_for_mirage(7002, 18904)}
      #{process_string_for_mirage(7003, 18905)}"

      @bridge.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(tasklist_output)
      @bridge.mirage_process_ids([:all]).should == {"7001" => "18903", "7002" => "18904", "7003" => "18905"}
    end

    it 'should kill the given process id' do
      @bridge.should_receive(:`).with(/taskkill \/F \/T \/PID 18903/)
      @bridge.kill(18903)
    end
  end

  describe 'Linux/MacOSX' do

    include_context :linux

    it 'should find the pids of mirage instances for given ports' do
      ps_aux_output = "#{process_string_for_mirage(7001, 18903)}
      #{process_string_for_mirage(7002, 18904)}
      #{process_string_for_mirage(7003, 18905)}"

      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      @bridge.mirage_process_ids([7001, 7002]).should == {"7001" => "18903", "7002" => "18904"}
    end

    it 'should find the pids of mirage instances for all ports' do
      ps_aux_output = "#{process_string_for_mirage(7001, 18903)}
      #{process_string_for_mirage(7002, 18904)}
      #{process_string_for_mirage(7003, 18905)}"

      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      @bridge.mirage_process_ids([:all]).should == {"7001" => "18903", "7002" => "18904", "7003" => "18905"}
    end

    it 'should kill the given process id' do
      @bridge.should_receive(:`).with(/kill -9 18903/)
      @bridge.kill(18903)
    end
  end
end