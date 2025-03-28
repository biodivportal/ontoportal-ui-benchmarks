require 'benchmark'
require 'pry'
require_relative 'check_abstract'
require_relative '../config'
module Checks
  class CheckHome < CheckAbstract

    def initialize
      super("Home page")
    end

    private

    def process
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.4363317509996705s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/slices with {:display_links=>false, :display_context=>false} (t: 0.5136855419841595s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/analytics with {:year=>2025, :month=>2} (t: 1.1376067920064088s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/slices with {:display_links=>false, :display_context=>false} (t: 0.40914308399078436s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.3647263750026468s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/metrics with {:display_links=>false, :display_context=>false} (t: 14.435820922022685s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/mappings/statistics/ontologies/ with {} (t: 0.3190470839908812s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.33847333400626667s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/projects with {:display_links=>false, :display_context=>false} (t: 0.7963174589967821s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.3608764999953564s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/users with {:include=>"all", :display_links=>false, :display_context=>false} (t: 1.8827487929956988s - cache: miss)
      LinkedData::Client::Models::Slice.all
      begin
        LinkedData::Client::Analytics.last_month
      rescue
        sleep(0.5)
      end
      LinkedData::Client::Models::Slice.all
      LinkedData::Client::Models::Metrics.all
      LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}/mappings/statistics/ontologies/")
      LinkedData::Client::Models::Project.all
      LinkedData::Client::Models::User.all(include: 'all', display_links: false, display_context: false)
    end
  end
end