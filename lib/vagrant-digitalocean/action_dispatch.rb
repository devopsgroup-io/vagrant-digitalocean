require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/prepare_nfs"
require "vagrant-digitalocean/actions/read_state"
require "vagrant-digitalocean/actions/setup_user"
require "vagrant-digitalocean/actions/up"

module VagrantPlugins
  module DigitalOcean
    class ActionDispatch
      # Include the built-in callable actions, eg SSHExec
      include Vagrant::Action::Builtin

      def action(name)
        send(name)
      end

      def up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate

          # build the vm if necessary
          builder.use Actions::Up

          # make sure the configured user is setup
          builder.use Actions::SetupUser

          # set the host and remote ips for NFS
          builder.use Actions::PrepareNFS

          # mount the nfs folders
          builder.use NFS
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

      def destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::Destroy
        end
      end
    end
  end
end
