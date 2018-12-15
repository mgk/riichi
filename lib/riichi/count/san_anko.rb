module Riichi::Count
  class SanAnko < Counter
    def points
      [2, 2]
    end

    def present?
      closed_pungs_and_kongs.length == 3
    end
  end
end