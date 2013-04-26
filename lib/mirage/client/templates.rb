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
      yield @default_config
    end

    def delete_all
      self.class.delete(@url)
      @requests.delete_all
    end

    def put *args, &block
      if args.first.class.is_a?(Template::Model)
        template = args.first
        template.endpoint "#{@url}/#{template.endpoint}"
      else
        endpoint, response = args
        template = Mirage::Template.new  "#{@url}/#{endpoint}", response, @default_config
      end
      template.instance_eval &block if block
      template.create
    end
  end
end
