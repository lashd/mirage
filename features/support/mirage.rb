module Test
  module Mirage
    module Runner
      def stop_mirage
        run "#{MIRAGE_CMD} stop -p all"
      end

      def start_mirage
        if ChildProcess.windows?
          Dir.chdir(SCRATCH) do
            process = ChildProcess.build(MIRAGE_CMD, "start")
            process.start
            wait_until { process.exited? }
          end
        else
          run "#{MIRAGE_CMD} start"
        end
      end
    end
  end
end
include Test::Mirage::Runner