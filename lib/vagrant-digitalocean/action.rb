require "vagrant-digitalocean/actions/up"
require "vagrant-digitalocean/actions/read_state"

module VagrantPlugins
  module DigitalOcean
    class Action
      # Include the built-in callable actions, eg SSHExec
      include Vagrant::Action::Builtin

      def initialize(config)
        @config = config
      end

      def action(name)
        send(name)
      end

      def up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::Up
        end
      end

      def ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use SSHExec
        end
      end

      def read_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::ReadState
        end
      end
    end
  end
end
