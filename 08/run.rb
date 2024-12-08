require_relative '../lib/common.rb'

def get_antinodes(antennas,grid,harmonic)
  antinodes = []
  antennas.each do |_,points|
    points.combination(2).each do |p|
      dy,dx = (p[0].y-p[1].y),(p[0].x-p[1].x)
      loop do
        n1 = Point.new( p[0].x+dx,p[0].y+dy )
        antinodes << n1 if grid[n1]
        n2 = Point.new( p[1].x-dx,p[1].y-dy )
        antinodes << n2 if grid[n2]
        p[0], p[1] = n1, n2
        break if ! harmonic || ( !grid[n1] && !grid[n2] )
      end
    end
  end
  antinodes
end

grid = Grid.new( :io => ARGF.read.chomp )
antennas = Hash.new { |h,k| h[k]=[] }
grid.each { |k,v| antennas[v] << k unless v == '.' }

p get_antinodes(antennas,grid,harmonic=false).uniq.length

# points of antennas w/at least 1 pair
ua = antennas.select{ |k,v| v.length > 1 ? k : false  }.values.flatten
p (get_antinodes(antennas,grid,harmonic=true) | ua ).length
