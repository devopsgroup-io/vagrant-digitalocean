require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Rebuild
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @translator = Helpers::Translator.new("actions.rebuild")
        end

        def call(env)
          # look up image id
          image_id = @client
            .request("/images", { :filter => "global" })
            .find_id(:images, :name => @machine.provider_config.image)

          # submit rebuild request
          result = @client.request("/droplets/#{@machine.id}/rebuild", {
            :image_id => image_id
          })

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(env, result["event_id"])

          @app.call(env)
        end
      end
    end
  end
end
