require_relative '../lib/common.rb'

grid = Grid.new( :io => ARGF.read.chomp ){ |x,y,c| [x,y,c.to_i] }
zeros = []
grid.each { |p,v| zeros << p if v == 0 }

p1sum,p2sum = 0,0
zeros.each do |z|
  hits = []
  q = [[z]]
  while q.length > 0
    path = q.pop
    point = path.last
    hits << path if grid[point] == 9
    point.hvadjacent.each { |a| q << (path|[a]) if !grid[a].nil? && grid[a] == grid[point]+1 }
  end
  p1sum += hits.map(&:last).uniq.length
  p2sum += hits.length
end
p p1sum,p2sum
