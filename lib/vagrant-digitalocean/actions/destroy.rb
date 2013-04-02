require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        include Vagrant::Util::Retryable
        include Helpers::Client

        def initialize(app, env)
          @app, @env = app, env
          @client = client
          @translator = Helpers::Translator.new("actions.destroy")
        end

        def call(env)
          # submit destroy droplet request
          env[:ui].info @translator.t("destroying")
          result = @client.request("/droplets/#{env[:machine].id}/destroy")

          # wait for request to complete
          env[:ui].info @translator.t("wait_off")
          @client.wait_for_event(result["event_id"])

          @app.call(env)
        end
      end
    end
  end
end
