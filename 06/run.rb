
require_relative '../lib/common.rb'

# returns number of uniq points, or, false if a loop
def traverse( c, grid )

  points, seen = {},{}
  loop do
    seen[c.hash] = true
    points[c.location.dup]=1
    c.turn(:direction=>'R') while grid[c.next_forward(:by=>1)] == '#'
    c.forward(:by=>1)
    return points if ! grid[c.location]
    return false if seen.key?(c.hash)
  end
end

grid = Grid.new( :io => ARGF.read.chomp )

start = nil
grid.each do |p,v|
  next unless v == '^'
  start = p
  break
end

# part 1
visited = traverse( Cursor.new( x:start.x,y:start.y,heading:'N',:ygrows=>:south), grid )
p visited.length

# part 2
spaces = []
grid.each do |p,v|
  spaces << p if ( v != '#' && visited.key?(p) )
end

loops = 0
spaces.each do |space|
  grid[space] = '#'
  loops += 1 if ! traverse( Cursor.new( x:start.x,y:start.y,heading:'N',:ygrows=>:south), grid )
  grid[space] = '.'
end
p loops





