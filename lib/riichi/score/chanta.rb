module Riichi::Score
  class Chanta < HandCounter
    def points
      [1, 2]
    end

    def present?
      all_sets_have_outside_tile = all_sets.all? do |set|
        set.any? { |tile| tile.terminal? || tile.honour? }
      end
      has_chow = all_sets.any? { |set| Riichi::Tile.chow?(set) }
      has_suit = all_sets.flatten.any?(&:suited?)
      has_honour = all_sets.flatten.any?(&:honour?)

      all_sets_have_outside_tile &&
        has_chow &&
        has_suit &&
        has_honour
    end
  end
end