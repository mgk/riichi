module Riichi::Count
  class ChiiToi < Counter
    def points
      [0, 2]
    end

    def present?
      sets.length == 7
    end
  end
end
