module VagrantPlugins
  module DigitalOcean
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :client_id, :api_key, :image, :region, :size, :ca_path

      def initialize
        @client_id       = UNSET_VALUE
        @api_key         = UNSET_VALUE
        @image           = UNSET_VALUE
        @region          = UNSET_VALUE
        @size            = UNSET_VALUE
        @ca_path         = UNSET_VALUE
      end

      def finalize!
        @client_id = ENV["DO_CLIENT_ID"] if @client_id == UNSET_VALUE
        @api_key   = ENV["DO_API_KEY"] if @api_key == UNSET_VALUE
        @image     = "Ubuntu 12.04 x32 Server" if @image == UNSET_VALUE
        @region    = "New York 1" if @region == UNSET_VALUE
        @size      = "512MB" if @size == UNSET_VALUE
        @ca_path   = nil if @ca_path == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << "Client ID required" if !@client_id
        errors << "API Key required" if !@api_key

        { "Digital Ocean Provider" => errors }
      end
    end
  end
end
