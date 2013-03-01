require "vagrant"

module VagrantPlugins
  module DigitalOcean
    module Errors
      class DigitalOceanError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_digital_ocean.errors")
      end

      class APIStatusError < DigitalOceanError
        error_key(:api_status)
      end

      class JSONError < DigitalOceanError
        error_key(:json)
      end
    end
  end
end
