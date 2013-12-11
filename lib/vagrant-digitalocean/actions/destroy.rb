require 'vagrant-digitalocean/helpers/client'

module VagrantPlugins
  module DigitalOcean
    module Actions
      class Destroy
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::digitalocean::destroy')
        end

        def call(env)
          # submit destroy droplet request
          result = @client.request("/droplets/#{@machine.id}/destroy")

          env[:ui].info I18n.t('vagrant_digital_ocean.info.destroying')

          # wait for the destroy progress to start
          @client.wait_for_event(env, result['event_id']) do |response|
            break if response['event']['percentage'] != nil
          end

          # set the machine id to nil to cleanup local vagrant state
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
