require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Reload
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @translator = Helpers::Translator.new("actions.reload")
        end

        def call(env)
          # submit reboot droplet request
          result = @client.request("/droplets/#{@machine.id}/reboot")

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(env, result["event_id"])

          @app.call(env)
        end
      end
    end
  end
end


