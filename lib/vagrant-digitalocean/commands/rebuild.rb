require 'optparse'

module VagrantPlugins
  module DigitalOcean
    module Commands
      class Rebuild < Vagrant.plugin('2', :command)
        def execute
          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant rebuild [vm-name]'
          end

          argv = parse_options(opts)

          with_target_vms(argv) do |machine|
            machine.action(:rebuild)
          end

          0
        end
      end
    end
  end
end
