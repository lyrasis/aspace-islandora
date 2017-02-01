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

            obj   = JSON.parse doc['json']
            event = obj['linked_events'].find { |evt| evt['_resolved']['event_type'] == 'ingestion' }

            unless islandora.event_eligible? event, uri
              islandora.error "Islandora uri detected but eligible event not found: #{uri}"
              next
            end

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
    }
  end

  # add hook for event updates to islandora if eligible
  add_indexer_initialize_hook do |indexer|
    # record: aspace record, doc: document shipped to solr
    indexer.add_document_prepare_hook { |doc, record|
      if doc['primary_type'] == 'event'
        record = record['record']
        if record['event_type'] == "ingestion" and !record['linked_records'].find { |lr| lr['ref'] =~ /digital_objects/ }

          # check this is really an islandora event
          islandora = Islandora.new(AppConfig[:islandora_config])
          url       = record['external_documents'][0]['location']

          islandora.debug "Checking if event update is Islandora eligible: #{record}"
          next unless islandora.uri_eligible?(url)
          next unless islandora.agent_eligible?(record['linked_agents'])

          # digital object link has been lost, notify islandora
          response = islandora.delete url

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