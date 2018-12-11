module Riichi
  class Score
    # @return [Hand] hand
    attr :hand

    # @return [Array<Array<Riichi::Tile>>] hand arrangement
    attr :arrangement

    def initialize(hand, arrangement)
      @hand = hand
      @arrangement = arrangement
    end

    private_class_method :new

    # @return [Hash{String => Integer}] count of each yaku present
    def yaku
      @yaku ||= Count::Counter.counters.transform_values do |counter|
        counter.new(hand, arrangement).yaku_count
      end
      .keep_if { |_, count| count > 0 }
    end

    # @return [Integer] total yaku count for the hand
    def total_yaku
      @total_yaku ||= yaku.values.sum
    end

    # @return [Array<Score>]
    def self.all_scores(hand)
      hand.complete_arrangements.map do |arrangement|
        new(hand, arrangement)
      end
    end

    # Get the best Score for the hand by scoring each
    # complete arrangement.
    def self.best_score(hand)
      all_scores(hand).max { |a, b| a.total_yaku <=> b.total_yaku }
    end

  end
end
