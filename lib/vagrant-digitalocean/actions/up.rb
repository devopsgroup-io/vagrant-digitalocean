require "vagrant-digitalocean/helpers/result"
require "faraday"
require "log4r"
require "json"
require "cgi"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Up
        def initialize(app, env)
          @app, @env = app, env

          # TODO move urls to a settings file
          @client = Faraday.new(:url => "https://api.digitalocean.com/")
          @client.response :logger
        end

        def call(env)
          ssh_key_id = request("/ssh_keys/").find_id(:ssh_keys, "Vagrant Insecure")

          # TODO move to settings file
          if !ssh_key_id
            key = nil
            File.open(DigitalOcean.source_root + "keys/vagrant.pub") do |file|
              key = file.read
            end

            result = request("/ssh_keys/new", {
              :name => "Vagrant Insecure",
              :ssh_pub_key => key
            })

            ssh_key_id = result["ssh_key"]["id"]
          end

          result = request("/images", { :filter => "global" })
          image_id = result.find_id(:images, "Ubuntu 12.04 x32 Server")

          result = request("/regions")
          region_id = result.find_id(:regions, "New York 1")

          result = request("/sizes")
          size_id = result.find_id(:sizes, "512MB")

          result = request("/droplets/new", {
            :size_id => size_id,
            :region_id => region_id,
            :image_id => image_id,
            :name => "vagrantGUID",
            :ssh_key_ids => ssh_key_id
          })

          @app.call(env)
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

          Helpers::Result.new(body)
        end
      end
    end
  end
end
