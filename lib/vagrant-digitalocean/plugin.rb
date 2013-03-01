module VagrantPlugins
  module DigitalOcean
    class Plugin < Vagrant.plugin("2")
      name "DigitalOcean"
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines using DigitalOcean's API.
      DESC

      config(:digital_ocean, :provider) do
        require_relative "config"
        Config
      end

      provider(:digital_ocean) do
        # Return the provider
        require_relative "provider"

        I18n.load_path << File.expand_path("locales/en.yml", DigitalOcean.source_root)
        I18n.reload!

        Provider
      end
    end
  end
end
