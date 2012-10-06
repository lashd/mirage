require 'ostruct'
module Mirage
  class Response

    attr_accessor :content_type,:method, :pattern, :default, :status, :delay
    attr_reader :value

    def initialize response
      @content_type = 'text/plain'
      @value = response
      @method = :get
      @status = 200
      @delay = 0
      @body_content_requirements = []
      @request_parameter_requirements = {}
    end

    def headers
      headers = {}
      headers['Content-Type']=@content_type
      headers['X-mirage-file'] = 'true' if @response.kind_of?(IO)
      headers['X-mirage-method'] = @method
      headers['X-mirage-pattern'] = @pattern if @pattern
      headers['X-mirage-default'] = @default if @default == true
      headers['X-mirage-status'] = @status
      headers['X-mirage-delay'] = @delay
      @body_content_requirements.each_with_index do |requirement, index|
        if requirement.is_a?(Regexp)
          headers["x-mirage-required_body_content#{index}"] = "%r{#{requirement.source}}"
        else
          headers["x-mirage-required_body_content#{index}"] = requirement
        end
      end

      @request_parameter_requirements.inject(0) do |index, requirement|
        name, requirement = requirement
        if requirement.is_a?(Regexp)
          headers["x-mirage-required_parameter#{index}"] = "#{name}:%r{#{requirement.source}}"
        else
          headers["x-mirage-required_parameter#{index}"] = "#{name}:#{requirement}"
        end
        index+=1
      end

      headers
    end

    def add_body_content_requirement requirement
      @body_content_requirements << requirement
    end

    def add_request_parameter_requirement name, requirement
      @request_parameter_requirements[name] = requirement
    end
  end
end