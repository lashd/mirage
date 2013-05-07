require 'tempfile'
module CommandLine
  def run command
    output = Tempfile.new("child")
    Dir.chdir SCRATCH do
      process = ChildProcess.build(*("#{command}".split(' ')))
      process.detach
      process.io.stdout = output
      process.io.stderr = output
      process.start
      wait_until(:timeout_after => 30.seconds) { process.exited? }
    end
    File.read(output.path)
  end

  def normalise text
    text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ').strip
  end
end

World CommandLine
include CommandLine