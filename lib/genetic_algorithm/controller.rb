module GeneticAlgorithm
  class Controller
    CLASS_ATTRIBUTE = 'class'
    THREADS = 4

    attr_accessor :seed, :working_dir, :in_file, :iterations
    attr_reader :pool

    def initialize (fitness_measure, fitness_threshold, p, r, m)
      @verbosity = $ga_verbosity || 0
      @fitness = fitness_measure
      @fitness_threshhold = fitness_threshold
      @pool_size = p
      @probability = r
      @mutation_factor = m
      @hypotheses = []
      @attributes = []
      @spaced_instances = []
      @test_instances = []
      @real_instances = []
    end

    def run
      raise ArgumentError 'no input file. use #in_file= to specify a file' unless @in_file
      puts "Initialising, with seed #@seed using #{THREADS} threads and Verbosity #{@verbosity}".blue if @verbosity >= 1
      load_relationship
      wait_for_user if @verbosity >= 5
      load_attributes
      wait_for_user if @verbosity >= 5
      discover_hypothesis_space
      wait_for_user if @verbosity >= 5
      convert_instances_to_space
      wait_for_user if @verbosity >= 5
      separate_test_and_unknown_instances
      wait_for_user if @verbosity >= 5
      build_hypos
      wait_for_user if @verbosity >= 5
      evolve

      #build_hypos
      #@@fitness_tests[rule].call answer, related_answer, checker_params
      #evaluate([fitness])
      #
      #
      #while @best_fitness < fitness_threshold do
      #  @best_fitness = evolve
      #end
      #
      #
      #select_best
    end

    def wait_for_user
      $stdin.gets 'Enter to continue'
    end

    def load_relationship
      puts "Loading Relationship".blue if @verbosity >= 1
      raise if @in_file.nil?

      @rel = Rarff::Relation.new
      @rel.parse(File.open(@in_file).read)
    end

    def load_attributes
      puts "Loading Attributes".blue if @verbosity >= 1
      @attributes = @rel.attributes
      puts "Attributes: #{@attributes.map { |a| a.name }.inspect}".cyan if @verbosity >= 2
    end

    def discover_hypothesis_space()
      puts "Discovering Hypothesis Space".blue 0 if @verbosity >= 1
      @hypothesis_space = []
      @attributes.each_with_index do |attr, idx|
        attribute_space = []
        attribute_space << nil unless attr.name.eql?(CLASS_ATTRIBUTE)
        if attr.nominal?
          attribute_space += attr.type
        else
          @rel.instances.each do |instance|
            attribute_space << instance[idx] unless instance[idx].eql?('?')
          end
        end
        attribute_space.uniq!
        @hypothesis_space << attribute_space
      end
      puts pretty_explain_hyp_space if @verbosity >= 2
    end

    def convert_instances_to_space
      puts "Converting #{@rel.instances.count} instances to hypothesis space".blue if @verbosity >= 1
      @rel.instances.each do |inst|
        spaced_inst = inst.each_with_index.map { |x, i| @hypothesis_space[i].find_index(x) }
        @spaced_instances << spaced_inst
        puts "#{spaced_inst.inspect}".yellow if @verbosity >= 4
      end
    end

    def separate_test_and_unknown_instances
      puts "Separating Test and Unknown instances".blue if @verbosity >= 1
      @spaced_instances.each do |inst|
        if inst.index(nil) # If we can find an index for an attribute with an unknown {?} value (nil in the space)
          @real_instances << inst
        else
          @test_instances << inst
        end
      end
      puts "#{@test_instances.count} Test and #{@real_instances.count} Unknown instances".cyan if @verbosity >= 2
    end

    def build_hypos
      @pool = HypothesisPool.new(@hypothesis_space, @test_instances, @seed, @probability, @mutation_factor, THREADS)
      @pool.populate(@pool_size)
    end

    def evolve
      @iterations.times do
        @pool.iterate

        if @verbosity >= 3
          @pool.ranked_pool.each_with_index do |f, idx|
            next if f.empty?
            puts "#{idx}: #{f.inspect}".yellow
          end
        end

        fittest = @pool.fittest(-1)
        if @verbosity >= 2
          puts "Fittest:".cyan

          human_fittest = fittest.map { |h| h.selection.each_with_index.map { |x, i| @hypothesis_space[i][x.to_i] } }
          human_fittest.each do |f|
            puts f.inspect.green
          end
        end
      end
    end


    def select_best

    end

    def pretty_explain_rel
      @rel.in
    end

    def pretty_explain_hyp_space
      "Hypothesis Space: #{@hypothesis_space.inspect}".cyan
    end

    def pretty_present_fittest_hyp
      @pool.fittest.inspect.green

    end


  end
end

#class DataSet
#
#  def initialize
#      @ds = []
#  end
#
#  def insert(*arry)
#      @ds += arry
#      @ds.sort!
#  end
#
#  def select(n)
#     @ds.first(n)
#  end
#
#end
