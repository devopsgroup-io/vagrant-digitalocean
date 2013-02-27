require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class ReadState
        def initialize(app, env)
          @app, @env = app, env

          # TODO move urls to a settings file
          @client = Helpers::Client.new
        end

        def call(env)
          if env[:machine].id
            result = @client.request("/droplets/#{env[:machine].id}")
            env[:machine_state] = result["droplet"]
          else
            env[:machine_state] = :not_created
          end

          @app.call(env)
        end
      end
    end
  end
end
