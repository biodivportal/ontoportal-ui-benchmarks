# frozen_string_literal: true
require 'optparse'
require 'uri'

# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: script.rb [options]"

  opts.on("-u", "--url URL", "Specify the URL to connect to") do |url|
    # Validate URL format
    begin
      uri = URI.parse(url)
      raise URI::InvalidURIError unless uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      options[:url] = url
    rescue URI::InvalidURIError
      puts "Error: Invalid URL format. Please provide a valid HTTP or HTTPS URL."
      exit 1
    end
  end

  opts.on("-k", "--apikey KEY", "Specify the API key") do |apikey|
    # Basic API key validation (you can customize this)
    if apikey.nil? || apikey.strip.empty?
      puts "Error: API key cannot be empty."
      exit 1
    end
    options[:apikey] = apikey
  end

  opts.on("--debug", "Enable debugging") do
    options[:debug] = true
  end

  opts.on("--cache cache", "Enable cache (true or false) by default true") do |cache|
    options[:cache] = cache.blank? || cache.eql?("true")
  end

  opts.on("--output-name name", "Enable cache (true or false) by default true") do |name|
    options[:output_name] = name
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

# Check if required options are provided
if options[:url].nil?
  puts "Error: URL is required. Use -u or --url to specify."
  exit 1
end

if options[:apikey].nil?
  puts "Error: API key is required. Use -k or --apikey to specify."
  exit 1
end

$url = options[:url]
$apikey = options[:apikey]
$runs = options[:runs] || 1
$debug = options[:debug] || false
$cache = options[:cache] || true
$output_name = options[:output_name] || "performance_data"
require_relative 'config'
require_relative 'checks/check_summary'
require_relative 'checks/check_home'
require_relative 'checks/check_browse'
require_relative 'checks/check_classes'
def not_valid_apikey
  result = LinkedData::Client::Models::Metrics.all
  Array(result).first&.error != nil
end

if not_valid_apikey
  puts "Error: Invalid API key. Please provide a valid API key."
  exit 1
end

puts "Running benchmarks..."
# Check home page
puts "Checking home page..."
r1 = Checks::CheckHome.run_benchmark
puts "✔︎"

# Check browse page
puts "Checking browse page..."
r2 = Checks::CheckBrowse.run_benchmark
puts "✔︎"

# Check summary page (sample 10)

def rand_ontologies_bench(title, &block)
  Rails.cache.clear
  @ontologies = LinkedData::Client::Models::Ontology.all(include: 'acronym', display_links: false, display_context: false, also_include_views: true).sample(10)
  puts "Checking #{title} for 10 random ontologies...(#{@ontologies.map(&:acronym).uniq.join(', ')})" if $debug
  require 'parallel'
  results = Parallel.map(@ontologies, in_process: 1) do |ontology|
    require_relative 'config'
    block.call(ontology)
  end

  raise "No results" if results.empty?

  Checks::Result.new.tap do |avg|
    avg.title = title
    avg.avg_time = results.sum(&:avg_time) / results.length
    avg.min_time = results.sum(&:min_time) / results.length
    avg.max_time = results.sum(&:max_time) / results.length
    avg.num_calls = results.sum(&:num_calls) / results.length
  end
end

puts "Checking summary page (sample 10)..."
r3 = rand_ontologies_bench("Average summary page (sample 10)") do |ontology|
  Checks::CheckSummary.run_benchmark(ontology.acronym)
end
puts "✔︎"

# Check classes page (sample 10)
puts "Checking classes page (sample 10)..."
r4 = rand_ontologies_bench("Average classes page (sample 10)") do |ontology|
  Checks::CheckClasses.run_benchmark(ontology.acronym)
end

results= [
       r1.to_h,
       r2.to_h,
       r3.to_h,
       r4.to_h,
     ]

require 'csv'
require 'time'
current_datetime = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
CSV.open("performance_#{$output_name}_#{current_datetime}.csv", "w") do |csv|
  # Write header
  csv << results.first.keys

  # Write data rows
  results.each do |row|
    csv << row.values
  end
end

