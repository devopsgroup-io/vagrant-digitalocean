

module VagrantPlugins
  module DigitalOcean
    module Helpers
      module File
        def read_file(relative_path)
          content = ""
          path = ::File.join(DigitalOcean.source_root, relative_path)

          ::File.open(path) do |file|
            content = file.read
          end

          content
        end
      end
    end
  end
end
