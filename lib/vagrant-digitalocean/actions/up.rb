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
          if env[:machine].state == :active
            env[:ui].info "Droplet is active, skipping the `up` process"
            return @app.call(env)
          end

          ssh_key_id = @client
            .request("/ssh_keys/")
            .find(:ssh_keys, :name => "Vagrant Insecure")

          if !ssh_key_id
            key = nil
            File.open(DigitalOcean.source_root + "keys/vagrant.pub") do |file|
              key = file.read
            end

            result = @client.request("/ssh_keys/new", {
              :name => "Vagrant Insecure",
              :ssh_pub_key => key
            })

            ssh_key_id = result["ssh_key"]["id"]
          end

          # TODO check for nil size_id
          size_id = @client
            .request("/sizes")
            .find(:sizes, :name => env[:machine].provider_config.size)

          # TODO check for nil image_id
          image_id = @client
            .request("/images", { :filter => "global" })
            .find(:images, :name => env[:machine].provider_config.image)

          # TODO check for nil region_id
          region_id = @client
            .request("/regions")
            .find(:regions, :name => env[:machine].provider_config.region)

          result = @client.request("/droplets/new", {
            :size_id => size_id,
            :region_id => region_id,
            :image_id => image_id,
            # TODO use the current directory name as a post fix
            :name => "vagrant",
            :ssh_key_ids => ssh_key_id
          })

          # assign the machine id for reference in other commands
          env[:machine].id = result["droplet"]["id"]

          @app.call(env)
        end
      end
    end
  end
end
