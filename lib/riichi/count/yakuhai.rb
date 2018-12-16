module Riichi::Count
  class Yakuhai < Counter
    # @return [Tile] tile type for this class, only
    # works for subclasses with names that match tile ids
    def tile
      id = self.class.name.split("::").last.downcase
       Riichi::Tile.get(id: id.to_sym)
    end

    def yaku_count
      # @see Hand.value_tiles
      multiplier = hand.value_tiles.count { |t| t == tile }

      # number of sets (pungs or kongs) of the given tile
      count = (pungs + kongs).map(&:first).count { |t| t == tile }

      count * multiplier
    end

    def present?
      count > 0
    end
  end

  class Ton < Yakuhai; end
  class Nan < Yakuhai; end
  class Sha < Yakuhai; end
  class Pei < Yakuhai; end

  class Haku < Yakuhai; end
  class Hatsu < Yakuhai; end
  class Chun < Yakuhai; end
end
