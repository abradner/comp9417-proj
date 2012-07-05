module GeneticAlgorithm
  class Hypothesis

    BINARY = 2
    attr_accessor :bit_string

    def initialize(space_bounds, seed)
      @verbosity = $ga_verbosity || 0
      @space_bounds = space_bounds
      @seed = seed
      srand(@seed)
      nil
    end

    def build_from_space(hyp_space, pad_length)
      printf 'Building Hypothesis:'.yellow if @verbosity >= 3
      selection = []
      padding = ""
      hyp_space.each do |attr|
        selection << rand(attr.length)
      end

      raw_int_selection = BitString.encode(@space_bounds, selection)

      printf " #{selection.inspect} "  if @verbosity >= 4

      raw_bin_selection = raw_int_selection.to_s(BINARY)
      padding << "0" * (pad_length - raw_bin_selection.length)
      @bit_string = padding + raw_bin_selection #Todo pad bin string out to max length

      printf " #@bit_string ".yellow  if @verbosity >= 4

      #printf " #{raw_int_selection} "

      puts selection.each_with_index.map { |x, i| hyp_space[i][x] }.inspect.green  if @verbosity >= 3

      #Using the method that adds a decode is significantly slower, so it's just here for show.
      #This should eventually be moved to a test case
      #puts self.selection.each_with_index.map { |x,i| hyp_space[i][x] }.inspect.green

      nil
    end

    def selection
      BitString.decode(@space_bounds, bit_string.to_i(2))
    end

    def inspect
      selection
    end


    private

    def point_mutate
      return false if @bit_string.empty?
      srand seed
      index = rand(@bit_string.length)
      @bit_string[index] = !@bit_string[index]
    end

    def single_point_crossover(my_bits, other_parent)
      length = self.length
      raise IndexError if length.eql? 0
      raise ArgumentError unless length.eql? other_parent.length

      @bit_string.take(my_bits).concat(other_parent.to_a.slice(my_bits, length - my_bits))
    end

  end
end
