require 'bundler/setup'
require 'riichi'

# Harness for debugging until I get debugging working in tests

# tiles = Riichi::Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
# puts Riichi::Tiles.chow_start?(tiles)


# ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m S",
#   ["7s 8s 9s", "8s 8s 8s", "1m 1m 3m"]]

class Array
  def to_tile_strings
    self.map do |x|
      case x
      when Riichi::Tile then x.to_s
      when Array then x.to_tile_strings
      else x
      end
    end
  end
end

Riichi::Tiles.initial_chow(Riichi::Tiles.from_s("8m 9m 9m").tiles)

[
  # "1p 2p 3p 4p",
  # "1s 1s 1s 2s 2s 2s",
  # "1s 1s 1s 2s 3s",
  # "1s 1s 1s 2s 3s 5m 6m 7m",
  # "1s 1s 1s 2s 3s 4s N",
  "3p 4p 5p 5p 7p 2s 6s 8s 8s 3m 6m 8m 9m 9m",
#  "8s 1s 4p W 9m 8s W 8p 1m 3s 5m 8m 9m 9m"
].each do |s|
  puts "Tiles: #{Riichi::Tiles.from_s(s)}"
  arrangements = Riichi::Tiles.arrangements(s)
  puts "==>"
  arrangements.each_with_index do|arr, i|
    puts "arrangement <#{i}>"
    arr.each do |set|
      puts "   set: #{set.to_tile_strings.inspect}"
    end
    rest = arr.reduce(Riichi::Tiles.from_s(s).tiles) { |acc, x| Riichi::Tiles.diff(acc, x) }
    puts "   -- rest: #{rest.to_tile_strings.inspect}"
  end
  puts "--\n\n"
end

100000.times do |n|
  hand = Riichi::Tile.deck.sample(14)
  begin
    Riichi::Tiles.arrangements(hand).each do |arrangement|
      arrangement.each do |set|
        if !Riichi::Tiles.set?(set)
          puts "n=[#{n}] bad set #{set} for #{hand.to_tile_strings}"
        end
      end
    end
  rescue => e
    p hand.to_tile_strings
    puts Riichi::Tiles.new(hand)
    raise e
  end
end

# t2 = "5p 7p 8p 9p 1s 1s 3s 5s 1m 2m 3m 3m 4m N"
# tiles = Riichi::Tiles.from_s(t2)
# puts "Computing sets for #{tiles}"
# puts tiles.sets.map { |a| "[#{a.join', '}]"}
