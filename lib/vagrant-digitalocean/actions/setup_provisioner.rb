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
          script_dir = ::File.join("scripts", "chef")
          guest_name = guest.class.to_s

          if guest_name =~ /Debian/ || guest_name =~ /Ubuntu/
            read_file(::File.join(script_dir, "debian.sh"))
          elsif guest_name =~ /RedHat/
            read_file(::File.join(script_dir, "redhat.sh"))
          else
            raise "unsupported guest operating system"
          end
        end
      end
    end
  end
end
