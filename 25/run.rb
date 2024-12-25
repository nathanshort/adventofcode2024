
require_relative '../lib/common'

locks, keys = [],[]

ARGF.read.split(/\n\n/).each do |data|
  g = Grid.new(io:data)
  width = g.width
  if (0..width-1).count{ |x| g[Point.new( x,0 )] == '#' } == width
    locks << g
  else
    keys << g
  end
end


numfits = 0 
locks.each do |lock|

  lp = Hash.new { |h,k| h[k]=0 }
  lock.points.each { |p,v| lp[p.x] += 1 if v == '#' }

  keys.each do |key|
    kp = Hash.new { |h,k| h[k]=0 }
    key.points.each { |p,v| kp[p.x] += 1 if v == '#' }

    fits = true
    (0..lock.width-1).each do |col|
      if lp[col]+kp[col] > lock.height
        fits = false
        break
      end
    end
    numfits += 1 if fits
  end
end

p numfits
