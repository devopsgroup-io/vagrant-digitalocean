require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        include Vagrant::Util::Retryable
        include Helpers::Client

        CHECK_COUNT = 30

        def initialize(app, env)
          @app, @env = app, env
          @client = client
          @translator = Helpers::Translator.new("actions.destroy")
        end

        def call(env)
          # TODO remove the key associated with this machine
          if [:active, :new].include?(env[:machine].state.id)
            env[:ui].info @translator.t("destroying")
            result = @client.request("/droplets/#{env[:machine].id}/destroy")

            env[:ui].info @translator.t("wait_off")

            checks = 0

            retryable(:tries => CHECK_COUNT, :sleep => 10) do
              # If we're interrupted don't worry about waiting
              next if env[:interrupted]

              # If we're getting close to our check count check for the
              # off state as well. It appears that destroyed droplets can occasionally
              # get stuck in the off state without ever proceeding to archive
              checks+=1
              states = ((CHECK_COUNT - 5) >= checks) ? [:archive, :off] : [:archive]

              # Wait for the server to be ready
              raise "not off" if !states.include?(env[:machine].state.id)
            end
          else

            env[:ui].info @translator.t("not_active_or_new")
          end

          @app.call(env)
        end
      end
    end
  end
end
