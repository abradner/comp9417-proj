module GeneticAlgorithm
  class OutputTools
    def self.print_percentage(n, tot)
      completion = (100*(n+1))/tot
      printf((completion < 100 ? "\rProgress:  %02d\%" : "\rProgress: %3d\%"), completion)
      $stdout.flush
    end
  end
end