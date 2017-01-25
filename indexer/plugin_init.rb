# require files from lib
Dir.glob(File.join(File.dirname(__FILE__), "lib", "*.rb")).sort.each do |file|
  require File.absolute_path(file)
end

unless AppConfig.has_key?(:islandora_config)
  # aspace-islandora config (example)
  AppConfig[:islandora_config] = {
    base_url:  ENV.fetch("ISLANDORA_BASE_URL", nil),
    rest_path: ENV.fetch("ISLANDORA_REST_PATH", nil),
    username:  ENV.fetch("ISLANDORA_USERNAME", nil),
    password:  ENV.fetch("ISLANDORA_PASSWORD", nil),
    api_key:   ENV.fetch("ISLANDORA_API_KEY", nil),
  }
end
