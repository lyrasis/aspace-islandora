class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits')
    .description("Create a Digital Object with an Islandora deposit ingest event")
    .params(["digital_object", JSONModel(:digital_object), "The record to create", :body => true],
            ["pid", String, :pid],
            ["repo_id", :repo_id])
    .permissions([:update_digital_object_record])
    .returns([200, "(:digital_object)"],
             [400, :error]) \
  do
    pid             = params[:pid]
    file_uri        = params[:digital_object]['file_versions'][0]['file_uri'] rescue nil
    file_uri_record = DigitalObject.find_by_file_uri(file_uri) # check for pre-existing file_uri
    agent_uri       = AgentSoftware.ensure_correctly_versioned_islandora_record.uri

    raise BadParamsException.new(
      :digital_object => ["File version uri required for Islandora deposit and must be unique."]
    ) if ! file_uri or file_uri_record

    # add islandora software agent to digital object payload
    params[:digital_object]['linked_agents'][0] = {
      "role"  => "source",
      "terms" => [],
      "ref"   => agent_uri,
    }

    # create digital object before event to check validation
    digital_object     = DigitalObject.create_from_json(params[:digital_object])
    digital_object_uri = JSONModel(:digital_object).uri_for(digital_object.id, :repo_id => RequestContext.get(:repo_id))

    DigitalObject.create_islandora_ingest_event(digital_object_uri, agent_uri, pid, file_uri)
    json_response(DigitalObject.to_jsonmodel(digital_object.refresh))
  end

  Endpoint.delete('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits/:id')
    .description("Add a delete event to an Islandora Digital Object deposit and remove references")
    .params(["id", Integer, :id],
            ["repo_id", :repo_id])
    .permissions([:update_digital_object_record])
    .returns([200, "(:event)"]) \
  do
    digital_object = DigitalObject.get_or_die(params[:id])
    obj            = DigitalObject.to_jsonmodel(digital_object)
    agent_uri      = AgentSoftware.ensure_correctly_versioned_islandora_record.uri

    # TODO: other actions? remove agent? suppress? unpublish?
    obj['file_versions'] = obj['file_versions'].clear
    digital_object.update_from_json(JSONModel(:digital_object).from_hash(obj.to_hash))

    event = DigitalObject.find_event_for(params[:id], 'deletion')
    unless event
      event = DigitalObject.create_islandora_delete_event(obj['uri'], agent_uri)
    end

    json_response(Event.to_jsonmodel(event))
  end

  Endpoint.get('/plugins/aspace_islandora/repositories/:repo_id/islandora_deposits/:id/event')
    .description("Get event associated with an Islandora Digital Object deposit")
    .params(["id", Integer, :id],
            ["event_type", String, :event_type],
            ["repo_id", :repo_id])
    .permissions([:view_digital_object_record])
    .returns([200, "(:event)"]) \
  do
    event = DigitalObject.find_event_for(params[:id], params[:event_type])
    if event
      json_response(Event.to_jsonmodel(event))
    else
      raise NotFoundException.new("Event wasn't found")
    end
  end

end
