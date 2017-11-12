require 'spec_helper'
require 'mirage/client'

describe CLIBridge do
  def mapping port
    {port.to_s => port_pid_mappings[port.to_s]}
  end

  let(:port_pid_mappings) do
    {"7001" => "18903", "7002" => "18904", "7003" => "18905"}
  end

  let(:operating_system) do
    Hashie::Mash.new({
                         :windows => {
                             :kill_string => "taskkill /F /T /PID %d",
                             :set_ps_cmd_expectation => proc{allow(bridge).to receive(:`).with(/tasklist.*/).and_return(tasklist_output)}
                         },
                         :linux => {
                             :kill_string => "kill -9 %d",
                             :set_ps_cmd_expectation => proc{allow(IO).to receive(:popen).with(/ps aux.*/).and_return(tasklist_output)}
                         }
                     })
  end

  [:linux,:windows].each do |os_name|

    describe os_name do
      let(:os){operating_system[os_name]}
      let!(:bridge) do
        bridge = Object.new
        bridge.extend(CLIBridge)
      end

      include_context os_name do

        let(:tasklist_output) do
          output = []
          port_pid_mappings.each do |port, pid|
            output << process_string_for_mirage(port, pid)
          end
          output.join("\n")
        end

        it 'should find the pids of mirage instances for given ports' do
          os.set_ps_cmd_expectation.call
          expect(bridge.mirage_process_ids([7001, 7002])).to eq(mapping(7001).merge(mapping(7002)))
        end

        it 'should find the pids of mirage instances for all ports' do
          os.set_ps_cmd_expectation.call
          expect(bridge.mirage_process_ids([:all])).to eq(port_pid_mappings)
        end

        it 'should kill the given process id' do
          expect(bridge).to receive(:`).with(os.kill_string % 18903)
          bridge.kill(18903)
        end
      end
    end
  end

end