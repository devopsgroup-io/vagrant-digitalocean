require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Create
        include Vagrant::Util::Retryable
        include Helpers::Client

        def initialize(app, env)
          @app, @env = app, env
          @client = client
          @translator = Helpers::Translator.new("actions.create")
        end

        def call(env)
          # if the machine state is created skip
          if env[:machine].state.id == :active
            env[:ui].info @translator.t("skip")
            return @app.call(env)
          end

          ssh_key_id = env[:ssh_key_id]

          size_id = @client
            .request("/sizes")
            .find_id(:sizes, :name => env[:machine].provider_config.size)

          image_id = @client
            .request("/images", { :filter => "global" })
            .find_id(:images, :name => env[:machine].provider_config.image)

          region_id = @client
            .request("/regions")
            .find_id(:regions, :name => env[:machine].provider_config.region)

          env[:ui].info @translator.t("create_droplet")

          result = @client.request("/droplets/new", {
            :size_id => size_id,
            :region_id => region_id,
            :image_id => image_id,
            # TODO use the current directory name as a post fix
            :name => "vagrant",
            :ssh_key_ids => ssh_key_id
          })

          # assign the machine id for reference in other commands
          env[:machine].id = result["droplet"]["id"].to_s

          env[:ui].info @translator.t("wait_active")

          retryable(:tries => 30, :sleep => 10) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Wait for the server to be ready
            raise "not ready" if env[:machine].state.id != :active
          end

          retryable(:tries => 30, :sleep => 2) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Wait for the server to be ready for ssh
            env[:machine].communicate.execute("echo");
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
          env[:action_runner].run(Action.new.destroy, destroy_env)
        end
      end
    end
  end
end
