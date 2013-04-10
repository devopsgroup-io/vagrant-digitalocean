module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupUser
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::digitalocean::setup_user')
        end

        def call(env)
          # check if a username has been specified
          return @app.call(env) if !@machine.config.ssh.username

          # override ssh username to root temporarily
          user = @machine.config.ssh.username
          @machine.config.ssh.username = 'root'

          env[:ui].info I18n.t('vagrant_digital_ocean.info.creating_user', {
            :user => user
          })

          # create user account
          @machine.communicate.execute(<<-BASH)
            if ! (grep #{user} /etc/passwd); then
              useradd -m -s /bin/bash #{user};
            fi
          BASH

          # grant user sudo access with no password requirement
          @machine.communicate.execute(<<-BASH)
            if ! (grep #{user} /etc/sudoers); then
              echo "#{user} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers;
            fi
          BASH

          # create the .ssh directory in the users home
          @machine.communicate.execute("su #{user} -c 'mkdir -p ~/.ssh'")

          # add the specified key to the authorized keys file
          private_key_path = @machine.ssh_info()[:private_key_path]
          pub_key = DigitalOcean.public_key(private_key_path)
          @machine.communicate.execute(<<-BASH)
            if ! grep '#{pub_key}' /home/#{user}/.ssh/authorized_keys; then
              echo '#{pub_key}' >> /home/#{user}/.ssh/authorized_keys;
            fi
          BASH

          # reset username
          @machine.config.ssh.username = user

          @app.call(env)
        end
      end
    end
  end
end
