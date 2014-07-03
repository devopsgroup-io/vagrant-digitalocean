require 'vagrant-digitalocean/helpers/client'
#TODO: --force
module VagrantPlugins
  module DigitalOcean
    module Actions
      class PowerOff
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::digitalocean::power_off')
        end

        def call(env)
          # submit power off droplet request
          result = @client.post("/v2/droplets/#{@machine.id}/actions", {
            :type => 'power_off'
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_digital_ocean.info.powering_off')
          @client.wait_for_event(env, result['action']['id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end

