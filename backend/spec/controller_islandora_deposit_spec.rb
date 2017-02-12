require 'spec_helper'

describe 'Islandora' do

  describe 'Deposits controller' do

    before(:each) do
      @pid                = "islandora:root"
      @agent_uri          = AgentSoftware.ensure_correctly_versioned_islandora_record.uri
      @file_version       = build(:json_file_version)
      @file_uri           = @file_version["file_uri"]
      @digital_object     = create(:json_digital_object, file_versions: [ @file_version ])
      @digital_object_uri = JSONModel(:digital_object).uri_for(
        @digital_object.id,
        :repo_id => RequestContext.get(:repo_id)
      )
    end

    it "can create a digital object deposit and event" do
      id = DigitalObject.create_islandora_ingest_event(@digital_object_uri, @agent_uri, @pid, @file_uri).id
      JSONModel(:event).find(id).outcome_note.should eq(@digital_object_uri)
    end

    it "can create a digital object deposit delete event" do
      id = DigitalObject.create_islandora_delete_event(@digital_object_uri, @agent_uri).id
      JSONModel(:event).find(id).outcome_note.should eq(@digital_object_uri)
    end

    it "can get a digital_object deposit event" do
      DigitalObject.create_software_event('validation', 'pass', @digital_object_uri, @agent_uri)
      id = DigitalObject.find_event_for(@digital_object.id, 'validation').id
      JSONModel(:event).find(id).outcome_note.should eq(@digital_object_uri)
    end

  end

end