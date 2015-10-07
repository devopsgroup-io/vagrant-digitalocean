require 'optparse'
require 'vagrant-digitalocean/helpers/client'

module VagrantPlugins
  module DigitalOcean
    module Commands
      class List < Vagrant.plugin('2', :command)
        def self.synopsis
          "list available images and regions from DigitalOcean"
        end

        def execute
          @token = nil

          @opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant digitalocean-list [options] <images|regions|sizes> <token>'

            o.on("-r", "--[no-]regions", "show the regions when listing images") do |r|
              @regions = r
            end
          end

          argv = parse_options(@opts)
          @token = argv[1]

          if @token.nil?
            usage
            return 1
          end

          case argv[0]
          when "images"
            result = query('/v2/images')
            images = Array(result["images"])
            if @regions
              images_table = images.map do |image|
                '%-50s %-20s %-20s %-50s' % ["#{image['distribution']} #{image['name']}", image['slug'], image['id'], image['regions'].join(', ')]
              end
              @env.ui.info I18n.t('vagrant_digital_ocean.info.images_with_regions', images: images_table.sort.join("\r\n"))
            else
              images_table = images.map do |image|
                '%-50s %-30s %-30s' % ["#{image['distribution']} #{image['name']}", image['slug'], image['id']]
              end
              @env.ui.info I18n.t('vagrant_digital_ocean.info.images', images: images_table.sort.join("\r\n"))
            end
          when "regions"
            result = query('/v2/regions')
            regions = Array(result["regions"])
            regions_table = regions.map { |region| '%-30s %-12s' % [region['name'], region['slug']] }
            @env.ui.info I18n.t('vagrant_digital_ocean.info.regions', regions: regions_table.sort.join("\r\n"))
          when "sizes"
            result = query('/v2/sizes')
            sizes = Array(result["sizes"])
            sizes_table = sizes.map { |size| '%-15s %-15s %-12s' % ["#{size['memory']}MB", size['vcpus'], size['slug']] }
            @env.ui.info I18n.t('vagrant_digital_ocean.info.sizes', sizes: sizes_table.sort_by{|s| s['memory']}.join("\r\n"))
          else
            usage
            return 1
          end

          0
        rescue Faraday::Error::ConnectionFailed, RuntimeError => e
          @env.ui.error I18n.t('vagrant_digital_ocean.info.list_error', message: e.message)
          1
        end

        def query(path)
          connection = Faraday.new({
            :url => "https://api.digitalocean.com/"
          })

          result = connection.get(path, per_page: 100) do |req|
            req.headers['Authorization'] = "Bearer #{@token}"
          end

          case result.status
          when 200 then JSON.parse(result.body)
          when 401 then raise("unauthorized access — is the token correct?")
          else raise("call returned with status #{result.status}")
          end
        end

        def usage
          @env.ui.info(@opts)
        end
      end
    end
  end
end
