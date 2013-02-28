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

        def find_id(sub_obj, search)
          find(sub_obj, search)["id"]
        end

        def find(sub_obj, search)
          key = search.keys.first
          value = search[key].to_s
          key = key.to_s

          result = @result[sub_obj.to_s].inject(nil) do |result, obj|
            obj[key] == value ? obj : result
          end

          result || error(sub_obj, key, value)
        end

        def error(sub_obj, key, value)
          raise "No id matches the #{key} for '#{value}' for #{sub_obj}"
        end
      end
    end
  end
end
