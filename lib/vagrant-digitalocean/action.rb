require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/read_state"
require "vagrant-digitalocean/actions/setup_provisioner"
require "vagrant-digitalocean/actions/setup_sudo"
require "vagrant-digitalocean/actions/setup_user"
require "vagrant-digitalocean/actions/create"
require "vagrant-digitalocean/actions/setup_ssh_key"
require "vagrant-digitalocean/actions/sync_folders"
require "vagrant-digitalocean/actions/rebuild"

module VagrantPlugins
  module DigitalOcean
    class Action
      # Include the built-in callable actions, eg SSHExec
      include Vagrant::Action::Builtin

      def action(name)
        send(name)
      end

      def destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::Destroy
        end
      end

      def read_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::ReadState
        end
      end

      def ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use SSHExec
        end
      end

      def provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate

          # sort out sudo for redhat, etc
          builder.use Actions::SetupSudo

          # execute provisioners
          builder.use Provision

          builder.use Actions::SetupProvisioner

          builder.use Actions::SyncFolders
        end
      end

      def up
        # TODO figure out when to exit if the vm is created
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate

          builder.use Actions::SetupSSHKey

          # build the vm if necessary
          builder.use Actions::Create

          builder.use provision
        end
      end

      def rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Actions::Rebuild
          builder.use provision
        end
      end
    end
  end
end
