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

    def extra_fu
      @extra_fu ||= Count::Counter.new(hand, arrangement).fu
    end

    def fu
      @fu ||= begin
        if chiitoi?
          25
        else
          points = 20

          if hand.tsumo?
            points += 2 unless pinfu?
          else
            points += 10 if hand.closed?
          end
          points += 2 if hand.open? && extra_fu == 0

          points += extra_fu
          (points + 4).round(-1)
        end
      end
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

    def self.base_points(han, fu)
      fu * 2.pow(han + 2)
    end

    # Get the payments for the hand arrangement
    def payments(dealer:, bonus:)
      points = Score.base_points(bonus + total_yaku, fu)
      payments = if hand.tsumo?
        if dealer
          { others: 2 * points }
        else
          { dealer: 2 * points, others: points }
        end
      else
        if dealer
          { discarder: 6 * points }
        else
          { discarder: 4 * points }
        end
      end

      # round each payment up to nearest hundred
      payments.transform_values do |payment|
        (payment + 49).round(-2)
      end
    end

    # Get the best Score for the hand by scoring each
    # complete arrangement.
    def self.best_score(hand)
      all_scores(hand).max { |a, b| a.total_yaku <=> b.total_yaku }
    end

    Count::Counter.counters.keys.each do |hand_type|
      define_method hand_type do
        yaku[hand_type]
      end
      define_method :"#{hand_type}?" do
        yaku.has_key?(hand_type)
      end
    end
  end
end
