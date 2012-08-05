Before do
  FileUtils.mkdir_p(SCRATCH)
  $mirage = Mirage::Client.new
  if $mirage.running?
    $mirage.clear
  else
    start_mirage
  end

  Dir["#{SCRATCH}/*"].each do |file|
    FileUtils.rm_rf(file) unless file == "#{SCRATCH}/mirage.log"
  end

  if File.exists? "#{SCRATCH}/mirage.log"
    @mirage_log_file = File.open("#{SCRATCH}/mirage.log")
    @mirage_log_file.seek(0, IO::SEEK_END)
  end
end

Before ('@command_line') do
  stop_mirage
end

After('@command_line') do
  stop_mirage
end

at_exit do
  stop_mirage
end