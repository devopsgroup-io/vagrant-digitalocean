require 'vagrant-digitalocean/helpers/client'

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Create
        include Helpers::Client
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::digitalocean::create')
        end

        def call(env)
          ssh_key_id = [env[:ssh_key_id]]

          image_id = @client
            .request('/v2/images')
            .find_id(:images, :name => @machine.provider_config.image)

          # submit new droplet request
          result = @client.post('/v2/droplets', {
            :size => @machine.provider_config.size,
            :region => @machine.provider_config.region,
            :image => image_id,
            :name => @machine.config.vm.hostname || @machine.name,
            :ssh_keys => ssh_key_id,
            :private_networking => @machine.provider_config.private_networking,
            :backups_enabled => @machine.provider_config.backups_enabled
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_digital_ocean.info.creating') 
          @client.wait_for_event(env, result['droplet']['action_ids'].first)

          # assign the machine id for reference in other commands
          @machine.id = result['droplet']['id'].to_s

          # refresh droplet state with provider and output ip address
          droplet = Provider.droplet(@machine, :refresh => true)
          public_network = droplet['networks']['v4'].find { |network| network['type'] == 'public' }
          private_network = droplet['networks']['v4'].find { |network| network['type'] == 'private' }
          env[:ui].info I18n.t('vagrant_digital_ocean.info.droplet_ip', {
            :ip => public_network['ip_address']
          })
          if private_network
            env[:ui].info I18n.t('vagrant_digital_ocean.info.droplet_private_ip', {
              :ip => private_network['ip_address']
            })
          end

          # wait for ssh to be ready
          switch_user = @machine.provider_config.setup?
          user = @machine.config.ssh.username
          @machine.config.ssh.username = 'root' if switch_user

          retryable(:tries => 120, :sleep => 10) do
            next if env[:interrupted]
            raise 'not ready' if !@machine.communicate.ready?
          end

          @machine.config.ssh.username = user

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)

          if @machine.state.id != :not_created
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Actions.destroy, destroy_env)
        end
      end
    end
  end
end
