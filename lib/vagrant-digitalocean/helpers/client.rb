require "vagrant-digitalocean/helpers/result"
require "faraday"
require "json"

module VagrantPlugins
  module DigitalOcean
    module Helpers
      module Client
        def client
          @client ||= ApiClient.new(@env[:machine].provider_config.ca_path)
        end
      end

      class ApiClient
        def initialize(ca_path)
          @client = Faraday.new({
                      :url => "https://api.digitalocean.com/",
                      :ssl => {
                        :ca_file => ca_path
                      }
                    })
        end

        def request(path, params = {})
          begin
            result = @client.get(path, params = params.merge({
              :client_id => ENV["DO_CLIENT_ID"],
              :api_key => ENV["DO_API_KEY"]
            }))
          rescue Faraday::Error::ConnectionFailed => e
            # TODO this is suspect but because farady wraps the exception
            #      in something generic there doesn't appear to be another
            #      way to distinguish different connection errors :(
            if e.message =~ /certificate verify failed/
              raise Errors::CertificateError
            end

            raise e
          end

          # remove the api key in case an error gets dumped to the console
          params[:api_key] = "REMOVED"

          begin
            body = JSON.parse(result.body)
          rescue JSON::ParserError => e
            raise(Errors::JSONError, {
              :message => e.message,
              :path => path,
              :params => params,
              :response => result.body
            })
          end

          if body["status"] != "OK"
            raise(Errors::APIStatusError, {
              :path => path,
              :params => params,
              :status => body["status"],
              :response => body.inspect
            })
          end

          Result.new(body)
        end
      end
    end
  end
end
