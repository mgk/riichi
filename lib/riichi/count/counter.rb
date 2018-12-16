module Riichi::Count

  # Hand counter base class. Counter counts Fu and there is
  # a subclass that counts each Yaku type.
  #
  class Counter
    extend Forwardable

    # @return [Hand] the hand
    attr :hand

    %w(closed? strictly_closed? last_draw).each do |method_name|
      def_delegator :@hand, method_name.to_sym
    end

    # @return [Array<Array<Tiles>>] closed sets in the hand arrangement
    attr :closed_sets

    # @return [Array<Array<Tiles>>] atama (head) in the hand arrangement
    attr :atama

    # Determine if the hand yaku is present. Subclasses
    # must implement present? and points or implement count.
    #
    # @return [true, false] true if the hand yaku is present, else false
    def present?
      raise NotImplementedError
    end

    # Get the yaku points for this hand if the yaku is present.
    # Subclasses must implement present? and points or implement count.
    #
    # @return [Array<Integer>] array of length 2: the open points
    # and the closed points
    def points
      raise NotImplementedError
    end

    # Instantiate a hand counter for a given hand arrangement
    #
    # @param [Hand] hand to count
    # @param [Array<Tile>] arrangement arrangement of tiles in hand
    # to count.
    #
    # @return [Counter] counter
    def initialize(hand, arrangement)
      @hand = hand
      *@closed_sets, @atama = arrangement
    end

    # @return [Array<Array<Tile>>] open melds in the hand
    def melds
      hand.melds
    end

    # @return [Array<Array<Tile>>] closed kongs in the hand
    def kongs
      hand.kongs
    end

    # @return [Array<Tile>] all the tiles in the hand, including
    # the open melds
    def all_tiles
      (sets + atama).flatten
    end

    # Get all the sets in the hand, including the open melds
    # @return [Array<Riichi::Tile>] the sets
    def sets
      closed_sets + melds + kongs
    end

    # Get all the chows in the hand including open melds
    # @return [Array<Array<Riichi::Tile>>] the chows
    def chows
      sets.find_all { |set| Riichi::Tile.chow?(set) }
    end

    def closed_chows
      closed_sets.find_all { |set| Riichi::Tile.chow?(set) }
    end

    # Get all the pungs in the hand including open melds.
    # @return [Array<Array<Riichi::Tile>>] the pungs
    def pungs
      sets.find_all { |set| Riichi::Tile.pung?(set) }
    end

    # Get all the strictly closed sets. A set is strictly closed if
    # it is a not formed by the called ron tile.
    # @return [Array<Array<Riichi::Tile>>] the strictly closed sets.
    def strictly_closed_sets
      closed_sets.find_all { |set| strictly_closed?(set) }
    end

    # Get the points to score for the hand when it is open
    # and the hand yaku is present.
    # @return [Integer] the points
    def open_points
      points[0]
    end

    # Get the points to score for the hand when it is closed
    # and the hand yaku is present.
    # @return [Integer] the points
    def closed_points
      points[1]
    end

    # Get the yaku count for the hand arrangement.
    # @return [Integer] the yaku
    def yaku_count
      if present?
        closed? ? closed_points : open_points
      else
        0
      end
    end

    # Get the fu count for the hand arrangement. This
    # is the fu count for sets, waits, and the pair. It does
    # not include the fu for winning (futei) and is not rounded.
    def fu
      fu_for_sets + fu_for_wait + fu_for_pair
    end

    def fu_for_sets
      sets.sum { |set| set_fu(set) }
    end

    def fu_for_pair
      hand.value_tiles.count do |tile|
        tile == atama.first
      end * 2
    end

    def set_fu(set)
      fu = case
      when Riichi::Tile.kong?(set) then 8
      when Riichi::Tile.pung?(set) then 2
      else 0
      end

      fu *= 2 if strictly_closed?(set)
      fu *= 2 if set.first.terminal? || set.first.honour?

      fu
    end

    def fu_for_wait
      case
      when penchan? then 2
      when kanchan? then 2
      when tanki? then 2
      else 0
      end
    end

    # Edge wait
    def penchan?
      chows.any? do |chow|
        (last_draw == chow.last && chow.first.rank == 1) ||
          (last_draw == chow.first && chow.last.rank == 9)
      end
    end

    # Center wait
    def kanchan?
      chows.any? { |chow| last_draw == chow[1] }
    end

    # Pair wait
    def tanki?
      last_draw == atama.first
    end

    # Double pairs (shabo)
    def shanpon?
      pungs.any? { |pung| last_draw == pung.first }
    end

    # Get all the counter classes: i.e., all of the
    # leaf subclassess of Counter.
    # @return [Hash{String => Class}]
    def self.counters
      @hand_counters ||= begin
        classes = Riichi::Count.constants
          .map { |c| module_eval(c.to_s) }
          .map(&:ancestors)
          .map { |cls, *parents| [cls, Set.new(parents)] }
          .to_h

        all_parents = classes.values.sum(Set.new)

        classes.find_all do |cls, parents|
          parents.include?(Counter) && !all_parents.include?(cls)
        end
        .map(&:first)
        .map { |cls| [cls.name.split('::').last.downcase.to_sym, cls] }
        .to_h
      end
    end
  end
end
