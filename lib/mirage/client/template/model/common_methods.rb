module Mirage

  class Template
    module Model
      module CommonMethods
        extend Helpers::MethodBuilder

        builder_methods :content_type,
                        :http_method,
                        :default,
                        :status,
                        :delay,
                        :required_parameters,
                        :required_body_content,
                        :required_headers,
                        :headers,
                        :endpoint,
                        :body
      end

    end
  end

end