module Islandora
  module Component

    def self.included(base)
      base.extend(ClassMethods)
    end

    def update_from_json(json, extra_values = {}, apply_nested_records = true)
      obj = super

      begin
        json["instances"].each do |instance|
          if instance["instance_type"] == "digital_object"
            ref = instance["digital_object"]["ref"]
            dobj = DigitalObject.get_or_die(JSONModel(:digital_object).id_for(ref))
            DigitalObject.handle_islandora_deposit(dobj) do |client, obj_json, uri|
              payload  = JSON.generate(obj_json)
              response = client.update(uri, payload)

              if response and response.code.to_s == "200"
                Log.info "Islandora metadata updated: #{uri}, #{response.to_hash}, #{response.body}"
              else
                Log.error "Islandora update failed: #{uri}, #{payload}, #{response.inspect}"
              end
            end
          end
        end
      rescue Exception => ex
        Log.error("Islandora integration error: #{ex.message}")
      end

      obj
    end

    module ClassMethods
    end

  end
end
