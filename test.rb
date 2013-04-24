#require './lib/mirage/client'
#
#
##mirage = Mirage::Client.new
#
#
#module Mirage
#  class Template
#    module Model
#      class << self
#        def included clazz
#          def clazz.endpoint endpoint =nil
#            return @endpoint unless endpoint
#            @endpoint = endpoint
#          end
#
#          def clazz.builder_method name
#            define_method "with_#{name}".to_sym do |arg|
#              instance_variable_set("@#{name}".to_sym, arg)
#              self
#            end
#          end
#        end
#      end
#
#      def initialize
#        @http_status = 200
#      end
#
#      def template
#        service_now_response = Mirage::Template.new endpoint, value
#        service_now_response.status=@http_status
#        return service_now_response
#      end
#
#      def endpoint
#        endpoint = self.class.endpoint
#        raise "define endpoint on class" unless endpoint
#        endpoint
#      end
#
#      def with_http_status status
#        @http_status = status
#        self
#      end
#
#
#    end
#  end
#end
#
#class FindCiResponse
#
#  include Mirage::Template::Model
#
#  endpoint 'getCis'
#
#  builder_method :status
#
#
#  def value
#    <<-XML
#      <xml><status>#{@status}</status></xml>
#    XML
#  end
#
#end
#
#
#response = FindCiResponse.new.status('failed').http_status(404)
#
#
#
#Mirage.start.put response
#
#puts response.value
#
#
#
#
#
#
#
#
#
#
#
#
#
require './lib/mirage/client'

template = Mirage::Template.new 'endpoint', 'hello'

class MyClass
  extend Mirage::Template::Model
end

