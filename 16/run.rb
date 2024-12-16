require_relative '../lib/common.rb'
require_relative '../lib/pqueue'

# dijkstra to find best path
# then bfs to find all paths - pruning if we get to a ( point,orientation ) that
# was seen in dijkstra at a lower score

  def findpaths( point, grid, seen, allpaths, score, movingin, distances, target, best ) 

    if point == target
      if score == best
        seen.keys.each{ |k| allpaths << k }
      end
    return
  end

  seen[[point.x,point.y]] = true

  point.hvadjacent.each do |pp|
    sscore = score
    if ! seen[[pp.x,pp.y]] && grid[pp] != '#'

      if ! movingin.nil?
        dx = pp.x - point.x
        dy = pp.y - point.y
        thismove = dx == 0 ? :dy : :dx
        sscore += 1
        sscore += 1000 if thismove != movingin
      end

      key = {:p=>pp,:m=>thismove}
      if  distances.key?(key) && distances[key] >= sscore
        findpaths( pp,grid,seen.dup,allpaths,sscore,thismove,distances,target, best ) if sscore <= best
      end
    end
  end
end


def dodij( pq, grid, distances, visited, eend )

  while ! pq.empty?

    c = pq.pop
    point = c[:p]
    moving = c[:m]
    visited[point] = true

    return if point == eend

    point.hvadjacent.each do |adj|

      next if grid[adj] == '#'
      distance = distances[c] + 1
      dx = point.x - adj.x
      dy = point.y - adj.y
      thismove = dx == 0 ? :dy : :dx
      distance += 1000 if thismove != moving

      key = {p:adj,m:thismove}
      if ! distances.key?(key) || distances[key] > distance
        distances[key] = distance
        pq.push(key)
      end
    end
  end
end

grid = Grid.new(:io=>ARGF)
start = grid.find { |k,v| v=='S' }.first
eend = grid.find { |k,v| v=='E' }.first

visited, distances = {},{}
pq = PQueue.new {|x,y| distances[y] <=> distances[x] }

pq.push({p:start,m: :dx})
pq.push({p:start,m: :dy})
visited[{p:start,m: :dx}] = true
visited[{p:start,m: :dy}] = true
distances[{p:start,m: :dx}] = 0
distances[{p:start,m: :dy}] = 1000

dodij( pq, grid, distances, visited, eend )
best = distances.select{ |k,v| k[:p] == eend }.values.min
p best

allpaths = []
score = 0
findpaths( start, grid, seen={}, allpaths, score, :dx, distances, eend, best )
p allpaths.uniq.length+1
