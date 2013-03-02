require "vagrant"
require "vagrant-digitalocean/version"
require "vagrant-digitalocean/plugin"
require "vagrant-digitalocean/errors"

module VagrantPlugins
  module DigitalOcean
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    def self.vagrant_key
      file = File.open(Vagrant.source_root + "keys/vagrant.pub")
      key = file.read
      file.close
      key
    end
  end
end
