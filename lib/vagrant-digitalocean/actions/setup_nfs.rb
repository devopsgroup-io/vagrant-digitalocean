require "socket"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupNFS
        def initialize(app, env)
          @app, @env = app, env
        end

        def call(env)
          # set the nfs machine ip
          env[:nfs_machine_ip] = env[:machine].provider.ssh_info[:host]

          # get the host ip from the local adapters
          env[:nfs_host_ip] = determine_host_ip.ip_address

          # make sure the nfs server is setup
          env[:machine].communicate.sudo(<<-BASH)
            if !(which nfsstat); then
              apt-get install -y nfs-kernel-server;
            fi
          BASH

          vm = env[:machine].config.vm

          # force all shard folders to use nfs
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
      end
    end
  end
end
