require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        def initialize(app, env)
          @app, @env = app, env
          @client = Helpers::Client.new
        end

        def call(env)
          # TODO remove the key associated with this machine
          if [:active, :new].include?(env[:machine].state.id)
            result = @client.request("/droplets/#{env[:machine].id}/destroy")
          else
            env[:ui].info "Droplet not created"
          end

          @app.call(env)
        end
      end
    end
  end
end
