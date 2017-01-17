# aspace-islandora

Plugin to interoperate with Islandora providing endpoints to create Digital Objects and associated records, and triggering metadata updates to Islandora from digital objects that reference an Islandora object URL.

For more details refer to [aspace-islandora integration](#).

## Requirements

For ArchivesSpace define the Islandora configuration then enable the plugin in `config.rb`.

```ruby
AppConfig[:islandora_config] = {
  base_url:  "https://digital.repository.edu",
  rest_path: "/islandora/archivesspace/v1/update",
  username:  "jsmith",
  password:  "password123456",
}

Appconfig[:plugins] << "aspace-islandora"
```

For Islandora requirements refer to [islandora_aspace_solution_pack](#).

## How it works

...

## ArchivesSpace versions tested:

- v1.5.3

## License

...

---