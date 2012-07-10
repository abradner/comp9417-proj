module Enumerable
  def mode
    group_by do |e|
      e
    end.values.max_by(&:size).first
  end
end
