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
        template = template.clone
        template.endpoint "#{@url}/#{template.endpoint}"
      else

        endpoint, template = args
        if template.class.is_a?(Template::Model)
          template = template.clone
          template.endpoint "#{@url}/#{endpoint}"
        else
          template = Mirage::Template.new("#{@url}/#{endpoint}", template, @default_config)
        end

      end

      if block
        calling_instance = eval "self", block.binding
        template.caller_binding = calling_instance
        template.instance_exec(template, &block)
        template.caller_binding = nil
      end
      template.create
    end
  end
end
