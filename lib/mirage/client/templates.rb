module Mirage
  class Templates
    include HTTParty
    def initialize base_url
      @url = "#{base_url}/templates"
      @requests = Requests.new(base_url)
      @default_config = Template::Configuration.new
    end

    def default_config &block
      return @default_config unless block_given?
      calling_instance = eval "self", block.binding
      @default_config.caller_binding = calling_instance
      @default_config.instance_eval &block
      @default_config.caller_binding = nil
    end

    def delete_all
      self.class.delete(@url)
      @requests.delete_all
    end

    def put *args, &block
      if args.first.class.is_a?(Template::Model)
        template = args.first
        template.endpoint "#{@url}/#{template.endpoint}" unless template.endpoint.to_s.start_with?(@url)
      else
        endpoint, response = args
        template = Mirage::Template.new  "#{@url}/#{endpoint}", response, @default_config
      end

      if block
        calling_instance = eval "self", block.binding
        template.caller_binding = calling_instance
        template.instance_exec(template,&block)
        template.caller_binding = nil
      end

      template.create
    end
  end
end
