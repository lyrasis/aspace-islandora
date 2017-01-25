class CommonIndexer

  add_attribute_to_resolve('linked_events')

  # add hook for digitial object updates to islandora if eligible
  add_indexer_initialize_hook do |indexer|
    # record: aspace record, doc: document shipped to solr
    indexer.add_document_prepare_hook { |doc, record|
      if doc['primary_type'] == 'digital_object'
        if record['record'].has_key? 'file_versions'
          record['record']['file_versions'].each do |file_version|
            uri       = file_version.fetch 'file_uri'
            islandora = Islandora.new(AppConfig[:islandora_config])

            next unless islandora.uri_eligible?(uri)
            islandora.debug "Islandora uri eligible: #{uri}"

            obj   = JSON.parse doc['json']
            event = obj['linked_events'].find { |evt| evt['_resolved']['event_type'] == 'ingestion' }
            islandora.debug "ArchivesSpace digital object: #{obj}"

            unless islandora.event_eligible? event['_resolved'], uri
              islandora.error "Islandora uri detected but eligible event not found: #{uri}"
              next
            end
            islandora.debug "Islandora event eligible: #{event}, #{uri}"

            payload  = JSON.generate(obj)
            response = islandora.update(uri, payload)

            if response and response.code.to_s == "200"
              islandora.debug "Islandora uri metadata updated: #{uri}, #{response.to_hash}, #{response.body}"
            else
              islandora.error "Islandora uri and event found but update failed: #{uri}, #{event}, #{payload}, #{response.inspect}"
            end
          end
        end

      end

      if doc['primary_type'] == 'event'
        record = record['record']
        if record['event_type'] == "ingestion" and record['linked_records'].empty?

          # check this is really an islandora event
          islandora_agent = record['linked_agents'].find { |la|
            la['role'] == "executing_program" and
            la['_resolved']['display_name']['software_name'] == "Islandora"
          }
          next unless islandora_agent

          # digital object link lost, notify islandora
          url       = record['external_documents'][0]['location']
          islandora = Islandora.new(AppConfig[:islandora_config])
          response  = islandora.delete url

          if response and response.code.to_s == "200"
            islandora.debug "Islandora delete notification succeeded: #{url}"
          else
            islandora.error "Islandora delete notification failed: #{url}, #{response.inspect}"
          end
        end
      end
    }
  end

end