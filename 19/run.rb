
a,b = ARGF.read.split(/\n\n/)
towels = a.split(", ").sort{ |a,b| a.length<=>b.length }
designs = b.split(/\n/)

def match( design, towels, cache )

  return cache[design] if cache.key?(design)
  count = design == "" ? 1 : 0 

  towels.each do |towel|
    if design.start_with?( towel )
      count += match( design[towel.length..], towels, cache )
    end
  end
  cache[design] = count
  count
end

cache = {}
p1wins,p2wins = 0,0
designs.each do |d|
  wins = match( d, towels, cache )
  p1wins += 1 if wins != 0
  p2wins += wins
end

p p1wins,p2wins







