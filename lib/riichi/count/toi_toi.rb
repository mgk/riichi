module Riichi::Count
  class ToiToi < Counter
    def points
      [2, 2]
    end

    def present?
      sets.all? { |set| Riichi::Tile.pung?(set) || Riichi::Tile.kong?(set) }
    end
  end
end
