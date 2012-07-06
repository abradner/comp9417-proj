module GeneticAlgorithm
  class Hypothesis

    BINARY = 2
    attr_reader :bit_string, :bs_length

    def initialize(space_bounds)
      @verbosity = $ga_verbosity || 0
      @space_bounds = space_bounds
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

      printf " #{selection.inspect} " if @verbosity >= 4

      raw_bin_selection = raw_int_selection.to_s(BINARY)
      padding << "0" * (pad_length - raw_bin_selection.length)
      self.bit_string = padding + raw_bin_selection #Todo pad bin string out to max length

      printf " #@bit_string ".yellow if @verbosity >= 4

      #printf " #{raw_int_selection} "

      puts selection.each_with_index.map { |x, i| hyp_space[i][x] }.inspect.red if @verbosity >= 3

      #Using the method that adds a decode is significantly slower, so it's just here for show.
      #This should eventually be moved to a test case
      #puts self.selection.each_with_index.map { |x,i| hyp_space[i][x] }.inspect.green

      nil
    end

    def selection
      BitString.decode(@space_bounds, bit_string.to_i(2))
    end

    def to_s
      selection.to_s
    end

    alias_method :inspect, :to_s


    def bit_string=(bs)
      @bit_string =bs
      @bs_length = bs.length
    end

    def hash
      @bit_string.to_i
    end

    def ==(other)
      self.hash == other.hash
    end

    def eql?(other)
      return false unless other.is_a? self.class
      @bit_string.eql? other.bit_string
    end

    def point_mutate
      return false if @bit_string.empty?
      index = rand(@bs_length)
      @bit_string[index] = invert(@bit_string[index])
    end

    def single_point_crossover(my_bits, other_parent)
      raise IndexError if @bs_length.eql? 0
      raise ArgumentError unless @bs_length.eql? other_parent.bs_length

      child = Hypothesis.new(@space_bounds)
      child.bit_string= @bit_string.slice(0, my_bits) + other_parent.bit_string.slice(my_bits, @bs_length - my_bits)

      child
    end

    private

    def invert(char)
      char.eql?(0) ? 1 : 0
    end

  end
end
