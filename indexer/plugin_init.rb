# require files from lib
Dir.glob(File.join(File.dirname(__FILE__), "lib", "*.rb")).sort.each do |file|
  require File.absolute_path(file)
end

# aspace-islandora config
AppConfig[:islandora_config] = {
  base_url:  ENV.fetch("ISLANDORA_BASE_URL"),
  rest_path: ENV.fetch("ISLANDORA_REST_PATH"),
  username:  ENV.fetch("ISLANDORA_USERNAME"),
  password:  ENV.fetch("ISLANDORA_PASSWORD"),
}
