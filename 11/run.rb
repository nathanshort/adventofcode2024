
def doit( n, iters, cache )

  return 1 if iters == 0
  cache_key = "#{n},#{iters}"
  return cache[cache_key] if cache.key?(cache_key)

  result = nil
  if n == 0
    result = doit( 1, iters-1, cache )
  elsif n.to_s.length % 2 == 0
    s = n.to_s
    result = doit( s[0,s.length/2].to_i, iters-1, cache ) + doit( s[s.length/2..].to_i, iters-1, cache )
  else
    result = doit( n * 2024, iters-1, cache)
  end

  cache[cache_key] = result
  result
end

n = ARGF.read.chomp.split(/\s+/).map(&:to_i)
p n.sum { |n| doit( n, 25, {} ) }
p n.sum { |n| doit( n, 75, {} ) }
