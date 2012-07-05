module GeneticAlgorithm
  class HypothesisPool


    attr_accessor :selection
    attr_reader :hyp_space
    attr_writer :seed
    attr_reader :pool

    def initialize(hyp_space, seed)
      @verbosity = $ga_verbosity || 0
      puts "Initialising Hypothesis Pool".cyan
      @seed = seed # not thread-safe!
      @space_bounds = []
      @pool = []
      @hyp_space = hyp_space
      @hyp_space.each do |element|
        @space_bounds << element.length
      end
      printf "Hypothesis Space Size: ".cyan
      puts @space_bounds.inspect
      nil
    end

    def build(number)
      puts "Building #{number} random hypotheses with seed #@seed".cyan  if @verbosity >= 1

      #find out how long each chromosome should be
      max_length = BitString.max_bit_string_val(@space_bounds).to_s(2).length

      #build N random hypotheses
      number.times do |n|
        printf "#{n}: "  if @verbosity >= 2
        h = Hypothesis.new(@space_bounds, @seed + n)
        h.build_from_space(@hyp_space,max_length)
        @pool << h
      end
      nil
    end


    def iterate

    end

    def fittest
      @pool.first
    end

    #This method is not a true inspect - it doesn't return a string, rather directly puts.
    #This is because it can potentially take a hell of a long time to print, so we can see it in action rather than
    # saving it all up
    def inspect
      puts 'Inspecting Hypothesis Pool'.green
        @pool.each do |hyp|
          raw_selection = hyp.selection
          selection = raw_selection.each_with_index.map { |x,i| @hyp_space[i][x] }
              puts "#{selection.inspect}".green
        end
    end

    #def self.parse_bit_string(b_string)
    #
    #end
    #

    private
    def init_arr(hyp_space, seed)

    end


  end
end