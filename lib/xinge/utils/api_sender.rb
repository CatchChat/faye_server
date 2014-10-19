require 'digest'
require 'uri'
module Xinge
  module Utils
    module ApiSender
      def send_api_request(api, params, method, secret_key, timeout = 3, &block)
        verify_method!(method)

        timeout = timeout.to_i
        timeout = 3 if timeout < 1
        params[:sign] = generate_sign(api, params, method, secret_key)

        uri = URI.parse(api)
        conn = Faraday.new(url: "#{uri.scheme}://#{uri.host}") do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end

        resp = conn.send method.downcase do |req|
          if method == 'GET'
            req.url uri.path, params
          else
            req.url uri.path
            req.body = params
            req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
          end
          req.options.timeout = timeout
        end

        Rails.logger.debug "===> PARAMS IS #{params}."
        response = Xinge::Response.new(resp.body)
        block.call(response) if block_given?
        response
      end

      def generate_sign(api, params, method, secret_key)
        verify_method!(method)

        uri = URI.parse(api)
        params_str = params.sort.map do |(key, value)|
          "#{key}=#{value}"
        end.join

        Digest::MD5.hexdigest([method, uri.host, uri.path, params_str, secret_key].join)
      end

      private

      def verify_method!(method)
        method.upcase!
        fail 'method is invalid' unless %w(GET POST).include?(method)
      end
    end
  end
end
