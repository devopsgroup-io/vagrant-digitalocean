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
            env[:ui].info "Destroying droplet ..."
            result = @client.request("/droplets/#{env[:machine].id}/destroy")
          else
            env[:ui].info "Droplet not in the `active` or `new` state..."
          end

          # make sure to remove the export when the machine is destroyed
          # private in some hosts and requires a send
          env[:ui].info "Cleaning up NFS exports, may require sudo password ..."
          env[:host].send(:nfs_cleanup, env[:machine].id)

          @app.call(env)
        end
      end
    end
  end
end
