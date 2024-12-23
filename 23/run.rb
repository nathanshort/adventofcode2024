
neighbors = Hash.new { |h, k| h[k] = [] }

ARGF.each_line do |line|
  a,b = line.chomp.split(/\-/).sort
  neighbors[a] << b
  neighbors[b] << a
end


# https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
def bk( r, p, x, neighbors, cliques )

  cliques[r.length] << r if p.empty? && x.empty?
  p.dup.each do |v|
    bk( r|[v], p & neighbors[v], x & neighbors[v], neighbors, cliques )
    p.delete(v)
    x = x | [v]
  end
end


cliques = Hash.new { |h, k| h[k] = [] }
bk( [], neighbors.keys, [], neighbors, cliques )

tuples_of_3 = []
cliques.keys.each do |kk|
  next if kk < 3
  if kk == 3
    tuples_of_3 = tuples_of_3 + cliques[kk]
    next
  end
  cliques[kk].each{ |c| c.combination(3).each{ |x| tuples_of_3 << x } }
end

p tuples_of_3.uniq.count { |x| x.count{ |xx| xx[0] == 't' } > 0 }
p cliques[cliques.keys.max].first.sort.join(",")

