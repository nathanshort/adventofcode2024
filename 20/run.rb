require_relative '../lib/common.rb'
require_relative '../lib/pqueue'

g = Grid.new(io:ARGF)
start = g.find{ |p,v| v=='S' }.first
eend = g.find{ |p,v| v=='E' }.first
g[start]='.'
g[eend]='.'


def dodij( pq, grid, distances, eend )

  while ! pq.empty?
    c = pq.pop
    path = c[:path]
    point = path.last
    return path if point == eend

    point.hvadjacent.each do |adj|
      next if grid[adj] != '.'
      distance = distances[point] + 1
      if ! distances.key?(adj) || distances[adj] > distance
        distances[adj] = distance
        pq.push({path:path+[adj]})
      end
    end
  end
end


distances = {start=>0}
pq = PQueue.new {|x,y| distances[y] <=> distances[x] }
pq.push({path:[start]})
path = dodij( pq, g, distances, eend )
pathh = Hash[path.map { |v| [v,1] }]

savings = Hash.new { |h,k| h[k]=0 }
depth = 20

path.each do |point|

  xmin = [point.x-depth,0].max
  xmax = [point.x+depth,g.width-1].min
  ymin = [point.y-depth,0].max
  ymax = [point.y+depth,g.height-1].min
  (xmin..xmax).each do |xx|
    (ymin..ymax).each do |yy|
      p = Point.new( xx,yy )
      next if ! pathh.key?(p)
      md = (xx-point.x).abs + (yy-point.y).abs
      next if md > depth

      # this point is reachable from current point, via cheat
      save = distances[p]-(distances[point]+md)
      savings[save]+= 1 if save >= 100
    end
  end
end

p savings.values.sum
