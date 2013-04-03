module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupProvisioner
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @translator = Helpers::Translator.new("actions.setup_provisioner")
        end

        def call(env)
          # check if provisioning is enabled
          enabled = true
          enabled = env[:provision_enabled] if env.has_key?(:provision_enabled)
          return @app.call(env) if !enabled

          # check if a chef provisioner is configured
          provisioners = @machine.config.vm.provisioners
          configured = provisioners.reduce(false) do |c, provisioner|
            provisioner.name =~ /chef/
          end
          return @app.call(env) if !configured

          # check if chef is already installed
          command = "which chef-solo"
          code = @machine.communicate.execute(command, :error_check => false)
          return @app.call(env) if code == 0

          # install chef
          env[:ui].info @translator.t("install", :provisioner => "chef")
          command = "wget -O - http://www.opscode.com/chef/install.sh | bash"
          env[:machine].communicate.sudo(command)

          @app.call(env)
        end
      end
    end
  end
end
