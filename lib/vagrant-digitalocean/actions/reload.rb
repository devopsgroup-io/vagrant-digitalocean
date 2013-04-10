require 'vagrant-digitalocean/helpers/client'

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Reload
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::digitalocean::reload')
        end

        def call(env)
          # submit reboot droplet request
          result = @client.request("/droplets/#{@machine.id}/reboot")

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_digital_ocean.info.reloading')
          @client.wait_for_event(env, result['event_id'])

          @app.call(env)
        end
      end
    end
  end
end


