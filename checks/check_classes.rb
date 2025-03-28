require 'benchmark'
require 'pry'
require_relative 'check_abstract'
require_relative '../config'

module Checks
  class CheckClasses < CheckAbstract
    def initialize(ontology)
      @ontology = ontology
      super("Accessing #{ontology} classes page")
    end

    def self.run_benchmark(ontology)
      new(ontology).bench
    end

    private

    def process
      # Getting: https://data.stageportal.lirmm.fr/slices with {:display_links=>false, :display_context=>false} (t: 0.4009887919819448s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES with {:include_views=>true} (t: 0.33890245799557306s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/latest_submission with {:include=>"all"} (t: 0.8510312930156942s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/latest_submission with {:include_status=>"ready", :include=>"all"} (t: 0.597138626006199s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/classes/roots with {:include=>"prefLabel,definition,synonym,obsolete,hasChildren,inScheme,memberOf"} (t: 0.7190027920005377s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/classes/http%3A%2F%2Fopendata.inrae.fr%2FthesaurusINRAE%2Fd_1 with {:lang=>:EN, :include=>"prefLabel,definition,synonym,obsolete,properties,hasChildren,childre,inScheme,memberOf"} (t: 0.39541808399371803s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/schemes with {:language=>:EN} (t: 0.6322727919905446s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/collections with {:language=>:EN} (t: 0.4281233339861501s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/classes/http%3A%2F%2Fopendata.inrae.fr%2FthesaurusINRAE%2Fd_1/notes with {} (t: 0.3238130829995498s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/slices with {:display_links=>false, :display_context=>false} (t: 0.4176752920029685s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES with {:include_views=>true} (t: 0.3455597079882864s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/latest_submission with {:include=>"uriRegexPattern,preferredNamespaceUri"} (t: 0.4256322919973172s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/classes/http%3A%2F%2Fopendata.inrae.fr%2FthesaurusINRAE%2Fd_1 with {:lang=>"EN", :include=>"prefLabel,definition,synonym,obsolete,properties,hasChildren,childre,inScheme,memberOf"} (t: 0.39279616699786857s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/classes/http%3A%2F%2Fopendata.inrae.fr%2FthesaurusINRAE%2Fd_1/tree with {:include=>"prefLabel,hasChildren,obsolete", :lang=>"EN"} (t: 0.6918270000023767s - cache: miss)

      LinkedData::Client::Models::Slice.all
      ont = LinkedData::Client::Models::Ontology.find(@ontology, include_views: true) rescue nil
      return if ont.blank?

      ont.explore.latest_submission(include: 'all')
      ont.explore.latest_submission(include: 'all', include_status: 'ready')
      roots = ont.explore.roots
      concept = roots[0].explore.self(full: true, lang: 'EN') unless roots.empty? rescue nil


      ont.explore.schemes
      ont.explore.collections
      concept.explore.notes if concept

      # Bellow is another call do after the classes page is shown, to display the tree (so it is async but still interesting to measure)
      LinkedData::Client::Models::Slice.all
      ont = LinkedData::Client::Models::Ontology.find(@ontology, include_views: true)
      return if ont.blank?

      ont.latest_submission(include: 'uriRegexPattern,preferredNamespaceUri')
      concept.explore.tree(include: 'prefLabel,hasChildren,obsolete', lang: 'EN') if concept
    end
  end
end