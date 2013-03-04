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
          # TODO sort out tty requirement on centos so we can use sudo
          env[:machine].communicate.execute(chef_install(env[:machine].guest))

          @app.call(env)
        end

        def chef_install(guest)
          script_dir = ::File.join("scripts", "chef")
          guest_name = guest.class.to_s

          if guest_name =~ /Debian/
            read_file(::File.join(script_dir, "apt_install.sh"))
          elsif guest_name =~ /RedHat/
            read_file(::File.join(script_dir, "rpm_install.sh"))
          else
            raise "unsupported guest operating system"
          end
        end
      end
    end
  end
end
