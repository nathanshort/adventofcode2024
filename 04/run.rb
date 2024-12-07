require_relative '../lib/common.rb'

def doit( what, p, grid, dir )
    return 0 if ! grid[p] || grid[p] != what.first
    return 1 if what.length == 1
    return doit( what[1..], Point.new( p.x+dir[0], p.y+dir[1]), grid, dir )
end

g = Grid.new( :io => ARGF.read.chomp )
count = 0
g.each do |p,v|
  next if v != 'X'
  [[-1,0],[-1,-1],[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1]].each do |d|
    count += doit( %w/M A S/, Point.new( p.x+d[0], p.y+d[1]), g, d )
  end
end
p count


count = 0
g.each do |p,v|
  next if v != 'A'
  tl = Point.new( p.x-1 , p.y-1 )
  tr = Point.new( p.x+1 , p.y-1 )
  bl = Point.new( p.x-1 , p.y+1 )
  br = Point.new( p.x+1 , p.y+1 )
  if ( g[tl] == 'M' && g[br] == 'S' ||
       g[tl] == 'S' && g[br] == 'M' ) &&
     ( g[tr] == 'M' && g[bl] == 'S' ||
     g[tr] == 'S' && g[bl] == 'M' )
    count += 1
  end
end

p count 
