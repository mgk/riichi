module Riichi::Count
  class Pinfu < Counter

    def points
      [0, 1]
    end

    def all_chows?
      closed_chows.length == 4
    end

    def valueless_atama?
      !hand.value_tiles.include?(atama[0])
    end

    def two_sided_wait?
      draw = hand.last_draw
      chows.any? do |chow|
        (draw == chow.first && draw.rank != 7) ||
          (draw == chow.last && draw.rank != 3)
      end
    end

    def present?
      closed? && all_chows? && two_sided_wait? && valueless_atama?
    end

  end
end
