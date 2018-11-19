require 'bundler/setup'
require 'riichi'

# Harness for debugging until I get debugging working in tests

# tiles = Riichi::Tiles.from_s("7s 8s 8s 8s 9s 1m").tiles
# puts Riichi::Tiles.chow_start?(tiles)


# ["1p 3p 9p 3s 7s 8s 8s 8s 9s 1m 2m 3m 6m S",
#   ["7s 8s 9s", "8s 8s 8s", "1m 1m 3m"]]

Riichi::Tiles.initial_chow(Riichi::Tiles.from_s("8m 9m 9m").tiles)

[
 "7p 5p 6p 6p 8p 5p 5p F 3p 4p E 9p 2p 6m",
  "1p 2p 3p 4p",
  "1s 1s 1s 2s 2s 2s",
  "1s 1s 1s 2s 3s",
  "1s 1s 1s 2s 3s 5m 6m 7m",
  "1s 1s 1s 2s 3s 4s N",
  "3p 4p 5p 5p 7p 2s 6s 8s 8s 3m 6m 8m 9m 9m",
  "8s 1s 4p W 9m 8s W 8p 1m 3s 5m 8m 9m 9m"
].each do |s|
  tiles = Riichi::Tiles.from_s(s)
  puts "Tiles: #{tiles}"
  arrangements = Riichi::Tiles.arrangements(s)
  arrangements.each_with_index do|arr, i|
    puts "arrangement <#{i}>"
    arr.each do |set|
      puts "   set: #{set.inspect}"
    end
    rest = Riichi::Tiles.diff(tiles.tiles, arr)
    puts "   -- rest: #{rest.inspect}"
  end
  puts "--\n\n"
end

0.times do |n|
  hand = Riichi::Tile.deck.sample(14)
  begin
    Riichi::Tiles.arrangements(hand).each do |arrangement|
      arrangement.each do |set|
        if !Riichi::Tiles.set?(set)
          puts "n=[#{n}] bad set #{set} for #{hand}"
        end
      end
    end
  rescue => e
    p hand
    puts Riichi::Tiles.new(hand)
    raise e
  end
end

# t2 = "5p 7p 8p 9p 1s 1s 3s 5s 1m 2m 3m 3m 4m N"
# tiles = Riichi::Tiles.from_s(t2)
# puts "Computing sets for #{tiles}"
# puts tiles.sets.map { |a| "[#{a.join', '}]"}
