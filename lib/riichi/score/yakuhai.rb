module Riichi::Score
  class Yakuhai < HandCounter
    # @return [Tile] tile type for this class, only
    # works for subclasses with names that match tile ids
    def tile
      id = self.class.name.split("::").last.downcase
      Riichi::Tile.get(id: id.to_sym)
    end

    def count
      # @see Hand.value_tiles
      multiplier = hand.value_tiles.count { |t| t == tile }

      # number of pungs of the given tile
      pungs = all_sets.map(&:first).count { |t| t == tile }

      pungs * multiplier
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
