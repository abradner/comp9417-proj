module GeneticAlgorithm
  WORKING_DIR = 'datasets'
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


  class DataSet <Array

    def + (other_array)
      super (other_array)
      self.sort!
    end

  end


  class BitString
    def initialize(length)
      @b_string = Array.new(length, false)
    end

    def length
      @b_string.length
    end


    def to_s
      str = ""
      @b_string.each do |c|
        str << c ? '1' : '0'
      end
    end

    protected
    def to_a
      @b_string
    end

  end


  class Attribute
    attr_reader :options_count
    attr_reader :options

    def initialize(options_hash)
      self.options_count = options_hash.count
      self.options = {:unused => ''}
      options_hash.each do |opt|
      end
    end

  end

  class AttributeOption

    attr_reader value
    attr_accessor mask

    def initialize(value)
      self.value = value
    end
  end

  class Runner
    def initialize(file = nil)
      if file.nil? raise "need a file"
        @data_file = file

        attributes = []
        raise 'no attrs' if true
        attributes.each do |attr|
        end

      end


    end
  end


  private
  def select

  end

  def crossover

  end

  def mutate

  end

  def update

  end

  def evaluate

  end
end