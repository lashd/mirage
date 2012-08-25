$LOAD_PATH.unshift "../lib"
require 'rspec'
require 'mirage/client'

if ChildProcess.windows?


  def process_string_for_mirage(mirage_port, pid)
    %Q{ruby.exe                      #{pid} Console                    1      6,076 K Running         WIN-ATPGMMC0218\\\\leon        0:01:58 mirage server port #{mirage_port}}
  end

  include Mirage

  describe Mirage do

    describe 'starting' do
      before(:each) do
        @runner = mock
        Runner.should_receive(:new).and_return(@runner)
      end

      it 'should start Mirage on port 7001 by default' do
        @runner.should_receive(:invoke).with(:start, [], {:port => 7001})
        Mirage.start
      end

      it 'should start mirage on the given port' do
        options = {:port => 9001}
        @runner.should_receive(:invoke).with(:start, [], options)
        Mirage.start options
      end
    end

    describe 'stopping' do
      before(:each) do
        @runner = mock
        Runner.stub(:new).and_return(@runner)
      end

      it 'should supply single port argument in an array to the runner' do
        port = 7001
        @runner.should_receive(:invoke).with(:stop, [], :port => [port])
        @runner.should_receive(:invoke).with(:stop, [], :port => [:all])
        Mirage.stop(:port => port)
        Mirage.stop(:port => :all)
      end

      it 'should stop multiple instances of Mirage' do
        ports = 7001, 7002
        @runner.should_receive(:invoke).with(:stop, [], :port => ports)
        Mirage.stop(:port => ports)
      end

    end

    describe Mirage::Runner do
      it 'should stop the running instance of Mirage' do

        runner = Mirage::Runner.new

        runner.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(process_string_for_mirage(7001, 18903))
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18903/) do
          runner.rspec_reset
          runner.stub(:`).and_return("")
        end

        Mirage::Runner.should_receive(:new).with([], {}, anything).and_return(runner)
        runner.invoke(:stop, [], nil)
      end

      it 'should not stop any instances when more than one is running' do
        ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
        #{process_string_for_mirage(7002, 18902)}
        #{process_string_for_mirage(7003, 18903)}
PS

        runner = Mirage::Runner.new

        runner.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(ps_aux_output)
        runner.should_not_receive(:`).with(/taskkill.*/)

        Mirage::Runner.should_receive(:new).with([], {}, anything).and_return(runner)

        lambda { runner.invoke(:stop, [], nil) }.should raise_error(Mirage::ClientError)

      end


      it 'should stop the instance running on the given port' do

        task_list_output =<<TASKLIST
#{process_string_for_mirage(7001, 18901)}
        #{process_string_for_mirage(7002, 18902)}
TASKLIST

        options = {:port => [7001]}
        runner = Mirage::Runner.new
        runner.options = options

        runner.should_receive(:`).with(/tasklist.*/).at_least(1).and_return(task_list_output)
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18901/) do
          runner.rspec_reset
          runner.stub(:`).and_return(process_string_for_mirage(7002, 18902))
        end

        Mirage::Runner.should_receive(:new).with([], options, anything).and_return(runner)

        runner.invoke(:stop, [], options)
      end

      it 'should stop the instance running on the given ports' do
        ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
        #{process_string_for_mirage(7002, 18902)}
        #{process_string_for_mirage(7003, 18903)}
PS

        options = {:port => [7001,7002]}
        runner = Mirage::Runner.new
        runner.options = options

        runner.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(ps_aux_output)
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18901/)
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18902/) do
          runner.rspec_reset
          runner.stub(:`).and_return(process_string_for_mirage("7003", 18903))
        end

        Mirage::Runner.should_receive(:new).with([], options, anything).and_return(runner)
        runner.invoke(:stop, [], options)
      end

      it 'should stop all running instances' do
        ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
        #{process_string_for_mirage(7002, 18902)}
        #{process_string_for_mirage(7003, 18903)}
PS

        options = {:port => [:all]}
        runner = Mirage::Runner.new
        runner.options = options


        runner.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(ps_aux_output)

        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18901/)
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18902/)
        runner.should_receive(:`).with(/taskkill \/F \/T \/PID 18903/) do
          runner.rspec_reset
          runner.stub(:`).and_return("")
        end

        Mirage::Runner.should_receive(:new).with([], options, anything).and_return(runner)
        runner.invoke(:stop, [], options)

      end

      it 'should not error when asked to stop Mirage on a port that it is not running on' do
        ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
PS

        options = {:port => [7002]}
        runner = Mirage::Runner.new

        runner.should_receive(:`).with(/tasklist.*/).any_number_of_times.and_return(ps_aux_output)
        runner.should_not_receive(:`).with(/taskkill \/F \/T \/PID 18901/)

        Mirage::Runner.should_receive(:new).with([], options, anything).and_return(runner)

        lambda { runner.invoke(:stop, [], options) }.should_not raise_error(Mirage::ClientError)
      end

#  it 'should not start mirage on the same port' do
#    ps_aux_output =<<PS
##{process_string_for_mirage(7001, 18901)}
#PS
#    IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
#    lambda{Mirage::Runner.new.invoke(:start, [], {:port => 7001})}.should raise_error(Mirage::ClientError)
#  end


    end
  end
end