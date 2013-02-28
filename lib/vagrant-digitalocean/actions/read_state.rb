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
            droplet = @client.request("/droplets/#{env[:machine].id}")["droplet"]

            env[:machine_state] = droplet
          end

          env[:machine_state] ||= {"status" => :not_created}

          env[:ui].info "Droplet state: #{env[:machine_state]["status"]}"
          @app.call(env)
        end
      end
    end
  end
end
