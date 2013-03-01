require "vagrant"
require "vagrant-digitalocean/version"
require "vagrant-digitalocean/plugin"
require "vagrant-digitalocean/errors"

module VagrantPlugins
  module DigitalOcean
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
