# encoding: utf-8
module GeneticAlgorithm
  require 'rarff'
  require "colorize"

  require File.expand_path('../enumerable', __FILE__)

  #if RUBY_VERSION > 1.9
  require File.expand_path('../genetic_algorithm/controller', __FILE__)
  require File.expand_path('../genetic_algorithm/hypothesis_pool', __FILE__)
  require File.expand_path('../genetic_algorithm/hypothesis', __FILE__)
  require File.expand_path('../genetic_algorithm/bit_string', __FILE__)
  require File.expand_path('../genetic_algorithm/output_tools', __FILE__)
end
