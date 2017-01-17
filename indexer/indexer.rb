class CommonIndexer

  # add hook for digitial object updates to islandora if eligible
  add_indexer_initialize_hook do |indexer|
    # record: aspace record, doc: document shipped to solr
    indexer.add_document_prepare_hook {|doc, record|
      if doc['primary_type'] == 'digital_object'
        if record['record'].has_key? 'file_versions'
          record['record']['file_versions'].each do |file_version|
            uri       = file_version.fetch 'file_uri'
            islandora = Islandora.new(AppConfig[:islandora_config])

            next unless islandora.uri_eligible?(uri)

            event = record['record']['linked_events'].map { |evt|
              JSONModel.JSONModel(:event).find_by_uri(evt['ref'])
            }.find { |evt| evt['event_type'] == 'ingestion' } rescue nil

            next unless islandora.event_eligible? event, uri

            islandora_session = islandora.login
            unless islandora_session
              $stderr.puts "Islandora uri detected but cannot login (check connection or credentials):\t#{uri}"
              next
            end

            # this assumes configured user can view object (needs documentation)
            unless islandora.object_exists?(uri)
              $stderr.puts "Islandora uri detected but remote object not found:\t#{uri}"
              next
            end

            payload  = JSON.generate record['record']
            response = islandora.update(uri, payload)

            if response # TODO: .code == 200
              $stdout.puts "Islandora uri metadata updated:\t#{uri}"
            else
              $stderr.puts "Islandora uri detected but update failed:\t#{uri},#{payload}"
            end
          end
        end

      end
    }
  end

  # TODO: delete_hook

end