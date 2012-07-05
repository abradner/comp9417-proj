#!/usr/bin/env ruby

require 'genetic_algorithm'
$ga_verbosity = 3

ga = GeneticAlgorithm::Controller.new(nil, nil, 10000, nil, nil)
ga.seed = 2
#ga.in_file="assets/balance-scale.arff"
ga.in_file="assets/mushroom.arff"
ga.run
