require "vagrant-digitalocean/actions/check_state"
require "vagrant-digitalocean/actions/create"
require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/power_off"
require "vagrant-digitalocean/actions/power_on"
require "vagrant-digitalocean/actions/rebuild"
require "vagrant-digitalocean/actions/reload"
require "vagrant-digitalocean/actions/check_ssh_user"
require "vagrant-digitalocean/actions/setup_sudo"
require "vagrant-digitalocean/actions/setup_provisioner"
require "vagrant-digitalocean/actions/setup_ssh_key"
require "vagrant-digitalocean/actions/sync_folders"
require "vagrant-digitalocean/actions/modify_provision_path"

module VagrantPlugins
  module DigitalOcean
    module Actions
      include Vagrant::Action::Builtin

      def action_destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info translator.t("not_created")
            else
              b.use Destroy 
            end
          end
        end
      end

      def action_ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use CheckSSHUser
              b.use SSHExec
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def action_provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use CheckSSHUser
              b.use ModifyProvisionPath
              b.use Provision
              b.use SetupSudo
              b.use SetupProvisioner
              b.use SyncFolders
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def action_up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              env[:ui].info translator.t("already_active")
            when :off
              b.use PowerOn
              b.use action_provision
            when :not_created
              b.use SetupSSHKey
              b.use Create
              b.use action_provision
            end
          end
        end
      end

      def action_halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use PowerOff
            when :off
              env[:ui].info translator.t("already_off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def action_reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Reload
              b.use action_provision
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def action_rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Rebuild
              b.use action_provision
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end
    end
  end
end
