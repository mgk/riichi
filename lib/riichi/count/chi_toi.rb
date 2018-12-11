module Riichi::Count
  class ChiToi < Counter
    def points
      [0, 2]
    end

    def present?
      sets.length == 7
    end
  end
end
