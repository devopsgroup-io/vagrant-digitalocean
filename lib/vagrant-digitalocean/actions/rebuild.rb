require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Rebuild
        include Helpers::Client

        def initialize(app, env)
          @app, @env = app, env
          @client = client
          @translator = Helpers::Translator.new("actions.rebuild")
        end

        def call(env)
          # look up image id
          image_id = @client
            .request("/images", { :filter => "global" })
            .find_id(:images, :name => env[:machine].provider_config.image)

          # submit rebuild request
          env[:ui].info @translator.t("rebuild")
          result = @client.request("/droplets/#{env[:machine].id}/rebuild", {
            :image_id => image_id
          })

          # wait for request to complete
          env[:ui].info @translator.t("wait")
          @client.wait_for_event(result["event_id"])

          @app.call(env)
        end
      end
    end
  end
end
