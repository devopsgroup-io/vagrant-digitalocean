module VagrantPlugins
  module DigitalOcean
    module Helpers
      class Result
        def initialize(body)
          @result = body
        end

        def [](key)
          @result[key.to_s]
        end

        def find_id(sub_obj, search) #:ssh_keys, {:name => 'ijin (vagrant)'}
          find(sub_obj, search)["id"]
        end

        def find(sub_obj, search)
          key = search.keys.first #:slug
          value = search[key].to_s #sfo1
          key = key.to_s #slug

          result = @result[sub_obj.to_s].inject(nil) do |result, obj|
            obj[key] == value ? obj : result
          end

          result || error(sub_obj, key, value)
        end

        def error(sub_obj, key, value)
          raise(Errors::ResultMatchError, {
           :key => key,
           :value => value,
           :collection_name => sub_obj.to_s,
           :sub_obj => @result[sub_obj.to_s]
          })
        end
      end
    end
  end
end
