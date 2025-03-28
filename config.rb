# frozen_string_literal: true
require 'ontologies_api_client'
require 'active_support'
require 'pry'

module Rails
  class Application
    # Mock cache store configuration
    def self.cache_store=(store)
      # Placeholder for cache store configuration
    end
  end

  # Implement a basic cache method
  def self.cache
    @cache ||= Cache.new
  end

  # Cache implementation
  class Cache
    def initialize
      @store = ActiveSupport::Cache::MemoryStore.new(
      size: 32.megabytes,  # Optional: limit cache size
      expires_in: 1.hour   # Optional: default expiration
    )
    end

    def write(key, value, options = {})
      @store.write(key, value, options)
    end

    def read(key)
      @store.read(key)
    end

    def delete(key)
      @store.delete(key)
    end

    def exist?(key)
      @store.exist?(key)
    end
    def clear
      entry_count = @store.instance_variable_get(:@data).size
      @store.clear
      after_count = @store.instance_variable_get(:@data).size
      puts "Clearing cache (#{entry_count} entries removed - #{after_count} remaining)" if $debug
    end
  end
end


def clear_cache
  Rails.cache.clear
end

$DEBUG_API_CLIENT = true
$API_CLIENT_INVALIDATE_CACHE = !$cache
LinkedData::Client.config do |config|
  LinkedData::Client.instance_variable_set("@settings_run", false)
  config.rest_url = $url
  config.apikey = $apikey
  config.cache = $cache
  config.debug_client = false
  config.debug_client_keys = []
  config.federated_portals = {}
end