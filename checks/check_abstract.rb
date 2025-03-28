# frozen_string_literal: true
require_relative '../config'
require 'stringio'

module Kernel
  @@puts_count = 0
  @@enable_count_puts = false
  def self.puts_count
    @@puts_count ||= 0
  end

  def self.enable_count_puts
    @@enable_count_puts = true
    @@puts_count = 0
  end

  def self.disable_count_puts
    @@enable_count_puts = false
    @@puts_count = 0
  end


  alias_method :original_puts, :puts
  def puts(*args)
      @@puts_count += 1 if @@enable_count_puts

      original_puts(*args) if !@@enable_count_puts || $debug
  end
end

module Checks
  class Result
    attr_accessor :title, :avg_time, :min_time, :max_time, :num_calls

    def initialize
      @title = ""
      @avg_time = 0
      @min_time = 0
      @max_time = 0
      @num_calls = 0
    end

    def to_s
      "#{@title} result: #{avg_time}s (Min:#{min_time}s, Max:#{max_time}s) - #{@num_calls} API calls"
    end

    def to_h
      {
        title: @title,
        avg_time: @avg_time,
        # min_time: @min_time,
        # max_time: @max_time,
        num_calls: @num_calls
      }
    end
  end

  class CheckAbstract
    def initialize(title, runs = $runs)
      @runs = runs
      @times = []
      @title = title
    end

    def self.run_benchmark
      new.bench
    end

    def setup
    end

    def bench
      puts "\nRunning #{@title} benchmark with #{@runs} runs" if $debug
      setup
      clear_cache
      num_calls = 0
      @runs.times do |i|
        time = Benchmark.realtime do
          Kernel.enable_count_puts
          begin
            process
            num_calls = Kernel.puts_count
            Kernel.disable_count_puts
          rescue Exception => ex
            Kernel.disable_count_puts
            puts "Error: #{ex.message}"
            raise ex if $debug
          end
        end
        @times << time
      end

      avg_t, min_t, max_t = calculate_stats
      result = Result.new
      result.title = @title
      result.avg_time = avg_t
      result.min_time = min_t
      result.max_time = max_t
      result.num_calls = num_calls
      puts result if $debug
      result
    end

    private
    def calculate_stats
      return if @times.empty?
      min_time = @times.min
      max_time = @times.max
      avg_time = @times.sum / @times.size
      [avg_time, min_time, max_time]
    end

    def process
      raise NotImplementedError, "You must implement the process method"
    end
  end
end
