class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits')
    .description("Create a Digital Object with an Islandora deposit ingest event")
    .params(["digital_object", JSONModel(:digital_object), "The record to create", :body => true],
            ["pid", String, :pid],
            ["repo_id", :repo_id])
    .permissions([:update_digital_object_record])
    .returns([200, :created],
             [400, :error]) \
  do
    pid             = params[:pid]
    file_uri        = params[:digital_object]['file_versions'][0]['file_uri'] rescue nil
    file_uri_object = get_file_uri_object(file_uri) # check for pre-existing file_uri
    agent           = get_islandora_agent
    agent_uri       = JSONModel(:agent_software).uri_for(agent[:id])

    raise BadParamsException.new(
      :digital_object => ["File version uri required for Islandora deposit and must be unique."]
    ) if ! file_uri or file_uri_object

    # add islandora software agent to digital object payload
    params[:digital_object]['linked_agents'][0] = {
      "role"  => "source",
      "terms" => [],
      "ref"   => agent_uri,
    }

    # create digital object before event to check validation
    digital_object     = DigitalObject.create_from_json(params[:digital_object])
    digital_object_uri = JSONModel(:digital_object).uri_for(digital_object[:id], :repo_id => RequestContext.get(:repo_id))

    add_software_event(
      "ingestion",
      "pass",
      digital_object_uri,
      agent_uri,
      pid,
      file_uri
    )

    created_response(digital_object, params[:digital_object])
  end

  Endpoint.delete('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits/:id')
    .description("Add a delete event to an Islandora Digital Object deposit and remove file_uri")
    .params(["id", Integer, :id],
            ["repo_id", :repo_id])
    .permissions([:update_digital_object_record])
    .returns([200, :deleted]) \
  do
    digital_object      = DigitalObject.get_or_die(params[:id])
    digital_object_json = DigitalObject.to_jsonmodel(digital_object)
    digital_object_uri  = digital_object_json['uri']
    agent               = get_islandora_agent
    agent_uri           = JSONModel(:agent_software).uri_for(agent[:id])

    # TODO: check we don't already have an associated delete event
    event = add_software_event(
      "deletion",
      "pass",
      digital_object_uri,
      agent_uri
    )

    # TODO: other actions? remove agent? suppress? unpublish?
    digital_object_json['file_versions'] = digital_object_json['file_versions'].clear
    digital_object.update_from_json(digital_object_json)

    created_response(event)
  end

  Endpoint.get('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits/:id/event')
    .description("Get event associated with an Islandora Digital Object deposit")
    .params(["id", Integer, :id],
            ["event_type", String, :event_type],
            ["repo_id", :repo_id])
    .permissions([:view_digital_object_record])
    .returns([200, "(:event)"]) \
  do
    json = resolve_references(
      DigitalObject.to_jsonmodel(params[:id]),
      ["linked_events", "linked_events::external_documents"]
    )
    event = json["linked_events"].find { |e| e["_resolved"]["event_type"] == params[:event_type] }

    if event
      json_response(event['_resolved'])
    else
      raise NotFoundException.new("Event wasn't found")
    end
  end

  def add_software_event(type, outcome, digital_object_uri, agent_uri, identifier = nil, uri = nil)
    event = {
      "event_type"   => type,
      "outcome"      => outcome,
      "outcome_note" => digital_object_uri,
      "date"       => {
        "date_type" => "single",
        "label"     => "event",
        "begin"     => Time.now.strftime("%Y-%m-%d")
      },
      "linked_records" => [{
       "role" => "source",
       "ref"  => digital_object_uri
      }],
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

    event = Event.create_from_json(JSONModel(:event).from_hash(event), :system_generated => true)
    Log.info("Created #{type} #{outcome} software event.")
    event
  end

  def create_islandora_agent
    json = JSONModel(:agent_software).from_hash(
      :publish => true,
      :names => [{
        :software_name => islandora_software_name,
        :version => islandora_software_version,
        :source => 'local',
        :rules => 'local',
        :sort_name_auto_generate => true
    }])
    agent = AgentSoftware.create_from_json(json, :system_generated => true)
    Log.info("Created #{islandora_software_name} #{islandora_software_version} agent.")
    agent
  end

  def get_file_uri_object(file_uri)
    # see get_islandora_agent_name comments
    FileVersion.all.find { |fv| fv[:file_uri] == file_uri }
  end

  def get_islandora_agent
    agent      = nil
    agent_name = get_islandora_agent_name
    if agent_name
      agent = AgentSoftware.get_or_die(agent_name[:agent_software_id])
    else
      agent = create_islandora_agent
    end
    agent
  end

  def get_islandora_agent_name
    # Derby does not like this =(
    # agent_name = NameSoftware.where(:software_name => agent_title, :version => agent_version).first
    # TODO: replace this method of getting name (using for now as it's Derby compatible)
    agent_name = NameSoftware.all.find { |ns|
      ns[:software_name] == islandora_software_name and ns[:version] == islandora_software_version
    }
    agent_name
  end

  def islandora_software_name
    # TODO: config for this?
    "Islandora"
  end

  def islandora_software_version
    # TODO: config for this?
    "7.x"
  end

end