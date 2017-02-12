# require files from lib
Dir.glob(File.join(File.dirname(__FILE__), "lib", "*.rb")).sort.each do |file|
  require File.absolute_path(file)
end

unless AppConfig.has_key?(:islandora_config)
  # aspace-islandora config (example)
  AppConfig[:islandora_config] = {
    base_url:  ENV.fetch("ISLANDORA_BASE_URL", nil),
    rest_path: ENV.fetch("ISLANDORA_REST_PATH", nil),
    api_key:   ENV.fetch("ISLANDORA_API_KEY", nil),
  }
end

ArchivesSpaceService.loaded_hook do
  # ensure setup of Islandora agent
  AgentSoftware.ensure_correctly_versioned_islandora_record
end