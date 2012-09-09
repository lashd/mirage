$LOAD_PATH.unshift "../lib"
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
