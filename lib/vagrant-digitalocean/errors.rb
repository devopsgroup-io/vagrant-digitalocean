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

      class ResultMatchError < DigitalOceanError
        error_key(:result_match)
      end

      class CertificateError < DigitalOceanError
        error_key(:certificate)
      end

      class LocalIPError < DigitalOceanError
        error_key(:local_ip)
      end

      class PublicKeyError < DigitalOceanError
        error_key(:public_key)
      end

      class RsyncError < DigitalOceanError
        error_key(:rsync)
      end
    end
  end
end
