require 'tempfile'
require 'wait_methods'

module CommandLine
  include Mirage::WaitMethods
  class Output
    attr_reader :stdout, :stdin, :status

    def initialize(stdout:, stdin:, status:)
      @stdout = stdout
      @stdin = stdin
      @status = status
    end
  end

  def run command
    command = if ENV['mode'] == 'regression' && ChildProcess.windows?
                command.gsub(/^mirage/, MIRAGE_CMD)
              else
                "#{RUBY_CMD} ../bin/#{command}"
              end

    output = Tempfile.new("child")
    Dir.chdir SCRATCH do
      process = ChildProcess.build(*("#{command}".split(' ')))
      process.detach
      process.io.stdout = output
      process.io.stderr = output
      process.start
      wait_until(:timeout_after => 30) {process.exited?}
    end
    @commandline_output = normalise(File.read(output.path))
  end

  def commandline_output
    @commandline_output
  end

  def run_ruby code
    Dir.chdir SCRATCH do
      system "#{RUBY_CMD} -I #{SOURCE_PATH} -e \"#{@code_snippet}\n#{escape_double_quotes(code)}\""
    end
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
