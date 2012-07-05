module GeneticAlgorithm
  class BitString
    BINARY = 2
    #this is the bit where we pick a random element and offset it by the magnitude of the prior elements.
    # basically basically a binary left-shift by the number of digits, then close the gap left over
    def self.encode(bounds, selection)

      net_shift_bits = 0
      net_overlap_bits = 0
      value = 0
      bounds.each_with_index do |attr, idx|
        value += (selection[idx] * (BINARY**net_shift_bits)) - net_overlap_bits #brackets for clarity

        next_shift_bits = log2(attr).ceil
        next_overlap_bits = BINARY**next_shift_bits - attr

        net_shift_bits += next_shift_bits
        net_overlap_bits += next_overlap_bits

      end
      value.to_i
    end

    def self.decode(bounds, value)
      shift_bits = [0]
      offset_bits = [0]
      selection = []

      #precalculate culmulative shifts and offsets
      bounds.each do |attr|
        next_shift_bits = log2(attr).ceil
        shift_bits << shift_bits.last + next_shift_bits
        offset_bits << offset_bits.last + (BINARY**next_shift_bits - attr)
      end

      #get rid of unimportant last value
      shift_bits.pop
      offset_bits.pop

      # calculate the selection
      bounds.each do |attr|
        offset = offset_bits.pop
        shift = shift_bits.pop
        current_element = (value + offset) >> shift
        selection.unshift current_element
        value -= (current_element * BINARY**shift) - offset

      end
      selection
    end

    def self.max_bit_string_val(bounds)
      self.encode(bounds,bounds.map{|x| x.eql?(0) ? x : x-1})
    end

    private

    # change of base since log2 isn't in ruby 1.8.7
    def self.log2(num)
      (Math.log(num)/Math.log(BINARY))
    end

  end
end
