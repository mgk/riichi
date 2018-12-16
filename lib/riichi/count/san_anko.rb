module Riichi::Count
  class SanAnko < Counter
    def points
      [2, 2]
    end

    def present?
      strictly_closed_sets.count do |set|
        Riichi::Tile.pung?(set) || Riichi::Tile.kong?(set)
      end == 3
    end
  end
end