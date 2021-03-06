module Riichi::Count
  class Ittsu < Counter

    def points
      [1, 2]
    end

    def present?
      # group the chows by suit
      suits = chows.group_by { |chow| chow.first.suit }.values

      # look for any suit that has the required 3 chows
      suits.any? do |suit_chows|
        starting_tiles = Set.new(suit_chows.map(&:first).map(&:rank))
        starting_tiles.superset?(Set[1, 4, 7])
      end
    end
  end
end

