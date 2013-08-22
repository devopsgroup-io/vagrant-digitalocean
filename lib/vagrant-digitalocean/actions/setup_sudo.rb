module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupSudo
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::digitalocean::setup_sudo')
        end

        def call(env)
          # check if setup is enabled
          return @app.call(env) unless @machine.provider_config.setup?

          # override ssh username to root
          user = @machine.config.ssh.username
          @machine.config.ssh.username = 'root'

          # check for guest name available in Vagrant 1.2 first
          guest_name = @machine.guest.name if @machine.guest.respond_to?(:name)
          guest_name ||= @machine.guest.to_s.downcase

          case guest_name
          when /redhat/
            env[:ui].info I18n.t('vagrant_digital_ocean.info.modifying_sudo')

            # disable tty requirement for sudo
            @machine.communicate.execute(<<-'BASH')
              sed -i'.bk' -e 's/\(Defaults\s\+requiretty\)/# \1/' /etc/sudoers
            BASH
          end

          # reset ssh username
          @machine.config.ssh.username = user

          @app.call(env)
        end
      end
    end
  end
end
