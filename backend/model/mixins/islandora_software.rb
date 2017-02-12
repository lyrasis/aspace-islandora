module Islandora
  module Software

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def islandora_name
        "Islandora"
      end

      def islandora_record
        AgentSoftware[:system_role => islandora_role]
      end

      def islandora_role
        "islandora_agent"
      end

      def islandora_version
        "7.x" # TODO: from AppConfig[:islandora_config] ???
      end

      # Create the agent record that represents Islandora,
      # or update it if it exists but the software version has changed
      def ensure_correctly_versioned_islandora_record
        if islandora_record.nil?
          json = JSONModel(:agent_software).from_hash(
            :publish => true,
            :names => [{
              :software_name => islandora_name,
              :version => islandora_version,
              :source => 'local',
              :rules => 'local',
              :sort_name_auto_generate => true
          }])

          AgentSoftware.create_from_json(
            json, :system_generated => true, :system_role => islandora_role
          )
        else
          as_sequel = islandora_record
          unless as_sequel.name_software[0].version == islandora_version
            as_sequel.name_software[0].software_name = islandora_name
            as_sequel.name_software[0].sort_name     = "#{islandora_name} #{islandora_version}"
            as_sequel.name_software[0].version       = islandora_version
            as_sequel.name_software[0].save
          end
        end

        islandora_record
      end

    end
  end
end