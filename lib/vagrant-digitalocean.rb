require "vagrant"
require "vagrant-digitalocean/version"
require "vagrant-digitalocean/plugin"


module VagrantPlugins
  module DigitalOcean
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
