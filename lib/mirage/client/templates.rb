module Mirage
  class Templates
    include HTTParty
    def initialize base_url
      @url = "#{base_url}/templates"
      @requests = Requests.new(base_url)
      @default_config = TemplateConfiguration.new
    end

    def default_config &block
      return @default_config unless block_given?
      yield @default_config
    end

    def delete_all
      self.class.delete(@url)
      @requests.delete_all
    end

    def put *args
      if args.first.is_a?(Template)
        template = args.first
        template.endpoint = "#{@url}/#{template.endpoint}"
      else
        endpoint, response = args
        template = Mirage::Template.new  "#{@url}/#{endpoint}", response, @default_config
        yield template if block_given?
      end
      template.create
    end
  end
end
