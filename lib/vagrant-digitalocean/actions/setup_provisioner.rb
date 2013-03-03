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
          env[:machine].communicate.sudo(chef_repo)
          env[:machine].communicate.sudo(chef_install)
          @app.call(env)
        end

        def chef_repo
          read_file(::File.join("scripts", "chef", "apt_setup.sh"))
        end

        def chef_install
          read_file(::File.join("scripts", "chef", "apt_install.sh"))
        end
      end
    end
  end
end
