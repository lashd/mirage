require 'rack/utils'
require 'sinatra/base'
module Mirage
  class Server < Sinatra::Base
    module Helpers
      module HttpHeaders
        HTTP_HEADER_FILTER_EXCEPTIONS = %w(CONTENT_TYPE CONTENT_LENGTH)
        def extract_http_headers(env)
          headers = env.reject do |k, v|
            !HTTP_HEADER_FILTER_EXCEPTIONS.include?(k.to_s.upcase) && (!(/^HTTP_[A-Z_]+$/ === k) || v.nil?)
          end.map do |k, v|
            [reconstruct_header_name(k), v]
          end.inject(Rack::Utils::HeaderHash.new) do |hash, k_v|
            k, v = k_v
            hash[k] = v
            hash
          end

          x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")

          headers.merge!("X-Forwarded-For" => x_forwarded_for)
        end

        def reconstruct_header_name(name)
          name.sub(/^HTTP_/, "").gsub("_", "-")
        end
      end
    end
  end

end