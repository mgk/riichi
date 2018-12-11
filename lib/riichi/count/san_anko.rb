module Riichi::Count
  class SanAnko < Counter
    def points
      [2, 2]
    end

    # todo: ron tile cannot count towards closed pung (but tsumo tile can)
    def present?
      sets.count { |set|  Riichi::Tile.pung?(set) } == 3
    end
  end
end