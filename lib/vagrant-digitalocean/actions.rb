require "vagrant-digitalocean/actions/check_state"
require "vagrant-digitalocean/actions/create"
require "vagrant-digitalocean/actions/destroy"
require "vagrant-digitalocean/actions/power_off"
require "vagrant-digitalocean/actions/power_on"
require "vagrant-digitalocean/actions/rebuild"
require "vagrant-digitalocean/actions/reload"
require "vagrant-digitalocean/actions/setup_sudo"
require "vagrant-digitalocean/actions/setup_provisioner"
require "vagrant-digitalocean/actions/setup_ssh_key"
require "vagrant-digitalocean/actions/sync_folders"
require "vagrant-digitalocean/actions/modify_provision_path"

module VagrantPlugins
  module DigitalOcean
    module Actions
      include Vagrant::Action::Builtin

      def self.translator
        @@translator ||= Helpers::Translator.new("actions")
      end

      def self.destroy
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

      def self.ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use SSHExec
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def self.ssh_run
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use SSHRun
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def self.provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Provision
              b.use SetupSudo
              b.use SetupProvisioner
              b.use ModifyProvisionPath
              b.use SyncFolders
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              env[:ui].info translator.t("already_active")
            when :off
              b.use PowerOn
              b.use provision
            when :not_created
              b.use SetupSSHKey
              b.use Create
              b.use provision
            end
          end
        end
      end

      def self.halt
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

      def self.reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Reload
              b.use provision
            when :off
              env[:ui].info translator.t("off")
            when :not_created
              env[:ui].info translator.t("not_created")
            end
          end
        end
      end

      def self.rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Rebuild
              b.use provision
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
