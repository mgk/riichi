module Riichi::Count
  class SanShoku < Counter

    def points
      [1, 2]
    end

    def present?
      # group each chow by rank of first tile
      groups = chows.map(&:first).group_by(&:rank).values

      # look for 3 suits for any starting tile
      groups.any? { |g| Set.new(g.map(&:suit)).length == 3 }
    end

  end
end