require 'minitest/autorun'
require 'minitest/benchmark'

require 'riichi'

class SetsBenchmark < Minitest::Benchmark
  def self.bench_range
    range = [1000, 10_000, 100_000, 1_000_000]
    puts "using bench_range: #{range}\n\n"
    range
  end

  def humanize(secs)
    if secs.abs > 1
      format("%9.2fs", secs)
    else
      format("%9.2fms", secs * 1000)
    end
  end

  def bench_sets
    validation = lambda do |range, times|
      [range, times]
    end

    counts, times = assert_performance validation do |n|
      n.times do
        Riichi::Tiles.arrangements(Riichi::Tile.deck.sample(14))
      end
    end

    printf("\nAverage time to compute sets for a hand: %.3f ms",
      (times.sum / counts.sum) * 1000)
  end
end