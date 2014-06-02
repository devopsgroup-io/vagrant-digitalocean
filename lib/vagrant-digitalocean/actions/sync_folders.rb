require 'vagrant/util/subprocess'
require 'vagrant/util/which'

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SyncFolders
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::digitalocean::sync_folders')
        end

        def call(env)
          ssh_info = @machine.ssh_info

          @machine.config.vm.synced_folders.each do |id, data|
            next if data[:disabled]

            unless Vagrant::Util::Which.which('rsync')
              env[:ui].warn I18n.t('vagrant_digital_ocean.info.rsync_missing')
              break
            end

            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]

            # make sure there is a trailing slash on the host path to
            # avoid creating an additional directory with rsync
            hostpath = "#{hostpath}/" if hostpath !~ /\/$/

            # on windows rsync.exe requires cygdrive-style paths
            if Vagrant::Util::Platform.windows?
              hostpath = hostpath.gsub(/^(\w):/) { "/cygdrive/#{$1}" }
            end

            env[:ui].info I18n.t('vagrant_digital_ocean.info.rsyncing', {
              :hostpath => hostpath,
              :guestpath => guestpath
            })

            # create the guest path
            @machine.communicate.sudo("mkdir -p #{guestpath}")
            @machine.communicate.sudo(
              "chown -R #{ssh_info[:username]} #{guestpath}")

            key = ssh_info[:private_key_path]
            key = key[0] if key.is_a?(Array)

            # rsync over to the guest path using the ssh info
            command = [
              "rsync", "--verbose", "--archive", "-z", "--delete",
              "-e", "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no -i '#{key}'",
              hostpath,
              "#{ssh_info[:username]}@#{ssh_info[:host]}:#{guestpath}"]

            # we need to fix permissions when using rsync.exe on windows, see
            # http://stackoverflow.com/questions/5798807/rsync-permission-denied-created-directories-have-no-permissions
            if Vagrant::Util::Platform.windows?
              command.insert(1, "--chmod", "ugo=rwX")
            end

            r = Vagrant::Util::Subprocess.execute(*command)
            if r.exit_code != 0
              raise Errors::RsyncError,
                :guestpath => guestpath,
                :hostpath => hostpath,
                :stderr => r.stderr
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
