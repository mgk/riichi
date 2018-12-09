module Riichi::Score
  class Chinitsu < HandCounter
    def points
      [5, 6]
    end

    def present?
      all_tiles.all? do |tile|
        tile.suited? && tile.suit == all_tiles.first.suit
      end
    end
  end
end
