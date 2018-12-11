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

      @melds = [melds].flatten(1).map do |meld|
        meld.is_a?(String) ? Tile.to_tiles(meld) : meld
      end

      @bakaze = bakaze
      @jikaze = jikaze
      @discards = discards
      @draws = draws

      if !valid?
        raise ArgumentError, self
      end
    end

    def valid?
      (@tiles + @melds.flatten).length.between?(13, 14) &&
        @tiles.group_by { |x| x }.values.map(&:length).all? { |count| count <= 4 }
    end

    # Draw a tile from the wall
    #
    # @param [Tile, String] tile drawn
    def draw!(tile)
      tile = Tile.to_tile(tile)

      unless @tiles.length % 3 == 1
        raise ArgumentError, "wrong number of tiles: #{self}"
      end

      tile = Tile.to_tile(tile)
      @draws << tile
      @tiles << tile
      @tiles.sort!

      self
    end

    # Discard a tile.
    #
    # @param [Tile, String] tile to discard
    def discard!(tile)
      tile = Tile.to_tile(tile)

      unless tiles.length % 3 == 2
        raise ArgumentError, "wrong number of tiles: #{self}"
      end
      unless @tiles.includes?(tile)
        raise ArgumentError, "tile #{tile} not in hand: #{self}"
      end

      @tiles = Tile.diff(@tiles, [tile])
      @discards << tile

      self
    end

    # Create an open pung meld of the given tile.
    #
    # @param [Tile, String] tile called tile discarded by opponent
    def pung!(tile)
      tile = Tile.to_tile(tile)

      unless @tiles.includes_all?([tile, tile])
        raise ArgumentError, "pair of #{tile} not in hand: #{self}"
      end

      @tiles = Tile.diff(@tiles, [tile, tile])
      @melds += [tile, tile, tile]

      self
    end

    # Create an open chow meld.
    #
    # @param [Tile, String] tile called tile discarded by opponent
    # @param [Array<Tile>, String, Array<Integer>] tatsu 2 tiles in hand that
    # complete the chow when combined with the called tile.
    def chi!(tile, tatsu)
      tile = Tile.to_tile(tile)
      if tatsu.is_a? String
        tatsu = Tile.to_tiles(tatsu)
      elsif tatsu.first.is_a? Integer
        tatsu = tatsu.map { |rank| Tile.get(suit: tile.suit, rank: rank)}
      end
      meld = (tatsu + [tile]).sort

      unless Tile.chow?(meld)
        raise ArgumentError, "#{meld.inspect} not a chow"
      end
      unless @tiles.includes_all?(tatsu)
        raise ArgumentError, "#{tatsu} not in hand: #{self}"
      end

      @tiles = Tile.diff(@tiles, tatsu)
      @melds += meld

      self
    end

    def tsumo!
    end

    def ron!(tile)
    end

    def last_draw
      @draws.last
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
        return [[tiles]]
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
      # TODO: 9 gates, 13 orphans (hmm...maybe 9 gates ok)
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
      "tiles: #{Tile.to_short_s(tiles)}, open: #{melds.inspect}, discards: #{discards}"
    end

    # Find all the hand counter classes: i.e., all of the
    # leaf descendents of the HandCounter base class.
    # @see Score::HandCounter
    def self.hand_counters
      @hand_counters ||= begin
        classes = Score.constants
          .map { |c| Score.module_eval(c.to_s) }
          .map(&:ancestors)
          .map { |cls, *parents| [cls, Set.new(parents)] }
          .to_h
        all_parents = classes.values.sum(Set.new)
        classes.find_all do |cls, parents|
          parents.include?(Score::HandCounter) &&
            !all_parents.include?(cls)
        end
        .map(&:first)
        .map { |cls| [cls.name.split('::').last, cls]}
        .to_h
      end
    end

    def yaku_count(arrangement)
      Hand.hand_counters.transform_values do |counter|
        counter.new(self, arrangement).yaku_count
      end
    end

    # Count all the yaku for each complete arrangement.
    #
    # @return [Array<Score::HandScore>]
    def all_yaku
      complete_arrangements.map do |arrangement|
        yaku = yaku_count(arrangement).keep_if { |_, count| count > 0 }
        Score::HandScore.new(arrangement: arrangement, yaku: yaku)
      end
    end

    def best_score
      all_yaku.max { |a, b| a.total_yaku <=> b.total_yaku }
    end
  end
end
