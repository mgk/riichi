module Riichi::Count
  class Pinfu < Counter

    def points
      [0, 1]
    end

    def all_chows?
      all_sets.all? { |set| Riichi::Tile.chow? set }
    end

    def valueless_atama?
      !hand.value_tiles.include?(atama[0])
    end

    def two_sided_wait?
      draw = hand.last_draw
      sets.any? do |set|
        (draw == set.first && draw.rank != 7) ||
          (draw == set.last && draw.rank != 3)
      end
    end

    def present?
      closed? && all_chows? && two_sided_wait? && valueless_atama?
    end

  end
end
