require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Up
        def initialize(app, env)
          @app, @env = app, env

          # TODO move urls to a settings file
          @client = Helpers::Client.new
        end

        def call(env)
          # if the machine state is anything but created skip
          if env[:machine].state != :not_created
            env[:ui].info "Droplet state is: #{env[:machine].state.short_description}, skipping the up"
            return @app.call(env)
          end

          ssh_key_id = request("/ssh_keys/").find_id(:ssh_keys, "Vagrant Insecure")

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

          # assign the machine id for reference in other commands
          env[:machine].id = result["droplet"]["id"]

          @app.call(env)
        end

        def request(path, params = {})
          @client.request(path, params)
        end
      end
    end
  end
end
