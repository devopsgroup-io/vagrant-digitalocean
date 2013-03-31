module VagrantPlugins
  module DigitalOcean
    module Actions
      class CheckSSHUser
        include Vagrant::Util::Counter

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @translator = Helpers::Translator.new("actions.check_ssh_user")
        end

        def call(env)
          # return if the machine is set with the default ssh username
          return @app.call(env) if @machine.ssh_info()[:username] == "root"

          # check if ssh username account has been provisioned
          begin
            tries = @machine.config.ssh.max_tries
            @machine.config.ssh.max_tries = 0
            @machine.communicate.execute("echo")
          rescue Vagrant::Errors::SSHAuthenticationFailed
            original_username = @machine.ssh_info()[:username]
            @machine.provider_config.ssh_username = "root"
            env[:ui].info @translator.t('fallback', {
              :user => original_username
            })

            # TODO remove when vagrant chef provisioning defect fixed
            @machine.config.ssh.username = "root"
          end

          @machine.config.ssh.max_tries = tries

          @app.call(env)

          # reset ssh username
          @machine.provider_config.ssh_username = original_username

          # TODO remove when vagrant chef provisioning defect fixed
          @machine.config.ssh.username = original_username
        end
      end
    end
  end
end
