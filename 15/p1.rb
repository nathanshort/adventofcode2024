require_relative '../lib/common.rb'

wall,box,free = '#','O','.'

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
  loop do
    cc.forward(by:1)
    break if g[cc.next_forward(by:1)] != box
  end

  ccnf = cc.next_forward(by:1)

  # hit a wall - cant push
  next if g[ccnf] != free

  # swap immediate next box with space, and last space with block
  g[ccnf] = box
  c.forward(by:1)
  g[c.location] = free
end

p g.sum { |p,v| v == box ? 100*p.y+p.x : 0 }
