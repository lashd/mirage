module Mirage
  class Templates
    include HTTParty

    def initialize base_url
      @base_url = base_url
    end

    def delete_all
      self.class.delete(@base_url)
      Requests.delete_all
    end

    def put endpoint, response
      template = Mirage::Template.new  "#{@base_url}/#{endpoint}", response
      yield template if block_given?
      template.create
    end
  end
end
