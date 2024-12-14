require_relative '../lib/common.rb'

data = []
ARGF.each_line do |line|
  d = line.scan(/-?\d+/).map(&:to_i)
  data << {x:d[0],y:d[1],dx:d[2],dy:d[3]}
end

w,h,t=101,103,1

# quadrant ranges used for part 1
qs = [ {x:(0..w/2-1), y:(0..h/2-1)},{x:(w.fdiv(2).ceil..w-1),y:(0..h/2-1)},
       {x:(0..w/2-1), y:(h.fdiv(2).ceil..h-1)}, {x:(w.fdiv(2).ceil..w-1),y:(h.fdiv(2).ceil..h-1)}]


orig = Marshal.load(Marshal.dump(data))

# find if this loops.
loop_at = nil
1_000_000.times do |tt|
  data.each do |d|
    d[:x] = ( d[:x]+t*d[:dx] ) % w
    d[:y] = ( d[:y]+t*d[:dy] ) % h
  end
  if data == orig
    loop_at = tt
    break
  end
end


# find the second where the distance from the center is minimized
data = Marshal.load(Marshal.dump(orig))
distances = []
centerx,centery = w/2,h/2

loop_at.times do |tt|
  dfc = 0
  data.each do |d|
    d[:x] = ( d[:x]+t*d[:dx] ) % w
    d[:y] = ( d[:y]+t*d[:dy] ) % h
    dfc += (d[:x]-centerx).abs + (d[:y]-centery).abs
  end
  distances << dfc
end

best_guess = distances.index(distances.min)+1
gg = Grid.new
orig.each do |d|
  d[:x] = ( d[:x]+best_guess*d[:dx] ) % w
  d[:y] = ( d[:y]+best_guess*d[:dy] ) % h
  gg[Point.new(d[:x],d[:y])] = '#'
end

p best_guess
gg.show
