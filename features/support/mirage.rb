module Test
  module Mirage
    module Runner
      def stop_mirage
        run "#{MIRAGE_CMD} stop -p all"
      end

      def start_mirage
          run "#{MIRAGE_CMD} start"
      end
    end
  end
end
include Test::Mirage::Runner