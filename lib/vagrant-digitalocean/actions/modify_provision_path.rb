module VagrantPlugins
  module DigitalOcean
    module Actions
      class ModifyProvisionPath
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger =
            Log4r::Logger.new('vagrant::digitalocean::modify_provision_path')
        end

        def call(env)
          # check if provisioning is enabled
          enabled = true
          enabled = env[:provision_enabled] if env.has_key?(:provision_enabled)
          return @app.call(env) if !enabled

          username = @machine.ssh_info()[:username]

          # change ownership of the provisioning path recursively to the
          # ssh user
          #
          # TODO submit patch to vagrant to set appropriate permissions
          # based on ssh username
          @machine.config.vm.provisioners.each do |provisioner|
            cfg = provisioner.config
            path = cfg.upload_path if cfg.respond_to? :upload_path
            path = cfg.provisioning_path if cfg.respond_to? :provisioning_path
            @machine.communicate.sudo("chown -R #{username} #{path}",
              :error_check => false)
          end

          @app.call(env)
        end
      end
    end
  end
end
