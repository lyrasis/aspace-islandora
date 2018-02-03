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

AppConfig[:plugins] << "aspace-islandora"
```

Islandora requires a user in ArchivesSpace. We recommend:

- Create a group in ArchivesSpace: group_code: islandora, desc: Islandora
- Add: view records, create/update digital objects, create/update events perms to group
- Create a user: islandora, add user to islandora group for each repo as necessary

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

Example payload to Islandora:

```json
{
  "lock_version": 22,
  "digital_object_id": "lyrasis:3245",
  "title": "TESTING, 123!!!%",
  "publish": true,
  "restrictions": false,
  "created_by": "admin",
  "last_modified_by": "admin",
  "create_time": "2017-10-11T22:51:43Z",
  "system_mtime": "2017-10-12T15:57:41Z",
  "user_mtime": "2017-10-12T15:57:41Z",
  "suppressed": false,
  "jsonmodel_type": "digital_object",
  "external_ids": [

  ],
  "subjects": [
    {
      "ref": "\/subjects\/1",
      "_resolved": {
        "lock_version": 17,
        "title": "Punk",
        "created_by": "admin",
        "last_modified_by": "admin",
        "create_time": "2017-10-12T00:55:08Z",
        "system_mtime": "2017-10-12T15:57:42Z",
        "user_mtime": "2017-10-12T00:55:08Z",
        "source": "local",
        "jsonmodel_type": "subject",
        "external_ids": [

        ],
        "publish": true,
        "used_within_repositories": [

        ],
        "used_within_published_repositories": [

        ],
        "terms": [
          {
            "lock_version": 0,
            "term": "Punk",
            "created_by": "admin",
            "last_modified_by": "admin",
            "create_time": "2017-10-12T00:55:08Z",
            "system_mtime": "2017-10-12T00:55:08Z",
            "user_mtime": "2017-10-12T00:55:08Z",
            "term_type": "cultural_context",
            "jsonmodel_type": "term",
            "uri": "\/terms\/1",
            "vocabulary": "\/vocabularies\/1"
          }
        ],
        "external_documents": [

        ],
        "uri": "\/subjects\/1",
        "vocabulary": "\/vocabularies\/1",
        "is_linked_to_published_record": true
      }
    }
  ],
  "linked_events": [
    {
      "ref": "\/repositories\/2\/events\/104",
      "_resolved": {
        "lock_version": 0,
        "suppressed": false,
        "outcome_note": "\/repositories\/2\/digital_objects\/2",
        "created_by": "admin",
        "last_modified_by": "admin",
        "create_time": "2017-10-11T22:51:43Z",
        "system_mtime": "2017-10-12T15:57:42Z",
        "user_mtime": "2017-10-11T22:51:43Z",
        "event_type": "ingestion",
        "outcome": "pass",
        "jsonmodel_type": "event",
        "external_ids": [

        ],
        "external_documents": [
          {
            "lock_version": 0,
            "title": "lyrasis:3245",
            "location": "https:\/\/dev-islandora.lyrasistechnology.org\/islandora\/object\/lyrasis:3245",
            "publish": false,
            "created_by": "admin",
            "last_modified_by": "admin",
            "create_time": "2017-10-11T22:51:43Z",
            "system_mtime": "2017-10-11T22:51:43Z",
            "user_mtime": "2017-10-11T22:51:43Z",
            "jsonmodel_type": "external_document"
          }
        ],
        "linked_agents": [
          {
            "role": "executing_program",
            "ref": "\/agents\/software\/101"
          }
        ],
        "linked_records": [
          {
            "role": "source",
            "ref": "\/agents\/software\/101"
          },
          {
            "role": "source",
            "ref": "\/repositories\/2\/digital_objects\/2"
          }
        ],
        "uri": "\/repositories\/2\/events\/104",
        "repository": {
          "ref": "\/repositories\/2"
        },
        "date": {
          "lock_version": 0,
          "begin": "2017-10-11",
          "created_by": "admin",
          "last_modified_by": "admin",
          "create_time": "2017-10-11T22:51:43Z",
          "system_mtime": "2017-10-11T22:51:43Z",
          "user_mtime": "2017-10-11T22:51:43Z",
          "date_type": "single",
          "label": "event",
          "jsonmodel_type": "date"
        }
      }
    }
  ],
  "extents": [

  ],
  "dates": [

  ],
  "external_documents": [

  ],
  "rights_statements": [

  ],
  "linked_agents": [
    {
      "role": "source",
      "terms": [

      ],
      "ref": "\/agents\/software\/101",
      "_resolved": {
        "lock_version": 8,
        "publish": true,
        "create_time": "2017-10-11T22:13:35Z",
        "system_mtime": "2017-10-12T15:57:42Z",
        "user_mtime": "2017-10-11T22:13:35Z",
        "jsonmodel_type": "agent_software",
        "agent_contacts": [

        ],
        "linked_agent_roles": [
          "source"
        ],
        "external_documents": [

        ],
        "notes": [

        ],
        "used_within_repositories": [

        ],
        "used_within_published_repositories": [

        ],
        "dates_of_existence": [

        ],
        "names": [
          {
            "lock_version": 0,
            "software_name": "Islandora",
            "version": "7.x",
            "sort_name": "Islandora 7.x",
            "sort_name_auto_generate": true,
            "create_time": "2017-10-11T22:13:35Z",
            "system_mtime": "2017-10-11T22:13:35Z",
            "user_mtime": "2017-10-11T22:13:35Z",
            "authorized": true,
            "is_display_name": true,
            "source": "local",
            "rules": "local",
            "jsonmodel_type": "name_software",
            "use_dates": [

            ]
          }
        ],
        "uri": "\/agents\/software\/101",
        "agent_type": "agent_software",
        "is_linked_to_published_record": true,
        "display_name": {
          "lock_version": 0,
          "software_name": "Islandora",
          "version": "7.x",
          "sort_name": "Islandora 7.x",
          "sort_name_auto_generate": true,
          "create_time": "2017-10-11T22:13:35Z",
          "system_mtime": "2017-10-11T22:13:35Z",
          "user_mtime": "2017-10-11T22:13:35Z",
          "authorized": true,
          "is_display_name": true,
          "source": "local",
          "rules": "local",
          "jsonmodel_type": "name_software",
          "use_dates": [

          ]
        },
        "title": "Islandora 7.x"
      }
    }
  ],
  "file_versions": [
    {
      "lock_version": 0,
      "file_uri": "https:\/\/dev-islandora.lyrasistechnology.org\/islandora\/object\/lyrasis:3245",
      "publish": false,
      "created_by": "admin",
      "last_modified_by": "admin",
      "create_time": "2017-10-12T01:27:56Z",
      "system_mtime": "2017-10-12T01:27:56Z",
      "user_mtime": "2017-10-12T01:27:56Z",
      "jsonmodel_type": "file_version",
      "is_representative": false,
      "identifier": "201"
    }
  ],
  "notes": [
    {
      "jsonmodel_type": "note_digital_object",
      "type": "note",
      "content": [
        "Nothing in <i>particular<\/i><\/i>."
      ],
      "persistent_id": "f772d69879f0467efc601f11da340600",
      "publish": true
    }
  ],
  "linked_instances": [
    {
      "ref": "\/repositories\/2\/archival_objects\/1",
      "_resolved": {
        "lock_version": 17,
        "position": 0,
        "publish": true,
        "ref_id": "952ed3a598f67856e91c9c217389c77a",
        "component_id": "1",
        "title": "WWWWAAsxdsszsASd",
        "display_string": "WWWWAAsxdsszsASd",
        "restrictions_apply": false,
        "created_by": "admin",
        "last_modified_by": "admin",
        "create_time": "2017-10-11T23:03:54Z",
        "system_mtime": "2017-10-12T15:57:42Z",
        "user_mtime": "2017-10-12T15:54:12Z",
        "suppressed": false,
        "level": "series",
        "jsonmodel_type": "archival_object",
        "external_ids": [

        ],
        "subjects": [
          {
            "ref": "\/subjects\/1",
            "_resolved": {
              "lock_version": 17,
              "title": "Punk",
              "created_by": "admin",
              "last_modified_by": "admin",
              "create_time": "2017-10-12T00:55:08Z",
              "system_mtime": "2017-10-12T15:57:42Z",
              "user_mtime": "2017-10-12T00:55:08Z",
              "source": "local",
              "jsonmodel_type": "subject",
              "external_ids": [

              ],
              "publish": true,
              "used_within_repositories": [

              ],
              "used_within_published_repositories": [

              ],
              "terms": [
                {
                  "lock_version": 0,
                  "term": "Punk",
                  "created_by": "admin",
                  "last_modified_by": "admin",
                  "create_time": "2017-10-12T00:55:08Z",
                  "system_mtime": "2017-10-12T00:55:08Z",
                  "user_mtime": "2017-10-12T00:55:08Z",
                  "term_type": "cultural_context",
                  "jsonmodel_type": "term",
                  "uri": "\/terms\/1",
                  "vocabulary": "\/vocabularies\/1"
                }
              ],
              "external_documents": [

              ],
              "uri": "\/subjects\/1",
              "vocabulary": "\/vocabularies\/1",
              "is_linked_to_published_record": true
            }
          }
        ],
        "linked_events": [

        ],
        "extents": [
          {
            "lock_version": 0,
            "number": "10",
            "created_by": "admin",
            "last_modified_by": "admin",
            "create_time": "2017-10-12T15:54:12Z",
            "system_mtime": "2017-10-12T15:54:12Z",
            "user_mtime": "2017-10-12T15:54:12Z",
            "portion": "whole",
            "extent_type": "volumes",
            "jsonmodel_type": "extent"
          }
        ],
        "dates": [

        ],
        "external_documents": [

        ],
        "rights_statements": [

        ],
        "linked_agents": [
          {
            "role": "creator",
            "terms": [

            ],
            "ref": "\/agents\/people\/1",
            "_resolved": {
              "lock_version": 1,
              "publish": false,
              "create_time": "2017-10-11T16:14:06Z",
              "system_mtime": "2017-10-12T15:54:13Z",
              "user_mtime": "2017-10-11T16:14:06Z",
              "jsonmodel_type": "agent_person",
              "agent_contacts": [

              ],
              "linked_agent_roles": [
                "creator"
              ],
              "external_documents": [

              ],
              "notes": [

              ],
              "used_within_repositories": [

              ],
              "used_within_published_repositories": [

              ],
              "dates_of_existence": [

              ],
              "names": [
                {
                  "lock_version": 0,
                  "primary_name": "Administrator",
                  "sort_name": "Administrator",
                  "sort_name_auto_generate": true,
                  "create_time": "2017-10-11T16:14:06Z",
                  "system_mtime": "2017-10-11T16:14:06Z",
                  "user_mtime": "2017-10-11T16:14:06Z",
                  "authorized": true,
                  "is_display_name": true,
                  "source": "local",
                  "rules": "local",
                  "name_order": "direct",
                  "jsonmodel_type": "name_person",
                  "use_dates": [

                  ]
                }
              ],
              "related_agents": [

              ],
              "uri": "\/agents\/people\/1",
              "agent_type": "agent_person",
              "is_linked_to_published_record": true,
              "display_name": {
                "lock_version": 0,
                "primary_name": "Administrator",
                "sort_name": "Administrator",
                "sort_name_auto_generate": true,
                "create_time": "2017-10-11T16:14:06Z",
                "system_mtime": "2017-10-11T16:14:06Z",
                "user_mtime": "2017-10-11T16:14:06Z",
                "authorized": true,
                "is_display_name": true,
                "source": "local",
                "rules": "local",
                "name_order": "direct",
                "jsonmodel_type": "name_person",
                "use_dates": [

                ]
              },
              "title": "Administrator",
              "is_user": "admin"
            }
          }
        ],
        "ancestors": [
          {
            "ref": "\/repositories\/2\/resources\/1",
            "level": "collection"
          }
        ],
        "instances": [
          {
            "lock_version": 0,
            "created_by": "admin",
            "last_modified_by": "admin",
            "create_time": "2017-10-12T15:54:12Z",
            "system_mtime": "2017-10-12T15:54:12Z",
            "user_mtime": "2017-10-12T15:54:12Z",
            "instance_type": "digital_object",
            "jsonmodel_type": "instance",
            "is_representative": false,
            "digital_object": {
              "ref": "\/repositories\/2\/digital_objects\/2"
            }
          }
        ],
        "notes": [
          {
            "jsonmodel_type": "note_singlepart",
            "type": "abstract",
            "content": [
              "About stuff."
            ],
            "persistent_id": "76a30e91691db3def16f9d0049f25784",
            "publish": true
          }
        ],
        "uri": "\/repositories\/2\/archival_ob backend stdout | jects\/1",
        "repository": {
          "ref": "\/repositories\/2"
        },
        "resource": {
          "ref": "\/repositories\/2\/resources\/1"
        },
        "has_unpublished_ancestor": false
      }
    }
  ],
  "uri": "\/repositories\/2\/digital_objects\/2",
  "repository": {
    "ref": "\/repositories\/2"
  },
  "tree": {
    "ref": "\/repositories\/2\/digital_objects\/2\/tree"
  }
}
```

## Running the tests

```bash
./build/run backend:test -Dexample='Islandora'
```

## License

This plugin is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

---
