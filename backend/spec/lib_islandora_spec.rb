require 'spec_helper'

describe 'Islandora' do

  describe 'Client' do

    before(:all) do
      @base_url = "https://repository.islandora.edu"
      @root_url = "#{@base_url}/islandora/object/islandora:root"
      @config   = {
        base_url:  @base_url,
        rest_path: "/islandora/aspace/object",
        api_key:   "123xyz",
        verbose:   false,
      }
      @client = Islandora::Client.new(@config)
    end

    it "can create a configured client" do
      @client.config[:base_url].should eq(@base_url)
    end

    it "can determine agent is eligible" do
      agents = [{
        "role" => "source",
        "_resolved" => {
          "display_name" => {
            "software_name" => "Islandora"
          }
        }
      }]
      @client.agent_eligible?(agents).should be_truthy
    end

    it "can determine agent is ineligible" do
      agents = [{
        "role" => "source",
        "_resolved" => {
          "display_name" => {
            "software_name" => "ArchivesSpace"
          }
        }
      }]
      @client.agent_eligible?(agents).should be_falsey
    end

    it "can determine event is eligible" do
      events = [{
        "_resolved" => {
          "event_type" => "ingestion",
          "external_documents" => [ { "location" => "123" } ]
        }
      }]
      @client.event_eligible?(events, '123').should be_truthy
    end

    it "can determine event is ineligible with no external document" do
      events = [{
        "_resolved" => {
          "event_type" => "ingestion",
          "external_documents" => [],
        }
      }]
      @client.event_eligible?(events, '789').should be_falsey
    end

    it "can determine event is ineligible with non-matching external document" do
      events = [{
        "_resolved" => {
          "event_type" => "ingestion",
          "external_documents" => ['456'],
        }
      }]
      @client.event_eligible?(events, '789').should be_falsey
    end

    it "can determine uri is eligible" do
      @client.uri_eligible?(@root_url).should be_truthy
    end

    it "can determine uri is ineligible" do
      uri = "https://archives.abc.edu/resources/1"      
      @client.uri_eligible?(uri).should be_falsey
    end

    it "can extract a pid from a url" do
      @client.extract_pid(@root_url).should eq("islandora:root")
    end

  end

end
