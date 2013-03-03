module Mirage
  class Templates
    include HTTParty
    def initialize base_url
      @base_url = base_url
      @default_config = TemplateConfiguration.new
    end

    def default_config &block
      return @default_config unless block_given?
      yield @default_config
    end

    def delete_all
      self.class.delete(@base_url)
      Requests.delete_all
    end

    def put endpoint, response
      template = Mirage::Template.new  "#{@base_url}/#{endpoint}", response, @default_config
      yield template if block_given?
      template.create
    end
  end
end
