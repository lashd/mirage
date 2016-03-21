require 'tempfile'
require 'wait_methods'

module CommandLine
  include Mirage::WaitMethods

  def run command
    output = Tempfile.new("child")
    Dir.chdir SCRATCH do
      process = ChildProcess.build(*("#{command}".split(' ')))
      process.detach
      process.io.stdout = output
      process.io.stderr = output
      process.start
      wait_until(:timeout_after => 30) { process.exited? }
    end
    File.read(output.path)
  end

  def normalise text
    text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ').strip
  end

  def write_to_file file_path, content
    file_path = "#{SCRATCH}/#{file_path}" unless file_path =~ /^\//

    FileUtils.rm_rf(file_path) if File.exists?(file_path)
    FileUtils.mkdir_p(File.dirname(file_path))

    File.open("#{file_path}", 'w') do |file|
      file.write(content)
    end
  end
end

World CommandLine
include CommandLine
