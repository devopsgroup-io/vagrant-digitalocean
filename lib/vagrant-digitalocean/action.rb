require "vagrant-digitalocean/actions/up"

module VagrantPlugins
  module DigitalOcean
    class Action
      def initialize(config)
        @config = config
      end

      def action(name)
        send(name)
      end

      def up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use Actions::Up
        end
      end
    end
  end
end
