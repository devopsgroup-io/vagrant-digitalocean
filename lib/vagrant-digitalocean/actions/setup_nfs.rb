require "socket"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupNFS
        include Helpers::File

        def initialize(app, env)
          @app, @env = app, env
          @translator = Helpers::Translator.new("actions.setup_nfs")
        end

        def call(env)
          # set the nfs machine ip
          env[:nfs_machine_ip] = env[:machine].provider.ssh_info[:host]
          env[:ui].info @translator.t("machine_ip", :ip => env[:nfs_machine_ip])

          # get the host ip from the local adapters
          env[:nfs_host_ip] = determine_host_ip.ip_address
          env[:ui].info @translator.t("host_ip", :ip => env[:nfs_host_ip])

          # make sure the nfs server is setup
          env[:ui].info @translator.t("install")
          env[:machine].communicate.execute(nfs_install(env[:machine].guest))

          vm = env[:machine].config.vm

          # force all shard folders to use nfs
          env[:ui].warn @translator.t("force_shared_folders")
          folders = vm.synced_folders.keys.each do |key|
            vm.synced_folders[key][:nfs] = true
          end

          @app.call(env)
        end

        # http://stackoverflow.com/questions/5029427/ruby-get-local-ip-nix
        # TODO this is currently *nix only according to the above post
        def determine_host_ip
          Socket.ip_address_list.detect do |intf|
            intf.ipv4? &&
              !intf.ipv4_loopback? &&
              !intf.ipv4_multicast? &&
              !intf.ipv4_private?
          end
        end

        def nfs_install(guest)
          read_script("nfs", guest)
        end
      end
    end
  end
end
