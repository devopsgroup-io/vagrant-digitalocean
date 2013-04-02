require "vagrant/util/subprocess"

module VagrantPlugins
  module DigitalOcean
    module Actions
      # This middleware uses `rsync` to sync the folders over to the
      # Digital Ocean instance. The implementation was lifted from the
      # vagrant-aws provider plugin.
      class SyncFolders
        def initialize(app, env)
          @app, @env = app, env
          @translator = Helpers::Translator.new("actions.sync_folders")
        end

        def call(env)
          @app.call(env)

          ssh_info = env[:machine].ssh_info

          env[:machine].config.vm.synced_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]

            # Make sure there is a trailing slash on the host path to
            # avoid creating an additional directory with rsync
            hostpath = "#{hostpath}/" if hostpath !~ /\/$/

            env[:ui].info @translator.t("rsync_folder",
                                        :hostpath => hostpath,
                                        :guestpath => guestpath)

            # Create the guest path
            env[:machine].communicate.sudo("mkdir -p #{guestpath}")
            env[:machine].communicate.sudo(
              "chown -R #{ssh_info[:username]} #{guestpath}")

            # Rsync over to the guest path using the SSH info
            command = [
              "rsync", "--verbose", "--archive", "-z",
              "-e", "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no -i '#{ssh_info[:private_key_path]}'",
              hostpath,
              "#{ssh_info[:username]}@#{ssh_info[:host]}:#{guestpath}"]

            r = Vagrant::Util::Subprocess.execute(*command)
            if r.exit_code != 0
              raise Errors::RsyncError,
                :guestpath => guestpath,
                :hostpath => hostpath,
                :stderr => r.stderr
            end
          end
        end
      end
    end
  end
end
