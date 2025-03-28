require 'benchmark'
require 'pry'
require_relative 'check_abstract'
require_relative '../config'

module Checks
  class CheckBrowse < CheckAbstract
    def initialize
      super("Browse page")
    end

    private
    def process
      # Getting: https://data.stageportal.lirmm.fr/analytics with {:year=>2025, :month=>2} (t: 0.9459119590173941s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.3471077919821255s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies with {:include=>"all", :display_links=>false, :display_context=>false, :also_include_views=>true} (t: 1.4130154999729712s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr with {} (t: 0.33000116699258797s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/submissions with {:include=>"ontology,submissionStatus,description,pullLocation,creationDate,contact,released,naturalLanguage,hasOntologyLanguage,hasFormalityLevel,isOfType,deprecated,status,metrics", :display_links=>false, :display_context=>false, :also_include_views=>true, :include_status=>"READY"} (t: 11.496646297018742s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories with {:display_links=>false, :display_context=>false} (t: 0.5253938339883462s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/groups with {:display_links=>false, :display_context=>false} (t: 0.4357905830256641s - cache: miss)

      begin
        LinkedData::Client::Analytics.last_month
      rescue
        nil
      end
      Rails.cache.clear
      LinkedData::Client::Models::Ontology.all(include: 'all', display_links: false, display_context: false, also_include_views: true)
      LinkedData::Client::Models::OntologySubmission.all(include: 'ontology,submissionStatus,description,pullLocation,creationDate,contact,released,naturalLanguage,hasOntologyLanguage,hasFormalityLevel,isOfType,deprecated,status,metrics', display_links: false, display_context: false, also_include_views: true, include_status: 'READY')
      LinkedData::Client::Models::Category.all
      LinkedData::Client::Models::Group.all(display_links: false, display_context: false)
    end
  end
end