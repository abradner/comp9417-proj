module GeneticAlgorithm
  class Controller
    CLASS_ATTRIBUTE = 'class'

    attr_accessor :seed, :working_dir, :in_file
    attr_reader :pool
    @@fitness_tests = {}

    def initialize (fitness_measure, fitness_threshold, p, r, m)
      @verbosity = $ga_verbosity || 0
      @fitness = fitness_measure
      @fitness_threshhold = fitness_threshold
      @pool_size = p
      @probability = r
      @mutation_factor = m
      @hypotheses = []
      @attributes = []
      #@seed = srand
    end

    def run
      raise ArgumentError 'no input file. use #in_file= to specify a file'  unless @in_file
      puts "Initialising".blue if @verbosity > 0
      load_relationship
      load_attributes
      discover_hypothesis_space
      build_hypos

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

    def load_relationship
      puts "Loading Relationship".blue if @verbosity > 0
      raise if @in_file.nil?

      @rel = Rarff::Relation.new
      @rel.parse(File.open(@in_file).read)
    end


    def self.register_fitness_test(rule, block)
      # Call register_fitness_test with the rule 'code' of your check.
      # Supply a block that takes the hypothesis and returns a value relating
      # to the fitness of the hypothesis
      @@fitness_tests[rule] = block
    end

    def load_attributes
      puts "Loading Attributes".blue if @verbosity > 0
      @attributes = @rel.attributes
      puts "#{@attributes.inspect}".cyan
    end

    def discover_hypothesis_space()
      puts "Discovering Hypothesis Space".blue if @verbosity > 0
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
      pretty_explain_hyp_space if @verbosity > 1
    end


    def build_hypos
      @pool = HypothesisPool.new(@hypothesis_space, @seed)
      @pool.build(@pool_size)
    end

    def evaluate(fitness)

    end

    def evolve

    end


    def select_best

    end

    def pretty_explain_rel
      puts @rel.in
    end

    def pretty_explain_hyp_space
      puts "#{@hypothesis_space.inspect}".cyan

    end

    def pretty_present_fittest_hyp
      @pool.fittest.inspect.green

    end


    register_fitness_test 'something', lambda { |*params|
      0
    }

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
