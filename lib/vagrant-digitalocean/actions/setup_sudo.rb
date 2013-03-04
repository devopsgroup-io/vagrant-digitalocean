require "vagrant-digitalocean/helpers/file"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupSudo
        include Helpers::File

        def initialize(app, env)
          @app, @env = app, env
        end

        def call(env)
          script_dir = ::File.join("scripts", "sudo")
          env[:machine].communicate.execute(fix_sudo(env[:machine].guest))

          @app.call(env)
        end

        def fix_sudo(guest)
          read_script("sudo", guest, false)
        end
      end
    end
  end
end
