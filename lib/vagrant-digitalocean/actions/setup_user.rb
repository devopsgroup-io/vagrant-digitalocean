module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupUser
        def initialize(app, env)
          @app, @env = app, env
          @translator = Helpers::Translator.new("actions.setup_user")
        end

        def call(env)
          # create the user, set the password to username, add to sudoers
          # NOTE assumes group with username is created with useradd
          env[:ui].info @translator.t("create", :user => user)
          env[:machine].communicate.execute(<<-BASH)
            if ! (grep #{user} /etc/passwd); then
              useradd -m -s /bin/bash #{user};
              echo -e "#{user}\n#{user}" | (passwd #{user});
            fi
          BASH

          env[:ui].info @translator.t("sudo", :user => user)
          env[:machine].communicate.execute(<<-BASH)
            if ! (grep #{user} /etc/sudoers); then
              echo "#{user} ALL=(ALL:ALL) ALL" >> /etc/sudoers;
            fi
          BASH

          # create the .ssh directory in the users home
          env[:machine].communicate.execute("su #{user} -c 'mkdir -p ~/.ssh'")

          env[:ui].info @translator.t("key")
          # add the specified key to the authorized keys file
          env[:machine].communicate.execute(<<-BASH)
            if ! grep '#{pub_key}' /home/#{user}/.ssh/authorized_keys; then
              echo '#{pub_key}' >> /home/#{user}/.ssh/authorized_keys;
            fi
          BASH

          env[:machine_state] ||= {}
          env[:machine_state][:user] = user

          @app.call(env)
        end

        private

        # TODO use a config option to allow for alternate users
        def user
          "vagrant"
        end

        # TODO allow for a custom key to specified
        def pub_key
          @key ||= DigitalOcean.vagrant_key
        end
      end
    end
  end
end
