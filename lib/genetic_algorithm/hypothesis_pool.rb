module GeneticAlgorithm
  class HypothesisPool



    attr_reader :hyp_space, :pool, :ranked_pool
    attr_writer :seed
    @@fitness_tests = {}

    def initialize(hyp_space, test_instances, seed, probability, mutation_factor, threads)
      @verbosity = $ga_verbosity || 0
      puts "Initialising Hypothesis Pool".blue if @verbosity >= 1
      seed ? srand(@seed = seed) : @seed = srand() # not thread-safe. and kind of weird, but still fine.

      @probability = probability
      @mutation_factor = mutation_factor
      @threads = threads
      @population =0
      @generation = 0
      @space_bounds = []
      @pool = []
      @ranked_pool = []
      @test_instances = []
      @test_count = test_instances.count
      @perfect_hypotheses_found = false # do we have any hypotheses that satisfy all test cases?
      @hyp_space = hyp_space
      @hyp_space.each do |element|
        @space_bounds << element.count
      end

      prepare_test_instances(test_instances)

      if @verbosity >= 2
        printf "Hypothesis Space Size: ".cyan
        puts @space_bounds.inspect
      end
      nil
    end

    def self.register_fitness_test(rule, block)
      # Call register_fitness_test with the rule 'code' of your check.
      # Supply a block that takes the hypothesis and returns a value relating
      # to the fitness of the hypothesis
      @@fitness_tests[rule] = block
    end

    def prepare_test_instances(instances)
      slices = ((instances.count)/(@threads.to_f)).ceil
      instances.each_slice(slices) do |i_chunk|
        @test_instances << i_chunk
      end
    end


    def populate(number)
      @population = number
      #TODO also include maximally general cases
      @max_length = BitString.max_bit_string_val(@space_bounds).to_s(2).length
      build(number)
    end

    def build(number)
      puts "Building #{number} random hypotheses".blue if @verbosity >= 1
      one_percent = number/100

      #find out how long each chromosome should be

      #build N random hypotheses
      number.times do |n|
        case @verbosity
          when 0, 1
          when 2
            OutputTools.print_percentage(n, number) if ((n+1)% one_percent).eql?(0)
          else
            printf "#{n}: "
        end
        h = Hypothesis.new(@space_bounds)
        h.build_from_space(@hyp_space, @max_length)
        @pool << h
      end
      nil
    end


    def iterate
      #if @perfect_hypotheses_found
      #  puts 'got one'.red
      #  fittest(-1).inspect
      #  exit 0 # lolol hulk smash
      #else
        OutputTools.print_generation @generation if @verbosity >=1
        puts if @verbosity >=2
        select_survivors!
        breed!
        mutate_generation!
        cull_migrate_integrate!
        sort_pool_by_fitness!
        cull_overpopulation! #unless @perfect_hypotheses_found
        @generation +=1
      #end

    end

    #returns the fittest or (n) fittest hypotheses. if (n) is negative, returns all of the current best hypotheses
    def fittest(n = nil)
      if n && n < 0
        @ranked_pool.each do |hyp_arr|
          break hyp_arr unless hyp_arr.eql? []
        end
      else
        n.nil? ? @pool.first : @pool.first(n)
      end
    end

    #This method is not a true inspect - it doesn't return a string, rather directly puts.
    #This is because it can potentially take a hell of a long time to print, so we can see it in action rather than
    # saving it all up
    def inspect
      puts 'Inspecting Hypothesis Pool'.green
      @pool.each do |hyp|
        raw_selection = hyp.selection
        selection = raw_selection.each_with_index.map { |x, i| @hyp_space[i][x] }
        puts "#{selection.inspect}".green
      end
    end

    #def self.parse_bit_string(b_string)
    #
    #end
    #

    # Returns an integer value of the number of passed test cases.
    # The best case is (test_instances.count)
    # While it could definitely be finer grained based on specifity of algorithm,
    # given the size of the hyp space,this is sufficient
    # This algorithm assumes the last element is the class.
    #   - this behaviour can be changed by adding a class_elements param and
    #     iterating the first test through them
    # Programs spend 90% of their time in 10% of their code.... more like 99vs1
    # The fitter a hypothesis is, the longer this will take
    def test_for_fitness(hyp)
      fitness = 0


      arr = []
      @test_instances.count.times do |i|
        arr[i] = Thread.new { HypothesisPool.test_worker(hyp.selection, @test_instances[i]) }
      end

      arr.each do |t|
        t.join; fitness += t[:fitness]
      end
      fitness
    end

    def self.test_worker(selection, chunk)
      fitness = 0
      chunk.each do |inst|
        #is this a positive or negative example?
        if selection.last.eql?(inst.last)
          #positive
          #Since it's positive, we can assume it's true unless an attribute actively differs ({?} is considered a match)
          valid = true
          selection.each_with_index do |attr, idx|
            break if attr.eql? selection.last
            next if attr.eql? 0 #If the hypothesis has a "{?}" for this attr we can skip it
            valid &= attr.eql?(inst[idx])
            break unless valid
          end
          fitness += 1 if valid
        else
          #negative
          #Since it's a negative case, we must find a difference in these attributes. {?} counts as the same
          valid = false
          selection.each_with_index do |attr, idx|
            break if attr.eql? selection.last
            valid ||= !(attr.eql?(inst[idx]) || attr.eql?(0))
            break if valid
          end
          fitness -= 1 unless valid
        end


      end
      Thread.current[:fitness] = fitness
      nil
    end

    private
    def select_survivors!
      #todo rounding
      fit_selection = @pool.length * (1.0-@probability)
      @pool_s = @pool[0, fit_selection] # collect the fittest bunch TODO make this closer to the actual GA selector
    end

    def breed!
      @pool.shuffle! # we don't need it in order anymore since our sort function is basically a counting sort
      breeder_selection = (@pool.length * @probability)/2
      breeder_selection-=(breeder_selection%2).eql?(0) ? 0 : 1 # even number of partners
      orgy = @pool[0, breeder_selection]

      offspring = []
      while @pool.count >= 2

        p1 = @pool.pop
        p2 = @pool.shift
        dominance = rand(p1.bs_length)

        offspring << p1.single_point_crossover(dominance, p2)
        offspring << p2.single_point_crossover(dominance, p1)

      end

      @pool_s = @pool_s | offspring

    end

    def mutate_generation!

      @pool_s.shuffle!

      @mutation_factor.times do |idx|
        @pool_s[idx].point_mutate
      end


    end

    #if the pool shrinks  due to rounding/uniq, introduce new, random hyps
    def cull_migrate_integrate!
      @pool = @pool_s
      @pool_s = nil #free up the pool for the benefit of the GC

        @pool.uniq! #This is SLOW
      if @population > @pool.length
        build(@population - @pool.length)
      end
      nil

    end

    #if rounding introduced extra population, kill off stragglers
    def cull_overpopulation!
      if @population < @pool.length
        @pool.pop(@pool.length - @population)
      end
    end

    # an O(n) sort of hypotheses into fitness order.
    # equally fit hypothesis will appear first in each fitness bracket
    def sort_pool_by_fitness!
      puts "Sorting Pool".yellow if @verbosity >=2
      num_instances = @test_count
      sorted_pool = Array.new(2*(num_instances+1)) { [] } # create a (large) 2D array for storing instances
      one_percent = @pool.count/100
      number = @pool.count
      OutputTools.print_percentage(0, 100) if @verbosity >= 2
      @pool.each_with_index do |hyp, n|
        fitness = test_for_fitness(hyp)
        sorted_pool[num_instances - fitness] << hyp
        OutputTools.print_percentage(n, number) if (@verbosity >= 2) &&(((n+1)% one_percent).eql?(0))
      end
      puts
      #if sorted_pool[num_instances].count > 0 #We found one!
      #  @perfect_hypotheses_found = true
      #end
      @ranked_pool = sorted_pool #gogo gadget garbage collector!
      @pool = sorted_pool.flatten #This does a shallow copy, so we aren't duplicating the pool
      nil
    end


    ## These are the actual tests for fitness

    register_fitness_test 'vs_target_set', lambda { |*params|
      0
    }

  end
end