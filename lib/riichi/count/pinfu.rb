module Riichi::Count
  class Pinfu < Counter

    def points
      [0, 1]
    end

    def present?
      fu == 0
    end

  end
end
