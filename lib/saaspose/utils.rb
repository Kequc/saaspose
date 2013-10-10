require 'cgi'
require 'rest_client'
require 'openssl'
require 'base64'
require 'uri'
require 'json'

module Saaspose
  class Utils
    DIGEST = OpenSSL::Digest::Digest.new('sha1')

    class << self
      def path(file_path)
        if file_path.is_a?(Array)
          File.join file_path.reject { |c| c.blank? }.map { |c| c.to_s }
        else
          file_path.to_s
        end
      end

      def sign(file_path, options=nil)
        options = options ? options.dup : {}
        options.merge!(:appSID => Configuration.app_sid)

        url = path file_path
        url = "#{Configuration.product_uri}#{url}"
        url << "?" << options.map{|key, value| "#{key}=#{CGI::escape(value.to_s)}"}.join("&")

        signature = OpenSSL::HMAC.digest(DIGEST, Configuration.app_key, url)
        signature = Base64.strict_encode64(signature).chop
        signature = URI::escape(signature, /[^A-z0-9]/)

        "#{url}&signature=#{signature}"
      end

      def call(uri, options=nil)
        signed_url = Utils.sign(uri, options)
        log(:debug, "calling: #{signed_url}")
        RestClient.get(signed_url, :accept => 'application/json')
      rescue
        log(:error, "error: #{$!.inspect}")
        raise
      end

      def call_and_parse(uri, options=nil)
        response = call(uri, options)
        JSON.parse(response.body)
      end

      def call_and_save(uri, options=nil, file)
        response = response = call(uri, options)
        Utils.save_file(response, file)
      end

      def save_file(response_stream, local_file)
        File.open(local_file, "wb") { |file| file.write(response_stream.body) }
      end

      def log(severity, message)
        Configuration.logger.send(severity, message) if Configuration.logger
      end

    end
  end
end
