module Riichi::Score

  # Hand counter base
  class HandCounter

    # @return [Array<Array<Tiles>>] open melds in the hand
    attr :hand

    # @return [Array<Array<Tiles>>] closed sets in the hand arrangement
    attr :sets

    # @return [Array<Array<Tiles>>] atama (head) in the hand arrangement
    attr :atama

    # Determine if the hand yaku is present. Subsclasses
    # must implement this.
    #
    # @return [true, false] true if the hand yaku is present, else false
    def present?
      raise NotImplementedError
    end

    # Get the yaku points for this hand if the yaku is present.
    # Subclasses must implement this.
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
    # @return [HandCounter] counter
    def initialize(hand, arrangement)
      @hand = hand
      *@sets, @atama = arrangement
    end

    # @return [Array<Array<Tiles>>] open melds in the hand
    def melds
      hand.melds
    end

    # @return [Array<Tile>] all the tiles in the hand, including
    # the open melds
    def all_tiles
      (melds + sets + atama).flatten
    end

    # @return [Array<Tile>] all the sets in the hand, including
    # the open melds
    def all_sets
      sets + melds
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

    def closed?
      hand.closed?
    end

    # Count the hand arrangement.
    def count
      if present?
        closed? ? closed_points : open_points
      else
        0
      end
    end
  end
end
