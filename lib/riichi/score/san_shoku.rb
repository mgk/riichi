module Riichi::Score
  class SanShoku < HandCounter

    def points
      [1, 2]
    end

    def present?
      # group each chow by rank of first tile
      chows = all_sets.find_all { |set| Tile.chow?(set) }
      groups = chows.map(&:first).group_by(&:rank).values

      # look for 3 suits for any starting tile
      groups.any? { |g| Set.new(g.map(&:suit)).length == 3 }
    end

  end
end