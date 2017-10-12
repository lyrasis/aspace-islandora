# aspace-islandora

Plugin to interoperate with Islandora providing endpoints to create
Digital Objects and associated records, and triggering metadata updates
to Islandora from digital objects that reference an Islandora object
URL.

## Requirements

For ArchivesSpace define the Islandora configuration then enable the
plugin in `config.rb`.

```ruby
AppConfig[:islandora_config] = {
  base_url:  "https://digital.repository.edu",
  rest_path: "/islandora/aspace/object",
  api_key: "123456",
}

Appconfig[:plugins] << "aspace-islandora"
```

For Islandora requirements refer to [Islandora ArchivesSpace Solution Pack](https://github.com/lyrasis/islandora_archivesspace).

## ArchivesSpace versions tested:

- v1.5.3
- v2.1.3

## Sample requests

Create an Islandora object:

```ruby
bundle exec ./archivesspace-cli request \
  --type=POST \
  --path=/plugins/aspace_islandora/repositories/2/islandora_deposits?pid=lyrasis:3245 \
  --payload='{"digital_object_id": "lyrasis:3245", "title": "TESTING, 123!", "file_versions": [ { "file_uri": "https://dev-islandora.lyrasistechnology.org/islandora/object/lyrasis:3245" } ]}'
```

Add a deleted in Islandora event:

```bash
bundle exec ./archivesspace-cli request --type=DELETE --path=/plugins/aspace_islandora/repositories/2/islandora_deposits/1
```

Get and delete the Islandora object in aspace (it's just a digital object):

```bash
bundle exec ./archivesspace-cli request --type=GET    --path=/repositories/2/digital_objects/1
bundle exec ./archivesspace-cli request --type=DELETE --path=/repositories/2/digital_objects/1
```

Example payload to Islandora (content model not applied):

```json
backend stdout |      [java] E, [2017-10-11T19:06:09.090170 #15990] ERROR -- : Thread-2082: Islandora update failed: https://dev-islandora.lyrasistechnology.org/islandora/object/lyrasis:3245, {"lock_version":19,"digital_object_id":"lyrasis:3245","title":"TESTING, 123!!!%","publish":true,"restrictions":false,"created_by":"admin","last_modified_by":"admin","create_time":"2017-10-11T22:51:43Z","system_mtime":"2017-10-12T02:06:07Z","user_mtime":"2017-10-12T01:27:56Z","suppressed":false,"jsonmodel_type":"digital_object","external_ids":[],"subjects":[],"linked_events":[{"ref":"/repositories/2/events/104","_resolved":{"lock_version":0,"suppressed":false,"outcome_note":"/repositories/2/digital_objects/2","created_by":"admin","last_modified_by":"admin","create_time":"2017-10-11T22:51:43Z","system_mtime":"2017-10-12T01:27:57Z","user_mtime":"2017-10-11T22:51:43Z","event_type":"ingestion","outcome":"pass","jsonmodel_type":"event","external_ids":[],"external_documents":[{"lock_version":0,"title":"lyrasis:3245","location":"https://dev-islandora.lyrasistechnology.org/islandora/object/lyrasis:3245","publish":false,"created_by":"admin","last_modified_by":"admin","create_time":"2017-10-11T22:51:43Z","system_mtime":"2017-10-11T22:51:43Z","user_mtime":"2017-10-11T22:51:43Z","jsonmodel_type":"external_document"}],"linked_agents":[{"role":"executing_program","ref":"/agents/software/101"}],"linked_records":[{"role":"source","ref":"/agents/software/101"},{"role":"source","ref":"/repositories/2/digital_objects/2"}],"uri":"/repositories/2/events/104","repository":{"ref":"/repositories/2"},"date":{"lock_version":0,"begin":"2017-10-11","created_by":"admin","last_modified_by":"admin","create_time":"2017-10-11T22:51:43Z","system_mtime":"2017-10-11T22:51:43Z","user_mtime":"2017-10-11T22:51:43Z","date_type":"single","label":"event","jsonmodel_type":"date"}}}],"extents":[],"dates":[],"external_documents":[],"rights_statements":[],"linked_agents":[{"role":"source","terms":[],"ref":"/agents/software/101","_resolved":{"lock_version":7,"publish":true,"create_time":"2017-10-11T22:13:35Z","system_mtime":"2017-10-12T01:27:57Z","user_mtime":"2017-10-11T22:13:35Z","jsonmodel_type":"agent_software","agent_contacts":[],"linked_agent_roles":["source"],"external_documents":[],"notes":[],"used_within_repositories":[],"used_within_published_repositories":[],"dates_of_existence":[],"names":[{"lock_version":0,"software_name":"Islandora","version":"7.x","sort_name":"Islandora 7.x","sort_name_auto_generate":true,"create_time":"2017-10-11T22:13:35Z","system_mtime":"2017-10-11T22:13:35Z","user_mtime":"2017-10-11T22:13:35Z","authorized":true,"is_display_name":true,"source":"local","rules":"local","jsonmodel_type":"name_software","use_dates":[]}],"uri":"/agents/software/101","agent_type":"agent_software","is_linked_to_published_record":true,"display_name":{"lock_version":0,"software_name":"Islandora","version":"7.x","sort_name":"Islandora 7.x","sort_name_auto_generate":true,"create_time":"2017-10-11T22:13:35Z","system_mtime":"2017-10-11T22:13:35Z","user_mtime":"2017-10-11T22:13:35Z","authorized":true,"is_display_name":true,"source":"local","rules":"local","jsonmodel_type":"name_software","use_dates":[]},"title":"Islandora 7.x"}}],"file_versions":[{"lock_version":0,"file_uri":"https://dev-islandora.lyrasistechnology.org/islandora/object/lyrasis:3245","publish":false,"created_by":"admin","last_modified_by":"admin","create_time":"2017-10-12T01:27:56Z","system_mtime":"2017-10-12T01:27:56Z","user_mtime":"2017-10-12T01:27:56Z","jsonmodel_type":"file_version","is_representative":false,"identifier":"201"}],"notes":[],"linked_instances":[{"ref":"/repositories/2/archival_objects/1","_resolved":{"lock_version":15,"position":0,"publish":true,"ref_id":"952ed3a598f67856e91c9c217389c77a","component_id":"1","title":"WWWWAAsxdsszsAS","display_string":"WWWWAAsxdsszsAS","restrictions_apply":false,"created_by":"admin","last_modified_by":"admin","create_time":"2017-10-11T23:03:54Z","system_mtime":"2017-10-12T02:06:07Z","user_mtime":"2017-10-12T02:06:07Z","suppressed":false,"level":"series","jsonmodel_type":"archival_object","external_ids":[],"subjects":[{"ref":"/subjects/1"}],"linked_events":[],"extents":[],"dates":[],"external_documents":[],"rights_statements":[],"linked_agents":[],"ancestors":[{"ref":"/repositories/2/resources/1","level":"collection"}],"instances":[{"lock_version":0,"created_by":"admin","last_modified_by":"admin","create_time":"2017-10-12T02:06:07Z","system_mtime":"2017-10-12T02:06:07Z","user_mtime":"2017-10-12T02:06:07Z","instance_type":"digital_object","jsonmodel_type":"instance","is_representative":false,"digital_object":{"ref":"/repositories/2/digital_objects/2"}}],"notes":[],"uri":"/repositories/2/archival_objects/1","repository":{"ref":"/repositories/2"},"resource":{"ref":"/repositories/2/resources/1"},"has_unpublished_ancestor":false}}],"uri":"/repositories/2/digital_objects/2","repository":{"ref":"/repositories/2"},"tree":{"ref":"/repositories/2/digital_objects/2/tree"}}, #<Net::HTTPNotAcceptable 406 Not Acceptable : Object is not linked to ArchivesSpace. readbody=true>
```

## License

This plugin is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

---
