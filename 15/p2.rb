require_relative '../lib/common.rb'

wall,box,free,boxl,boxr = '#','O','.','[',']'

a,b =ARGF.read.split(/\n\n/)
ins = b.gsub("\n","")
g = Grid.new(:io=>a)
start = g.find { |k,v| v=='@' }.first
c = Cursor.new(x:start.x,y:start.y,ygrows: :south)
g[start]=free


ins.each_char do |i|

  c.heading=Cursor.caret_to_heading(i)
  nf = c.next_forward(by:1)

  next if g[nf] == wall

  if g[nf] == free
    c.forward(by:1)
    next
  end

  cc = c.clone
  if ['E','W'].include?(c.heading)
    loop do
      cc.forward(by:1)
      break if ! [boxl,boxr].include?(g[cc.next_forward(by:1)])
    end
    ccnf = cc.next_forward(by:1)

    # hit a wall - cant push
    next if g[ccnf] != free

    dx = nf.x-c.location.x
    range = c.heading == 'E' ? ccnf.x.downto(nf.x).to_a : ccnf.x.upto(nf.x).to_a
    range.each { |x| g[Point.new(x,c.location.y)] = g[Point.new(x-dx,c.location.y)] }
    c.forward(by:1)

    # pushing north or south
  else

    hitwall = false
    dy = c.next_forward(by:1).y-c.location.y
    q = [nf]
    seen = {}
    while q.length > 0
      i = q.pop
      seen[i] = true
      qp = g[i] == '[' ?  Point.new(i.x+1,i.y) :  Point.new(i.x-1,i.y)
      q << qp if !seen.key?(qp)
      pp = Point.new(qp.x,qp.y+dy)
      if [boxl,boxr].include?(g[pp])
        q << pp
      elsif g[pp] != free
        hitwall = true
        break
      end
    end
    next if hitwall == true

    ysminmax = seen.keys.map{ |p| p.y }.minmax
    ty = c.heading == 'N' ? ysminmax.first : ysminmax.last

    canmove,need2move=0,0
    seen.keys.each do |p|
      next if p.y != ty
      need2move+=1
      break if g[Point.new(p.x,p.y+dy)] != free
      canmove+=1
    end
    next if canmove != need2move

    range =
      ysminmax.first == ysminmax.last ? [ysminmax.first] :
        (c.heading == 'N' ?  ysminmax.first.upto(ysminmax.last) : ysminmax.last.downto(ysminmax.first) )

    range.each do |yy| 
      seen.keys.each do |p|
        next if p.y != yy
        ev = g[p]
        g[Point.new(p.x,p.y+dy)] = ev
        g[p] = free
      end
    end

    c.forward(by:1)
  end
end

g.show
p g.sum { |p,v| [boxl].include?(v) ? 100*p.y+p.x : 0 }
