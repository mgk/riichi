module Riichi::Score
  class Tanyao < HandCounter
    def points
      [1, 1]
    end

    def present?
      all_tiles.all?(&:simple?)
    end
  end
end
