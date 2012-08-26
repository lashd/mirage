Before do
  FileUtils.mkdir_p(SCRATCH)

  if Mirage.running?
    $mirage.clear
  else
    $mirage = start_mirage_in_scratch_dir
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
  Mirage.stop :port => :all
end

After('@command_line') do
  Mirage.stop :port => :all
end

at_exit do
  Mirage.stop :port => :all
end