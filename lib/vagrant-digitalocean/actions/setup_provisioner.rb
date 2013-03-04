require "vagrant-digitalocean/helpers/file"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupProvisioner
        include Helpers::File

        def initialize(app, env)
          @app, @env = app, env
        end

        def call(env)
          # TODO prevent setup when no chef provisioner declared
          # TODO catch ssh failure and report back on install issues
          env[:machine].communicate.execute(chef_install(env[:machine].guest))

          @app.call(env)
        end

        def chef_install(guest)
          read_script("chef", guest)
        end
      end
    end
  end
end
