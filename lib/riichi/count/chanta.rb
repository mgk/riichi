module Riichi::Count
  class Chanta < Counter
    def points
      [1, 2]
    end

    def present?
      all_sets_have_outside_tile = sets.all? do |set|
        set.any? { |tile| tile.terminal? || tile.honour? }
      end
      has_chow = !chows.empty?
      has_suit = sets.flatten.any?(&:suited?)
      has_honour = sets.flatten.any?(&:honour?)

      all_sets_have_outside_tile &&
        has_chow &&
        has_suit &&
        has_honour
    end
  end
end