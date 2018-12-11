module Riichi::Count
  class ToiToi < Counter
    def points
      [2, 2]
    end

    def present?
      all_sets.all? { |set| Riichi::Tile.pung?(set) }
    end
  end
end
