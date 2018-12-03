module Riichi

  # A player's hand state.
  class Hand

    # @return [Array<Tiles>] unmelded tiles in the hand
    attr_reader :tiles

    # @return [Array<Array<Tiles>>] open melds in the hand
    attr_reader :melds

    # @return [Array<Tiles>] tiles discarded from the hand
    attr_reader :discards

    # @return [:east, :south, :west, :north] the prevailing wind
    attr_reader :bakaze

    # @return [:east, :south, :west, :north] the seat wind
    attr_reader :jikaze

    # @return [Array<Draw>] tiles drawn
    attr_reader :draws

    def initialize(tiles, bakaze: :east, jikaze: :east, melds: [], discards: [], draws: [])
      @tiles = case tiles
      when String then Tile.to_tiles(tiles)
      when Array then tiles
      end.sort

      if !valid?
        raise ArgumentError, @tiles
      end
      @bakaze = bakaze
      @jikaze = jikaze
      @melds = melds
      @discards = discards
      @draws = draws
    end

    def draw(tile)
      @draws << tile
      @tiles << tile
      @tiles.sort!
    end

    def discard(tile)
      @discards << tile
    end

    def last_draw
      @draws.last
    end

    def valid?
      @tiles.group_by { |x| x }.values.map(&:length).all? { |count| count <= 4 }
    end

    def open?
      !closed?
    end

    def closed?
      @melds.empty?
    end

    def value_tiles
      [Tile.get(dragon: :red), Tile.get(dragon: :white), Tile.get(dragon: :green),
        Tile.get(wind: bakaze), Tile.get(wind: jikaze)]
    end

    # Determine if the hand is complete
    #
    # @return [true, false] if the hand is complete
    def complete?
      !complete_arrangements.empty?
    end

    # Determine all the arrangements which make the hand complete.
    #
    # @return [Array<Array<Array<Tile>>>] complete arrangements, each
    # arrangement includes the final pair if any. If the hand is not complete
    # an empty array is returned.
    def complete_arrangements
      if tiles.length % 3 != 2
        return []
      end

      if Tile.pair?(tiles)
        return [tiles]
      end

      Tile.arrangements(tiles)
      .map do |arrangement|
        unmatched = Tile.diff(tiles, arrangement)
        [arrangement, unmatched]
      end
      .find_all do |arrangement, unmatched|
        unmatched.empty? || Tile.pair?(unmatched)
      end
      .map do |arrangement, pair|
        arrangement + [pair]
      end
    end

    # Determine all the tiles that would make a given arrangement into
    # a complete hand.
    #
    # @return [Array<Tile>] tiles that would complete the arrangement, empty
    # Array if there are no such tiles (i.e., not tenpai).
    def waiting_tiles(arrangement)
      # TODO: check that waiting tiles are not used up in rest of hand
      # TODO: chitoi, 9 gates, 13 orphans (hmm...maybe 9 gates ok)
      unmatched = Tile.diff(tiles, arrangement)

      if unmatched.length == 1
        unmatched
      elsif unmatched.length == 4
        pairs, rest = Tile.pairs(unmatched)
        if pairs.length == 2
          pairs.map(&:first)
        elsif pairs.length == 1
          Tile.tiles_that_complete_chow(rest)
        end
      end
    end

    # Determine all the tenpai arrangments and the tiles that complete each.
    #
    # TODO: terminology?
    #
    # @return [Array<Array<Array<Array<Tile>>>, Array<Tile>] an array
    # of [arrangement, waiting_tiles] pairs, one for each arrangement that
    # makes the hand tenpai.
    def waits
      Tile.arrangements(tiles).map do |arrangement|
        [arrangement, waiting_tiles(arrangement)]
      end.find_all do |arrangement, winning_tiles|
        !winning_tiles.empty?
      end
    end

    def to_s
      # This might be nicer, need to reconcile with Tile.to_s
      # suited = @tiles.find_all(&:suited?).group_by(&:suit).map do |suit, tiles|
      #   "#{suit[0]}#{tiles.map(&:rank).join}"
      # end.join(" ")
      "tiles: #{tiles}, open: #{melds}, discards: #{discards}"
    end

    def yaku
      if !complete?
        return nil
      end
      complete_arrangements.map do |arrangement|
        [
          :tanyao,
          :yakuhai,
        ]
        .map do |hand_type|
          [arrangement, [hand_type, self.method(hand_type).call(arrangement)]]
        end
        .find_all do |arr, y|
          y[1] > 0
        end
      end
    end

    def tanyao(arrangement)
      (melds + arrangement).flatten.all?(&:simple?) ? 1 : 0
    end

    def yakuhai(arrangement)
      (melds + arrangement).find_all { |set| Tile.pung? set }.sum do |pung|
        value_tiles.count do |value_tile|
          pung[0] == value_tile
        end
      end
    end

    def pinfu(arrangement)
      *sets, atama = arrangement

      all_chows = sets.all? { |set| Tile.chow? set }

      two_sided_wait = sets.any? do |set|
        (last_draw == set.first && last_draw.rank != 7) ||
          (last_draw == set.last && last_draw.rank != 3)
      end

      valueless_atama = !value_tiles.include?(atama[0])

      closed? && all_chows && two_sided_wait && valueless_atama ? 1 : 0
    end

    def honitsu(arrangement)
      suits = (arrangement + melds)
      .group_by { |set| set.first.suit }

      if suits.length == 2 && suits.include?(nil)
        closed? ? 3 : 2
      else
        0
      end
    end

    def toitoi(arrangement)
      *sets, _atama = arrangement
      (sets + melds).all? { |set| Tile.pung?(set) } ? 2 : 0
    end

    def mixed_triple_chow(arrangement)
      *sets, _atama = arrangement
      chows = (sets + melds).find_all { |set| Tile.chow?(set) }
      groups = chows.map(&:first).group_by(&:rank).values
      if groups.any? { |g| Set.new(g.map(&:suit)).length == 3 }
        return closed? ? 2 : 1
      end
      return 0
    end

    def chii_toitsu(arrangement)
      *pairs, _atama = arrangement
      pairs.length == 7 ? 2 : 0
    end

  end
end
