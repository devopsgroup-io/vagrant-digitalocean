

module VagrantPlugins
  module DigitalOcean
    module Helpers
      module File
        # TODO the optional exceptions are clumsy
        def read_file(relative_path, except = true)
          content = ""
          path = ::File.join(DigitalOcean.source_root, relative_path)

          begin
            ::File.open(path) do |file|
              content = file.read
            end
          rescue Errno::ENOENT => e
            # ignore the missing file if except is false
            raise(e) if except
          end

          content
        end

        # TODO the optional exceptions are clumsy
        # read a script and match it to the guest operating system
        def read_script(dir, guest, except = true)
          script_dir = ::File.join("scripts", dir)
          guest_name = guest.class.to_s

          if guest_name =~ /Debian/ || guest_name =~ /Ubuntu/
            read_file(::File.join(script_dir, "debian.sh"), except)
          elsif guest_name =~ /RedHat/
            read_file(::File.join(script_dir, "redhat.sh"), except)
          else
            raise "unsupported guest operating system" if except
          end
        end
      end
    end
  end
end
