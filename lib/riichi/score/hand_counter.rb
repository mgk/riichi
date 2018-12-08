module Riichi::Score

  # Hand counter base
  class HandCounter
    attr :hand
    attr :arrangement

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
    # @return [Array<Integer>] array of length 2: the closed points
    # and the open points
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
      @arrangement = arrangement
    end

    # Get the melds in the hand.
    # @return [Array<Array<Tile>>] melds in the hand
    def melds
      hand.melds
    end

    # Get all the tiles in the hand, including the open melds
    # @return [Array<Tile>]
    def tiles
      (melds + arrangement).flatten
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

    # Count the hand arrangement.
    def count
      if present?
        hand.closed? ? closed_points : open_points
      else
        0
      end
    end
  end
end
