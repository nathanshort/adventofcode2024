require_relative '../lib/common.rb'
require_relative '../lib/pqueue'

def shortest( pq, grid, distances, eend )

  while ! pq.empty?

    point = pq.pop

    # return [min distance, path as hash of points]
    if point == eend
      return [nil,nil] if distances[eend].nil?

      path = [eend]
      p = eend
      while p != Point.new(0,0)
        p = p.hvadjacent.select { |a| distances.key?(a) }.sort{ |a,b| distances[a]<=>distances[b] }.first
        path.unshift(p)
      end

      pathh = {}
      path.each{ |p| pathh[p] = 1 }
      return [distances[eend],pathh]
    end

    point.hvadjacent.each do |adj|
      next if !grid.covers?(adj) || grid[adj]=='#'
      distance = distances[point] + 1
      if ! distances.key?(adj) || distances[adj] > distance
        distances[adj] = distance
        pq.push(adj)
      end
    end
  end
end

data = []
ARGF.each_line{ |line| data << line.scan(/\d+/).map(&:to_i)}

grid = Grid.new
1024.times { |p| grid[Point.new(data[p].first,data[p].last)] = '#'}
start = Point.new(0,0)
eend = Point.new(grid.width-1,grid.height-1)

distances = {}
pq = PQueue.new {|a,b| distances[b] <=> distances[a] }
pq.push(start)
distances[start] = 0
d,pathh = shortest( pq, grid, distances, eend )
p d

grid.points.keys.count.upto(data.length-1) do |p|

  newp = Point.new(data[p].first,data[p].last)
  grid[newp] = '#'

  # if this point is not on the shortest path - no need to re-find the
  # shortest path
  next if ! pathh.key?(newp)

  distances = {}
  pq = PQueue.new {|a,b| distances[b] <=> distances[a] }
  pq.push(start)
  distances[start] = 0

  d,pathh = shortest( pq, grid, distances, eend )
  if d.nil?
    p data[p]
    exit
  end
end


