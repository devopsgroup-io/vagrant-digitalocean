require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Create
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @translator = Helpers::Translator.new("actions.create")
        end

        def call(env)
          ssh_key_id = env[:ssh_key_id]

          size_id = @client
            .request("/sizes")
            .find_id(:sizes, :name => @machine.provider_config.size)

          image_id = @client
            .request("/images", { :filter => "global" })
            .find_id(:images, :name => @machine.provider_config.image)

          region_id = @client
            .request("/regions")
            .find_id(:regions, :name => @machine.provider_config.region)

          # submit new droplet request
          result = @client.request("/droplets/new", {
            :size_id => size_id,
            :region_id => region_id,
            :image_id => image_id,
            :name => @machine.config.vm.hostname || @machine.name,
            :ssh_key_ids => ssh_key_id
          })

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(env, result["droplet"]["event_id"])

          # assign the machine id for reference in other commands
          @machine.id = result["droplet"]["id"].to_s

          # refresh droplet state with provider and output ip address
          droplet = Provider.droplet(@machine, :refresh => true)
          env[:ui].info @translator.t("ip", { :ip => droplet["ip_address"] })

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if @machine.state.id != :not_created
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Actions.destroy, destroy_env)
        end
      end
    end
  end
end
