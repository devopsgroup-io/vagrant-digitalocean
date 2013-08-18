module VagrantPlugins
  module DigitalOcean
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :client_id
      attr_accessor :api_key
      attr_accessor :image
      attr_accessor :region
      attr_accessor :size
      attr_accessor :ca_path
      attr_accessor :ssh_key_name

      def initialize
        @client_id    = UNSET_VALUE
        @api_key      = UNSET_VALUE
        @image        = UNSET_VALUE
        @region       = UNSET_VALUE
        @size         = UNSET_VALUE
        @ca_path      = UNSET_VALUE
        @ssh_key_name = UNSET_VALUE
      end

      def finalize!
        @client_id    = ENV['DO_CLIENT_ID'] if @client_id == UNSET_VALUE
        @api_key      = ENV['DO_API_KEY'] if @api_key == UNSET_VALUE
        @image        = 'Ubuntu 12.04 x64' if @image == UNSET_VALUE
        @region       = 'New York 2' if @region == UNSET_VALUE
        @size         = '512MB' if @size == UNSET_VALUE
        @ca_path      = nil if @ca_path == UNSET_VALUE
        @ssh_key_name = 'Vagrant' if @ssh_key_name == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_digital_ocean.config.client_id') if !@client_id
        errors << I18n.t('vagrant_digital_ocean.config.api_key') if !@api_key

        key = machine.config.ssh.private_key_path
        if !key
          errors << I18n.t('vagrant_digital_ocean.config.private_key')
        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
          errors << I18n.t('vagrant_digital_ocean.config.public_key', {
            :key => "#{key}.pub"
          })
        end

        { 'Digital Ocean Provider' => errors }
      end
    end
  end
end
