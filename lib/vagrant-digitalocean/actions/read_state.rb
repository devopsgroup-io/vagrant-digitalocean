require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class ReadState
        def initialize(app, env)
          @app, @env = app, env
          @client = Helpers::Client.new
        end

        def call(env)
          # If we have a machine id ask the api what the state is
          if env[:machine].id
            droplet = @client.request("/droplets/#{env[:machine].id}")["droplet"]

            env[:machine_state] = droplet
          end

          # no id signals that the machine hasn't yet been created
          env[:machine_state] ||= {"status" => :not_created}

          # TODO there has to be a better way, see UP for when
          # :machine_just_created is set
          env[:machine_state][:just_created] = env[:machine_just_created]
          @app.call(env)
        end
      end
    end
  end
end
