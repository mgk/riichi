module Riichi

  # A player's hand state.
  class Hand

    # @return [Array<Tiles>] unmelded tiles in the hand
    attr :tiles

    # @return [Array<Array<Tiles>>] open melds in the hand
    attr :melds

    # @return [Array<Array<Tiles>>] closed kongs in the hand
    attr :kongs

    # @return [Array<Tiles>] tiles discarded from the hand
    attr :discards

    # @return [:east, :south, :west, :north] the prevailing wind
    attr :bakaze

    # @return [:east, :south, :west, :north] the seat wind
    attr :jikaze

    # @return [Array<Draw>] tiles drawn
    attr :draws

    def initialize(tiles,
                   bakaze: :east,
                   jikaze: :east,
                   melds: [],
                   kongs: [],
                   discards: [],
                   draws: [],
                   tsumo: false,
                   ron: false)
      @tiles = case tiles
      when String then Tile.to_tiles(tiles)
      when Array then tiles
      end.sort

      @melds = [melds].flatten(1).map do |meld|
        meld.is_a?(String) ? Tile.to_tiles(meld) : meld
      end

      @kongs = [kongs].flatten(1).map do |kong|
        kong.is_a?(String) ? Tile.to_tiles(kong) : meld
      end

      @bakaze = bakaze
      @jikaze = jikaze
      @discards = discards
      @draws = draws
      @tsumo = tsumo
      @ron = ron

      if !valid?
        raise ArgumentError, self
      end
    end

    def kongs
      @kongs + @melds.find_all { |set| Tile.kong?(set) }
    end

    def valid?
      hand_length = (@tiles + @melds.flatten + @kongs.flatten).length
      length_valid = (hand_length - kongs.length).between?(13, 14)
      tiles_valid = (@tiles + melds.flatten).group_by { |t| t}
        .values.map(&:length).all? { |count| count <= 4 }
      win_state_valid = !@tsumo || !@ron

      length_valid && tiles_valid && win_state_valid
    end

    # Draw a tile from the wall
    #
    # @param [Tile, String] tile drawn
    def draw!(tile)
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
    def pon!(tile)
      tile = Tile.to_tile(tile)

      unless @tiles.includes_all?([tile, tile])
        raise ArgumentError, "pair of #{tile} not in hand: #{self}"
      end

      @tiles = Tile.diff(@tiles, [tile, tile])
      @melds += [tile, tile, tile]

      self
    end

    def kan!(tile, replacement_tile)
      triple = [tile] * 3
      quad = [tile] * 4

      if @tiles.includes_all?(quad)
        @kongs += quad
        @tiles = Tile.diff(@tiles, quad)
      elsif @tiles.includes_all?(triple)
        @melds += quad
        @tiles = Tile.diff(@tiles, triple)
      else
        raise ArgumentError, self
      end
    end

    # Create an open chow meld.
    #
    # @param [Tile, String] tile called tile discarded by opponent
    # @param [Array<Tile>, String, Array<Integer>] tatsu 2 tiles in hand that
    # complete the chow when combined with the called tile.
    def chii!(tile, tatsu)
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

    # Declare tsumo win
    #
    # @param [Tile, String] tile drawn. If no tile is supplied
    # the hand must already have been completed with a draw!
    #
    def tsumo!(tile=nil)
      @tsumo = true
      @ron = false

      tile ? draw!(tile) : self
    end

    def tsumo?
      @tsumo
    end

    # Declare ron win with the specificed discarded tile.
    #
    # @param [Tile, String] tile drawn
    def ron!(tile)
      @ron = true
      @tsumo = false

      draw!(tile)
    end

    def ron?
      @ron
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

    # Determine if a set is considered closed
    # for purposes of counting fu and hands like san anko.
    #
    # @param [Array<Tile>] set pung or kong in hand arrangement
    def strictly_closed?(set)
      tsumo? || last_draw != set.first
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
      "tiles: #{Tile.to_short_s(tiles)}, open: #{melds.inspect}, kongs: #{kongs.inspect}, discards: #{discards}"
    end

  end
end
