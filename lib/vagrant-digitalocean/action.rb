require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/read_state"
require "vagrant-digitalocean/actions/setup_provisioner"
require "vagrant-digitalocean/actions/setup_sudo"
require "vagrant-digitalocean/actions/create"
require "vagrant-digitalocean/actions/setup_ssh_key"
require "vagrant-digitalocean/actions/sync_folders"
require "vagrant-digitalocean/actions/rebuild"
require "vagrant-digitalocean/actions/is_active"
require "vagrant-digitalocean/actions/message_is_active"
require "vagrant-digitalocean/actions/check_ssh_user"
require "vagrant-digitalocean/actions/modify_provision_path"

module VagrantPlugins
  module DigitalOcean
    class Action
      include Vagrant::Action::Builtin

      def action(name)
        send(name)
      end

      def destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Actions::IsActive do |env, b|
            if !env[:is_active]
              b.use Actions::MessageIsActive
              next
            end
            b.use Actions::Destroy
          end
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
          builder.use Call, Actions::IsActive do |env, b|
            if !env[:is_active]
              b.use Actions::MessageIsActive
              next
            end
            b.use Actions::CheckSSHUser
            b.use SSHExec
          end
        end
      end

      def provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Actions::IsActive do |env, b|
            if !env[:is_active]
              b.use Actions::MessageIsActive
              next
            end
            b.use Actions::CheckSSHUser
            b.use Actions::ModifyProvisionPath
            b.use Provision
            b.use Actions::SetupSudo
            b.use Actions::SetupProvisioner
            b.use Actions::SyncFolders
          end
        end
      end

      def up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Actions::IsActive do |env, b|
            if env[:is_active]
              b.use Actions::MessageIsActive
              next
            end
            b.use Actions::SetupSSHKey
            b.use Actions::Create
            b.use provision
          end
        end
      end

      def rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Actions::IsActive do |env, b|
            if !env[:is_active]
              b.use Actions::MessageIsActive
              next
            end
            b.use Actions::Rebuild
            b.use provision
          end
        end
      end
    end
  end
end
