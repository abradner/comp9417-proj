module GeneticAlgorithm
  class OutputTools
    def self.print_percentage(n, tot)
      completion = (100*(n+1))/tot
      printf((completion < 100 ? "\rProgress:  %02d\%" : "\rProgress: %3d\%"), completion)
      $stdout.flush
    end
    def self.print_generation(n)
      digits = n.to_s.length
      $stderr.printf("\rGeneration:  %0#{digits}d", n)
      $stderr.flush

      printf("\rGeneration:  %0#{digits}d", n)
      $stdout.flush
    end
  end
end