class Event

  def self.for_islandora_deposit_ingestion(digital_object_uri, agent_uri, identifier, uri)
    for_software_event("ingestion", "pass", digital_object_uri, agent_uri, identifier, uri)
  end

  def self.for_islandora_deposit_deletion(digital_object_uri, agent_uri)
    for_software_event("deletion", "pass", digital_object_uri, agent_uri)
  end

  def self.for_software_event(type, outcome, digital_object_uri, agent_uri, identifier = nil, uri = nil)
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