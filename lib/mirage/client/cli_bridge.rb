module Mirage
module CLIBridge
  def mirage_process_ids ports
    mirage_instances = {}
    ["Mirage Server", "mirage_server", "mirage server"].each do |process_name|
      processes_with_name(process_name).lines.collect { |line| line.chomp }.each do |process_line|
        pid = process_line.split(' ')[1]
        port = process_line[/port (\d+)/, 1]
        mirage_instances[port] = pid
      end
    end

    return mirage_instances if ports.first.to_s == "all" || ports.empty?
    Hash[mirage_instances.find_all { |port, pid| ports.include?(port.to_i) }]
  end

  def kill pid
    ChildProcess.windows? ? `taskkill /F /T /PID #{pid}` : `kill -9 #{pid}`
  end

  def processes_with_name name
    if ChildProcess.windows?
      `tasklist /V | findstr "#{name.gsub(" ", '\\ ')}"`
    else
      IO.popen("ps aux | grep '#{name}' | grep -v grep | grep -v #{$$}")
    end
  end

end
end
