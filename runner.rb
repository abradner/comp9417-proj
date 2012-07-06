#!/usr/bin/env ruby

require 'genetic_algorithm'

if ARGV.count < 6
  puts "Usage: #{__FILE__} <arff_file> <fitness_measure> <fitness_threshold> <p (pool_size)> <r (probability)> <m (mutation_factor)> <iterations> [<verbosity 1..4> [<seed>]]"
  exit 1
end

in_file           = ARGV[0]
fitness_measure   = ARGV[1].to_sym
fitness_threshold = ARGV[2].to_i
pool_size         = ARGV[3].to_i
probability       = ARGV[4].to_f
mutation_factor   = ARGV[5].to_i
iterations        = ARGV[6].to_i
verbosity         = (ARGV.length >= 8) ? ARGV[7].to_i : 2
seed              = (ARGV.length >= 9) ? ARGV[8].to_i : nil

#test file exists


$ga_verbosity = verbosity
ga = GeneticAlgorithm::Controller.new(fitness_measure, fitness_threshold, pool_size, probability, mutation_factor)
ga.seed = seed
#ga.in_file="assets/balance-scale.arff"
ga.in_file= in_file
ga.iterations = iterations
ga.run
