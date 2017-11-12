require 'hashie/mash'
module Mirage
  module Hashie
    class Mash < ::Hashie::Mash
      disable_warnings
    end
  end
end