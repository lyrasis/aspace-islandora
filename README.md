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

## How it works

...

## ArchivesSpace versions tested:

- v1.5.3

## License

This plugin is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

---
