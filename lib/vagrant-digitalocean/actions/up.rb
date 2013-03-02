require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Up
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app, @env = app, env
          @client = Helpers::Client.new
        end

        def call(env)
          # if the machine state is created skip
          if env[:machine].state.id == :active
            env[:ui].info "Droplet is active, skipping the `up` process"
            return @app.call(env)
          end

          # TODO check the content of the key to see if it's changed
          # TODO use the directory / vm name to qualify they
          begin
            ssh_key_id = @client
              .request("/ssh_keys/")
              .find_id(:ssh_keys, :name => "Vagrant Insecure")
          rescue Errors::ResultMatchError
            key = DigitalOcean.vagrant_key

            result = @client.request("/ssh_keys/new", {
              :name => "Vagrant Insecure",
              :ssh_pub_key => key
            })

            ssh_key_id = result["ssh_key"]["id"]
          end

          size_id = @client
            .request("/sizes")
            .find_id(:sizes, :name => env[:machine].provider_config.size)

          image_id = @client
            .request("/images", { :filter => "global" })
            .find_id(:images, :name => env[:machine].provider_config.image)

          region_id = @client
            .request("/regions")
            .find_id(:regions, :name => env[:machine].provider_config.region)

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

          retryable(:tries => 30, :sleep => 10) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Wait for the server to be ready
            raise "not ready" if env[:machine].state.id != :active
          end

          # signal that the machine has just been created, used in ReadState
          env[:machine_just_created] = true

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].state.id != :not_created
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(ActionDispatch.new.destroy, destroy_env)
        end
      end
    end
  end
end
