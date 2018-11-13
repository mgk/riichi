require 'set'

class Tile

  include Comparable

  attr_reader :type, :suit, :rank, :wind, :dragon

  def initialize(type: nil, suit: nil, rank: nil, wind: nil, dragon: nil)
    @type = type
    @suit = suit
    @rank = rank
    @wind = wind
    @dragon = dragon

    freeze
  end

  def to_s
    if suit
      "#{rank}#{suit.to_s[0]}"
    elsif wind
      "#{wind.to_s[0].upcase}"
    else
      case dragon
      when :red then 'C'
      when :green then 'F'
      when :white then 'B'
      end
    end
  end

  def self.from_s(str)
    if str.length == 2
      suit = case str[1]
      when 'p' then :pinzu
      when 'm' then :manzu
      when 's' then :sozu
      else
        raise ArgumentError, str
      end
      Tile.new(suit: suit, rank: Integer(str[0]))
    else
      case str
      when 'E' then Tile.new(wind: :east)     # 東
      when 'S' then Tile.new(wind: :south)    # 南
      when 'W' then Tile.new(wind: :west)     # 西
      when 'N' then Tile.new(wind: :north)    # 北
      when 'C' then Tile.new(dragon: :red)    # 中 - (pinyin chung)
      when 'F' then Tile.new(dragon: :green)  # 發 - (pinyin fa)
      when 'B' then Tile.new(dragon: :white)  # 白 - (pingyin bai)
      else
        raise ArgumentError, str
      end
    end
  end

  def honour?
    wind || dragon
  end

  def terminal?
    [1, 9].include? rank
  end

  def simple?
    suit && !terminal?
  end

  def <=>(other)
    self.type <=> other.type
  end

  def self.pung?(tiles)
    tiles[0] == tiles[1] && tiles[1] == tiles[2]
  end

  def self.chow?(tiles)
    tiles.all? do |tile|
      !tile.honour? && tile.suit == tiles[0].suit
    end &&
      tiles[1].rank == tiles[0].rank + 1 &&
      tiles[2].rank == tiles[1].rank + 1
  end

  def self.set?(tiles)
    tiles.size == 3 && (self.pung?(tiles) || self.chow?(tiles))
  end

  def self.create_deck
    tiles = [:pinzu, :sozu, :manzu].map do |suit|
      (1..9).map do |rank|
        Tile.new(suit: suit, rank: rank)
      end
    end.flatten + [
      Tile.new(wind: :east),
      Tile.new(wind: :south),
      Tile.new(wind: :west),
      Tile.new(wind: :north),
      Tile.new(dragon: :white),
      Tile.new(dragon: :green),
      Tile.new(dragon: :red),
    ]

    tiles.each_with_index.map do |t, i|
      Tile.new(type: i, suit: t.suit, rank: t.rank, wind: t.wind, dragon: t.dragon)
    end * 4
  end

end

class PlayerHand
  attr_reader :tiles

  def initialize(tiles)
    @tiles = tiles.sort
  end

  def sets
    def aux(unmatched, sets, remaining)
      if remaining.empty?
        return [unmatched, sets]
      end

      candidate = remaining.take(3)
      rest = remaining.drop(3)

      if Tile.set?(candidate)
        aux(unmatched, sets + [candidate], rest)
      else
        aux(unmatched + [remaining[0]], sets, remaining.drop(1))
      end
    end
    aux([], [], tiles)
  end

  def to_s
    tiles.join(' ')
  end
end

5.times do
  puts PlayerHand.new(Tile.create_deck().shuffle[0,14]).tiles.join(' ')
end

# deck = Tile.create_deck

# counts = Hash.new(0)
# 10000.times do
#   tiles = deck.shuffle[0, 14]

#   hand = PlayerHand.new tiles
#   unmatched, sets = hand.sets

#   counts[sets.length] += 1
#   if sets.length == 4
#     if unmatched[0] == unmatched[1]
#       counts['yakuman'] += 1
#       counts[4] -= 1
#     end
#   end
# end

# puts counts
# puts counts.values.sum
