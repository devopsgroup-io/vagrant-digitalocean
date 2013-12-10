require 'vagrant-digitalocean/helpers/result'
require 'faraday'
require 'json'

module VagrantPlugins
  module DigitalOcean
    module Helpers
      module Client
        def client
          @client ||= ApiClient.new(@machine)
        end
      end

      class ApiClient
        include Vagrant::Util::Retryable

        def initialize(machine)
					@logger = Log4r::Logger.new('vagrant::digitalocean::apiclient')
          @config = machine.provider_config
          @client = Faraday.new({
            :url => 'https://api.digitalocean.com/',
            :ssl => {
              :ca_file => @config.ca_path
            }
          })
        end

        def request(path, params = {})
          begin
						@logger.info "Request: #{path}"
            result = @client.get(path, params = params.merge({
              :client_id => @config.client_id,
              :api_key => @config.api_key
            }))
          rescue Faraday::Error::ConnectionFailed => e
            # TODO this is suspect but because farady wraps the exception
            #      in something generic there doesn't appear to be another
            #      way to distinguish different connection errors :(
            if e.message =~ /certificate verify failed/
              raise Errors::CertificateError
            end

            raise e
          end

          # remove the api key in case an error gets dumped to the console
          params[:api_key] = 'REMOVED'

          begin
            body = JSON.parse(result.body)
						@logger.info "Response: #{body}"
          rescue JSON::ParserError => e
            raise(Errors::JSONError, {
              :message => e.message,
              :path => path,
              :params => params,
              :response => result.body
            })
          end

          if body['status'] != 'OK'
            raise(Errors::APIStatusError, {
              :path => path,
              :params => params,
              :status => body['status'],
              :response => body.inspect
            })
          end

          Result.new(body)
        end

        def wait_for_event(env, id)
          retryable(:tries => 120, :sleep => 10) do
            # stop waiting if interrupted
            next if env[:interrupted]

            # check event status
            result = self.request("/events/#{id}")

            yield result if block_given?
            raise 'not ready' if result['event']['action_status'] != 'done'
          end
        end
      end
    end
  end
end
