module Riichi::Score
  class Honitsu < HandCounter
    def points
      [2, 3]
    end

    def present?
      suits = all_tiles.group_by(&:suit)
      suits.length == 2 && suits.include?(nil)
    end
  end
end
