require "socket"

module VagrantPlugins
  module DigitalOcean
    module Actions
      class SetupNFS
        include Helpers::File

        def initialize(app, env)
          @app, @env = app, env
        end

        def call(env)
          # set the nfs machine ip
          env[:nfs_machine_ip] = env[:machine].provider.ssh_info[:host]

          # get the host ip from the local adapters
          env[:nfs_host_ip] = determine_host_ip.ip_address

          # TODO sort out tty requirement on centos so we can use sudo
          # make sure the nfs server is setup
          env[:machine].communicate.execute(nfs_install(env[:machine].guest))

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

        # TODO this definitely sucks, hopefully we can extend the guest
        #      at some point or just use subdirectories
        def nfs_install(guest)
          script_dir = ::File.join("scripts", "nfs")
          guest_name = guest.class.to_s
          if guest_name =~ /Debian/
            read_file(::File.join(script_dir, "apt_install.sh"))
          elsif guest_name =~ /RedHat/
            read_file(::File.join(script_dir, "rpm_install.sh"))
          else
            raise "unsupported guest operating system"
          end
        end
      end
    end
  end
end
