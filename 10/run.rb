require_relative '../lib/common.rb'

grid = Grid.new( :io => ARGF.read.chomp ){ |x,y,c| [x,y,c.to_i] }
zeros = []
grid.each { |p,v| zeros << p if v == 0 }

sum = 0
zeros.each do |z|
  hits = []
  seen = {}
  q = [z]
  while q.length > 0
    p = q.pop
    seen[p] = true
    hits << p if grid[p] == 9
    p.hvadjacent.each { |a| q << a if ! grid[a].nil? && grid[a]==grid[p]+1 && !seen.key?(a) }
  end
  sum += hits.length
end
p sum


sum = 0
zeros.each do |z|
  hits = []
  seen = {}
  q = [[z]]
  while q.length > 0
    path = q.pop
    point = path.last
    seen[path] = true
    hits << path if grid[point] == 9
    point.hvadjacent.each do |a|
      if ! grid[a].nil? && grid[a] == grid[point]+1
        new_path = path | [a]
        q << new_path if ! seen.key?(new_path)
      end
    end
  end
  sum += hits.length
end
p sum
