module Riichi::Count
  class Tanyao < Counter
    def points
      [1, 1]
    end

    def present?
      all_tiles.all?(&:simple?)
    end
  end
end
