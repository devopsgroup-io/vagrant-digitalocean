module VagrantPlugins
  module DigitalOcean
    module Actions
      class ModifyProvisionPath
        include Vagrant::Util::Counter

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @translator =
            Helpers::Translator.new("actions.modify_provision_path")
        end

        def call(env)
          # check if provisioning is enabled
          enabled = true
          enabled = env[:provision_enabled] if env.has_key?(:provision_enabled)
          return @app.call(env) if !enabled

          username = @machine.ssh_info()[:username]
          env[:ui].info @translator.t("modify", { :user => username })

          # modify provisioning paths to enable different users to
          # provision the same machine
          #
          # TODO submit patch to vagrant to set appropriate permissions
          # based on ssh username
          @machine.communicate.execute("mkdir -p /home/#{username}/tmp")
          env[:global_config].vm.provisioners.each do |prov|
            if prov.name == :shell
              prov.config.upload_path =
                prov.config.upload_path.prepend("/home/#{username}")
            else
              counter = get_and_update_counter(:provisioning_path)
              path = "/home/#{username}/tmp/vagrant-chef-#{counter}"
              prov.config.provisioning_path = path
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
