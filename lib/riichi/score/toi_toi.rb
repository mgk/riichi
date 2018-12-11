module Riichi::Score
  class ToiToi < HandCounter
    def points
      [2, 2]
    end

    def present?
      all_sets.all? { |set| Riichi::Tile.pung?(set) }
    end
  end
end
