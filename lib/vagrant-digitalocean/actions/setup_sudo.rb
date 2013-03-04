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

          if env[:machine].guest.class.to_s =~ /RedHat/
            script = read_file(::File.join(script_dir, "redhat.sh"))
            env[:machine].communicate.execute(script)
          end

          @app.call(env)
        end
      end
    end
  end
end
