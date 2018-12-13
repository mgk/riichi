module Riichi::Count

  # Hand counter base class. Counter counts Fu and there is
  # a subclass that counts each Yaku type.
  #
  class Counter
    extend Forwardable

    # @return [Hand] the hand
    attr :hand

    %w(closed? ron? tsumo?).each { |m| def_delegator :@hand, m.to_sym }

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

    # @return [Array<Tile>] all the tiles in the hand, including
    # the open melds
    def all_tiles
      (sets + atama).flatten
    end

    # Get all the sets in the hand, including the open melds
    # @return [Array<Riichi::Tile>] the sets
    def sets
      closed_sets + melds
    end

    # Get all the chows in the hand including open melds
    # @return [Array<Riichi::Tile>] the chows
    def chows
      sets.find_all { |set| Riichi::Tile.chow?(set) }
    end

    def closed_chows
      closed_sets.find_all { |set| Riichi::Tile.chow?(set) }
    end

    # Get all the pungs in the hand including open melds
    # @return [Array<Riichi::Tile>] the pungs
    def pungs
      sets.find_all { |set| Riichi::Tile.pung?(set) }
    end

    def closed_pungs
      # TODO: handle ron for san ako counting
      closed_sets.find_all { |set| Riichi::Tile.pung?(set) }
    end

    # Get the points to score for the hand when it is open
    # and the hand yaku is present.
    def open_points
      points[0]
    end

    # Get the points to score for the hand when it is closed
    # and the hand yaku is present.
    def closed_points
      points[1]
    end

    # Get the yaku count for the hand arrangement.
    def yaku_count
      if present?
        closed? ? closed_points : open_points
      else
        0
      end
    end

    def fu_count
      # todo chi_toi
      fu = 20

      if tsumo?
        fu += 2
      elsif closed?
        fu += 10
      end

      # todo kuipinfu ? 2



    end

    def set_fu

    end

    # Get all the counter classes: i.e., all of the
    # leaf subclassess of Counter.
    # @return [Hash{String, Class}]
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
