module Islandora
  module Deposits

    def self.included(base)
      base.extend(ClassMethods)
    end

    def update_from_json(json, extra_values = {}, apply_nested_records = true)
      obj = super

      begin
        DigitalObject.handle_islandora_deposit(obj) do |client, obj_json, uri|
          payload  = JSON.generate(obj_json)
          response = client.update(uri, payload)

          if response and response.code.to_s == "200"
            Log.info "Islandora metadata updated: #{uri}, #{response.to_hash}, #{response.body}"
          else
            Log.error "Islandora update failed: #{uri}, #{payload}, #{response.inspect}"
          end
        end
      rescue Exception => ex
        Log.error("Islandora integration error: #{ex.message}")
      end

      obj
    end

    def delete
      obj  = self

      begin
        DigitalObject.handle_islandora_deposit(obj) do |client, obj_json, uri|
          response = client.delete uri

          if response and response.code.to_s == "200"
            Log.info "Islandora delete notification succeeded: #{uri}"
          else
            Log.error "Islandora delete notification failed: #{uri}, #{response.inspect}"
          end
        end
      rescue Exception => ex
        Log.error("Islandora integration error: #{ex.message}")
      end

      super
    end

    module ClassMethods

      # nothing on create for now ...
      # def create_from_json(json, opts = {})
      #   obj = super
      #   # TODO
      #   obj
      # end

      def handle_islandora_deposit(obj, &block)
        json = URIResolver.resolve_references(
          DigitalObject.to_jsonmodel(obj),
          [
            'extents',
            'linked_agents',
            'linked_events',
            'linked_instances',
            'linked_instances::extents',
            'linked_instances::linked_agents',
            'linked_instances::notes',
            'linked_instances::subjects',
            'notes',
            'subjects',
          ]
        )
        json["file_versions"].each do |fv|
          uri    = fv.fetch("file_uri")
          client = Islandora::Client.new(AppConfig[:islandora_config])

          next unless client.uri_eligible?(uri)
          next unless client.agent_eligible?(json['linked_agents'])
          next unless client.event_eligible?(json['linked_events'], uri)

          yield client, json, uri
        end
      end

      def find_event_for(id, event_type)
      json = URIResolver.resolve_references(DigitalObject.to_jsonmodel(
        DigitalObject.get_or_die(id)
      ), ['linked_events'])
      event = json["linked_events"].find { |e| e["_resolved"]["event_type"] == event_type }
      event ? Event.get_or_die(JSONModel(:event).id_for(event["ref"])) : nil
      end

      # Islandora::Deposits.find_by_file_uri
      def find_by_file_uri(file_uri)
        fv = find_file_version_by_file_uri(file_uri)
        fv ? DigitalObject.get_or_die(fv.digital_object_id) : nil
      end

      # Islandora::Deposits.find_file_version_by_file_uri
      def find_file_version_by_file_uri(file_uri)
        FileVersion[:file_uri => file_uri]
      end

      # Islandora::Deposits.create_islandora_ingest_event
      def create_islandora_ingest_event(digital_object_uri, agent_uri, identifier, uri)
        create_software_event("ingestion", "pass", digital_object_uri, agent_uri, identifier, uri)
      end

      # Islandora::Deposits.create_islandora_delete_event
      def create_islandora_delete_event(digital_object_uri, agent_uri)
        create_software_event("deletion", "pass", digital_object_uri, agent_uri)
      end

      # Islandora::Deposits.create_software_event
      def create_software_event(type, outcome, digital_object_uri, agent_uri, identifier = nil, uri = nil)
        event = {
          "event_type"   => type,
          "outcome"      => outcome,
          "outcome_note" => digital_object_uri,
          "date"       => {
            "date_type" => "single",
            "label"     => "event",
            "begin"     => Time.now.strftime("%Y-%m-%d")
          },
          "linked_records" => [
            # need the agent so that deletes to object don't create an invalid (on update) event
            {
              "role" => "source",
              "ref"  => agent_uri
            },
            {
              "role" => "source",
              "ref"  => digital_object_uri
            }
          ],
          "linked_agents" => [{
            "role" => "executing_program",
            "ref"  => agent_uri
          }]
        }

        if identifier and uri
          event["external_documents"] = [{
            "title"    => identifier,
            "location" => uri,
          }]
        end

        Event.create_from_json(JSONModel(:event).from_hash(event), :system_generated => true)
      end

    end
  end
end
