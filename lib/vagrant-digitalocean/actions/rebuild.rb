require 'vagrant-digitalocean/helpers/client'

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Rebuild
        include Helpers::Client
				include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::digitalocean::rebuild')
        end

        def call(env)
          # look up image id
          image_id = @client
            .request('/images')
            .find_id(:images, :name => @machine.provider_config.image)

          # submit rebuild request
          result = @client.request("/droplets/#{@machine.id}/rebuild", {
            :image_id => image_id
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_digital_ocean.info.rebuilding')
          @client.wait_for_event(env, result['event_id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

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
      end
    end
  end
end
