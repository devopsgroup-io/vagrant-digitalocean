require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class PowerOn
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @translator = Helpers::Translator.new("actions.power_on")
        end

        def call(env)
          # submit power on droplet request
          result = @client.request("/droplets/#{@machine.id}/power_on")

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(env, result["event_id"])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end


