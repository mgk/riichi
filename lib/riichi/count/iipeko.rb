module Riichi::Count
  class Iipeko < Counter

    def points
      [0, 1]
    end

    def present?
      closed_chows.group_by(&:first).values
        .any? { |group| group.length >= 2 }
    end
  end
end

