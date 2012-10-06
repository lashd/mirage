Before do
  FileUtils.mkdir_p(SCRATCH)

  $mirage = start_mirage_in_scratch_dir
  $mirage.clear

  Dir["#{SCRATCH}/*"].each do |file|
    FileUtils.rm_rf(file) unless file == "#{SCRATCH}/mirage.log"
  end

  if File.exists? "#{SCRATCH}/mirage.log"
    @mirage_log_file = File.open("#{SCRATCH}/mirage.log")
    @mirage_log_file.seek(0, IO::SEEK_END)
  end
end

Before ('@command_line') do
  Mirage.stop :all
end

After('@command_line') do
  Mirage.stop :all
end

at_exit do
  Mirage.stop :all
end