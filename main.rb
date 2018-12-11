require 'bundler/setup'
require 'riichi'

# Harness for debugging until I get debugging working in tests

def t(s); Riichi::Tile.to_tiles(s); end

# p Riichi::Tile.initial_chow(t('1s 2s 3s 4s'))
# Kernel.exit
# p Riichi::Tile.connectors(t('1s 2s 3s 4s'))

hand = Riichi::Hand.new("s222333444 m123 m88")
puts hand
arrangement = hand.complete_arrangements.first
puts Riichi::Count::Tanyao.new(hand, arrangement).yaku_count
Kernel.exit

[
  "Ww Ww Nw Wd 1p 2p 4p",
  "2m 2m 3m 3m 4m 4m 5m",
  "8p 2m 2m 3m 3m 4m 4m 5m 6m 8m Wd Wd Wd",
  "7p 5p 6p 6p 8p 5p 5p Wd 3p 4p Ew 9p 2p 6m",
  "1p 2p 3p 4p",
  "1s 1s 1s 2s 2s 2s",
  "1s 1s 1s 2s 3s",
  "1s 1s 1s 2s 3s 5m 6m 7m",
  "1s 1s 1s 2s 3s 4s Nw",
  "3p 4p 5p 5p 7p 2s 6s 8s 8s 3m 6m 8m 9m 9m",
  "8s 1s 4p Ww 9m 8s Ww 8p 1m 3s 5m 8m 9m 9m"
].each do |s|
  tiles = t(s)
  p tiles
  Riichi::Tile.arrangements(tiles).each_with_index do|arr, i|
    puts "arrangement <#{i}>"
    arr.each do |set|
      puts "   set: #{set.inspect}"
    end
    rest = Riichi::Tile.diff(tiles, arr)
    puts "   -- rest: #{rest.inspect}"
  end
  puts "--\n\n"
end

1_000.times do |n|
  hand = Riichi::Tile.deck.sample(14)
  begin
    Riichi::Tile.arrangements(hand).each do |arrangement|
      if Riichi::Tile.pairs(hand).first.length == 7
        puts "chi toi and yakuman! #{hand.sort.inspect}"
      end
      arrangement.each do |set|
        if !Riichi::Tile.set?(set)
          puts "n=[#{n}] bad set #{set} for #{hand.sort.inspect}"
        end
      end
    end
  rescue => e
    puts hand
    raise e
  end
end
