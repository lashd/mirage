$LOAD_PATH.unshift "../lib"
require 'rspec'
require 'mirage/client'

def process_string_for_mirage(mirage_port, pid)
  "team     #{pid}  6.2  0.4  84328 20760 pts/1    Sl   22:15   0:00 Mirage Server port #{mirage_port}"
end

describe Mirage do

  describe 'starting' do
    it 'should start Mirage' do
      #Mirage.start
    end
  end

  describe 'stopping' do
  end

  describe Mirage::Runner do
    it 'should stop the running instance of Mirage' do
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(process_string_for_mirage(7001, 18903))

      IO.should_receive(:popen).with("kill -9 18903") do
        IO.rspec_reset
        IO.stub(:popen).and_return("")
      end
      runner = Mirage::Runner.new
      runner.stop
    end

    it 'should not stop any instances when more than one is running' do
      ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
      #{process_string_for_mirage(7002, 18902)}
      #{process_string_for_mirage(7003, 18903)}
PS
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      IO.should_not_receive(:popen).with(/kill.*/)

      lambda { Mirage::Runner.new.stop }.should raise_error(Mirage::ClientError)

    end


    it 'should stop the instance running on the given port' do
      ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
      #{process_string_for_mirage(7002, 18902)}
PS
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      IO.should_receive(:popen).with(/kill -9 18901/) do
        IO.rspec_reset
        IO.stub(:popen).and_return(process_string_for_mirage(7002, 18902))
      end

      begin
        Mirage::Runner.new.invoke(:stop, [], {:port => [7001]})
      rescue Mirage::ClientError => ce
      end
    end

    it 'should stop the instance running on the given ports' do
      ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
      #{process_string_for_mirage(7002, 18902)}
      #{process_string_for_mirage(7003, 18903)}
PS
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      IO.should_receive(:popen).with(/kill -9 18901/)
      IO.should_receive(:popen).with(/kill -9 18902/) do
        IO.rspec_reset
        IO.stub(:popen).and_return(process_string_for_mirage("7003", 18903))
      end

      Mirage::Runner.new.invoke(:stop, [], {:port => [7001, 7002]})
    end

    it 'should stop all running instances' do
      ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
      #{process_string_for_mirage(7002, 18902)}
      #{process_string_for_mirage(7003, 18903)}
PS
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      IO.should_receive(:popen).with(/kill -9 18901/)
      IO.should_receive(:popen).with(/kill -9 18902/)
      IO.should_receive(:popen).with(/kill -9 18903/) do
        IO.rspec_reset
        IO.stub(:popen).and_return("")
      end

      Mirage::Runner.new.invoke(:stop, [], {:port => ["all"]})

    end

    it 'should not error when asked to stop Mirage on a port that it is not running on' do
      ps_aux_output =<<PS
#{process_string_for_mirage(7001, 18901)}
PS
      IO.should_receive(:popen).with(/ps aux.*/).any_number_of_times.and_return(ps_aux_output)
      IO.should_not_receive(:popen).with(/kill -9 18901/)
      lambda { Mirage::Runner.new.invoke(:stop, [], {:port => [7002]}) }.should_not raise_error(Mirage::ClientError)
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