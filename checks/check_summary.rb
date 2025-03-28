require 'benchmark'
require 'pry'
require_relative 'check_abstract'
require_relative '../config'

module Checks
  class CheckSummary < CheckAbstract
    def initialize(ontology)
      @ontology = ontology
      super("Accessing #{ontology} summary page")
    end

    def self.run_benchmark(ontology)
      new(ontology).bench
    end

    private
    def process
      # Getting: https://data.stageportal.lirmm.fr/slices with {:display_links=>false, :display_context=>false} (t: 0.43917033399338834s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES with {:include_views=>true} (t: 1.364801042014733s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/latest_submission with {:include=>"all"} (t: 0.7485983330116142s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/metrics with {} (t: 0.3932585839938838s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/projects with {} (t: 0.3584082089946605s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/analytics with {} (t: 0.3600247089925688s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/ontologies/INRAETHES/views with {:include=>"all"} (t: 0.34040300000924617s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/AG-ENG with {} (t: 1.3774686680117156s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/AG-RES with {} (t: 0.33863924999604933s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/AGRI with {} (t: 0.3921597919834312s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/ANIM with {} (t: 0.42050254199421033s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/BIODIV with {} (t: 0.40253941700211726s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/BIOTECH with {} (t: 0.33573166700080037s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/BOTA with {} (t: 0.39392608299385756s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/CULT with {} (t: 0.40340725000714883s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/EARTH with {} (t: 0.39587795798433945s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/ECO with {} (t: 0.41528525002649985s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/ENTOM with {} (t: 0.41044487498584203s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/ENV with {} (t: 0.40228312599356286s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/FISH with {} (t: 0.4042758750147186s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/FOOD with {} (t: 0.35716166702331975s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/FOREST with {} (t: 1.4258312090241816s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/GENE with {} (t: 0.35554391698678955s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/HEALTH with {} (t: 0.34887766602332704s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/NAT-RES with {} (t: 0.3559425419953186s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/NUT with {} (t: 11.409908380999696s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/PHENO with {} (t: 0.5183192499971483s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/PHYS with {} (t: 0.35571512501337565s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/PLANT with {} (t: 0.4279435419884976s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/PLANT-PHY with {} (t: 0.3574265000061132s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/RURAL with {} (t: 0.3897669170110021s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/categories/AGRICULTURE with {} (t: 0.33956554101314396s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/groups/INRAE with {} (t: 0.3797537919890601s - cache: miss)
      # Getting: https://data.stageportal.lirmm.fr/groups/INRAE with {} (t: 0.3779172920039855s - cache: miss)
      LinkedData::Client::Models::Slice.all
      ont = LinkedData::Client::Models::Ontology.find(@ontology, include_views: true) rescue nil
      return if ont.blank?
      ont.latest_submission(include: 'all')
      ont.explore.metrics
      ont.explore.pojects
      LinkedData::Client::HTTP.get(ont.links['analytics'])
      domains = Array(ont.hasDomain)
      domains.each do |domain|
        LinkedData::Client::Models::Category.find(domain.split('/').last)
      end
      groups = Array(ont.group)
      groups.each do |group|
        LinkedData::Client::Models::Group.find(group.split('/').last)
      end

      sleep(0.5) # Simulate FAIR processing time
    end
  end
end