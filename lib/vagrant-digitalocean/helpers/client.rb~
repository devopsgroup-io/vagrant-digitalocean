require "vagrant-digitalocean/helpers/result"
require "faraday"
require "json"

module VagrantPlugins
  module DigitalOcean
    module Helpers
      class Client
        def initialize
          @client = Faraday.new(:url => "https://api.digitalocean.com/")
        end

        def request(path, params = {})
          # create the key
          result = @client.get(path, params = params.merge({
            :client_id => ENV["DO_CLIENT_ID"],
            :api_key => ENV["DO_API_KEY"]
          }))

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
