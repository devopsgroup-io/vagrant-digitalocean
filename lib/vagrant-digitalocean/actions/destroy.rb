require "vagrant-digitalocean/helpers/client"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app, @env = app, env
          @client = Helpers::Client.new(env[:machine].provider_config.ca_path)
          @translator = Helpers::Translator.new("actions.destroy")
        end

        def call(env)
          # TODO remove the key associated with this machine
          if [:active, :new].include?(env[:machine].state.id)
            env[:ui].info @translator.t("destroying")
            result = @client.request("/droplets/#{env[:machine].id}/destroy")

            env[:ui].info @translator.t("wait_off")

            retryable(:tries => 30, :sleep => 10) do
              # If we're interrupted don't worry about waiting
              next if env[:interrupted]

              # Wait for the server to be ready
              raise "not off" if env[:machine].state.id != :off
            end
          else
            env[:ui].info @translator.t("not_active_or_new")
          end

          # make sure to remove the export when the machine is destroyed
          # private in some hosts and requires a send
          env[:ui].info @translator.t("clean_nfs")
          env[:host].send(:nfs_cleanup, env[:machine].id)

          @app.call(env)
        end
      end
    end
  end
end
