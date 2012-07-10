#!/usr/bin/env ruby

require File.expand_path('../lib/genetic_algorithm', __FILE__)

if ARGV.count < 6
  puts "Usage: #{__FILE__} <arff_file> <fitness_measure> <fitness_threshold> <p (pool_size)> <r (probability)> <m (mutation_factor)> <iterations> [<verbosity 1..4> [<seed>]]"
  exit 1
end

params = {}

params[:in_file]           = ARGV[0]
params[:fitness_measure]   = ARGV[1].to_sym
params[:fitness_threshold] = ARGV[2].to_i
params[:pool_size]         = ARGV[3].to_i
params[:probability]       = ARGV[4].to_f
params[:mutation_factor]   = ARGV[5].to_i
params[:iterations]        = ARGV[6].to_i
params[:verbosity]         = (ARGV.length >= 8) ? ARGV[7].to_i : 2
params[:seed]              = (ARGV.length >= 9) ? ARGV[8].to_i : nil

#test file exists


if params[:verbosity] >=1
  printf "Running with: ".cyan
  puts params.inspect.cyan
end

$ga_verbosity = params[:verbosity]
ga = GeneticAlgorithm::Controller.new(params[:fitness_measure], params[:fitness_threshold], params[:pool_size], params[:probability], params[:mutation_factor])
ga.seed = params[:seed]
#ga.params[:in_file]="assets/balance-scale.arff"
ga.in_file= params[:in_file]
ga.iterations = params[:iterations]
ga.run
