require 'spec_helper'

describe 'Islandora' do

  describe 'Deposits mixin' do

    it "can find a digital_object and file version by file uri" do
      file_version   = build(:json_file_version)
      file_uri       = file_version["file_uri"]
      digital_object = create(:json_digital_object, file_versions: [file_version])
      
      found_file_uri = DigitalObject.find_file_version_by_file_uri(file_uri).file_uri
      found_file_uri.should eq(file_uri)

      DigitalObject.find_by_file_uri(file_uri).id.should eq(digital_object.id)
    end

    it "can create an ingest event" do
      digital_object = create(:json_digital_object)
      agent          = create(:json_agent_software)

      event = DigitalObject.create_islandora_ingest_event(digital_object.uri, agent.uri, 'ABC', '123')
      JSONModel(:event).find(event.id).event_type.should eq('ingestion')
    end

    it "can create a deletion event" do
      digital_object = create(:json_digital_object)
      agent          = create(:json_agent_software)

      event = DigitalObject.create_islandora_delete_event(digital_object.uri, agent.uri)
      JSONModel(:event).find(event.id).event_type.should eq('deletion')
    end

    it "can create a software event" do
      digital_object = create(:json_digital_object)
      agent          = create(:json_agent_software)

      event = DigitalObject.create_software_event('validation', 'pass', digital_object.uri, agent.uri)
      JSONModel(:event).find(event.id).event_type.should eq('validation')
    end

    it "can find a digital object event" do
      digital_object = create(:json_digital_object)
      agent          = create(:json_agent_software)

      event_opts = {
        event_type: 'ingestion',
        linked_agents: [{ 'ref' => agent.uri, 'role' => 'executing_program' }],
        linked_records: [{'ref' => digital_object.uri, 'role' => 'source'}],
      }
      create(:json_event, event_opts)

      id = DigitalObject.find_event_for(digital_object.id, 'ingestion').id
      JSONModel(:event).find(id).event_type.should eq('ingestion')
    end

  end

end