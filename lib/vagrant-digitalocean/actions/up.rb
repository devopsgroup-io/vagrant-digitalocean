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
          result = wrap_request("/ssh_keys/")

          # TODO check for ssh keys (foo || [])
          ssh_key_id = nil

          result["ssh_keys"].each do |key|
            if key["name"] == "Vagrant Insecure"
              ssh_key_id = key["id"]
              break
            end
          end

          # TODO move to settings file
          if ssh_key_id
            File.open(DigitalOcean.source_root + "keys/vagrant.pub") do |file|
              puts (key = file.read)
              puts key
              result = wrap_request("/ssh_keys/new", {
                :name => "Vagrant Insecure",
                :ssh_pub_key => key
              })

              ssh_key_id = result["ssh_key"]["id"]
            end
          end

          image_id = nil

          result = wrap_request("/images/", { :filter => "global" })

          result["images"].each do |image|
            if image["name"] == "Ubuntu 12.04 x32 Server"
              image_id = image["id"]
              break
            end
          end

          region_id = nil

          result = wrap_request("/regions/")

          result["regions"].each do |region|
            if region["name"] == "New York 1"
              region_id = region["id"]
              break
            end
          end

          size_id = nil

          result = wrap_request("/sizes/")

          result["sizes"].each do |size|
            if size["name"] == "512MB"
              size_id = size["id"]
              break
            end
          end

          result = wrap_request("/droplets/new", {
            :size_id => size_id,
            :region_id => region_id,
            :image_id => image_id,
            :name => "vagrantGUID",
            :ssh_key_ids => ssh_key_id
          })

          @app.call(env)
        end

        def wrap_request(path, params = {})
          # create the key
          result = @client.get(path, params.merge({
            :client_id => ENV["DO_CLIENT_ID"],
            :api_key => ENV["DO_API_KEY"]
          }))

          # TODO catch parsing errors
          body = JSON.parse(result.body)

          # TODO wrap all calls to api with this check and throw
          if body["status"] != "OK"
            puts "FAIL"
            puts body.inspect
            raise "error in call to #{path} with #{params}"
          end

          JSON.parse(result.body)
        end
      end
    end
  end
end
