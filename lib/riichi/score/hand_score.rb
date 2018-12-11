module Riichi::Score
  class HandScore
    # @return [Array<Array<Riichi::Tile>>] hand arrangement
    attr :arrangement

    # @return [Hash{String => Integer}] count for each yaku present
    attr :yaku

    def initialize(arrangement:, yaku:)
      @arrangement = arrangement
      @yaku = yaku
    end

    # @return [Integer] total yaku for the hand
    def total_yaku
      @total_yaku ||= yaku.values.sum
    end
  end

end