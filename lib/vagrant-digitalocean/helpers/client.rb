require "vagrant-digitalocean/helpers/result"
require "faraday"
require "json"

module VagrantPlugins
  module DigitalOcean
    module Helpers
      class Client
        def initialize
          @client = Faraday.new(:url => "https://api.digitalocean.com/")
          # @client.response :logger
        end

        def request(path, params = {})
          # create the key
          result = @client.get(path, params.merge({
            :client_id => ENV["DO_CLIENT_ID"],
            :api_key => ENV["DO_API_KEY"]
          }))

          # TODO catch parsing errors
          body = JSON.parse(result.body)

          # TODO wrap all calls to api with this check and throw
          if body["status"] != "OK"
            raise "error in call to #{path} with #{params}"
          end

          Result.new(body)
        end
      end
    end
  end
end
