require_relative '../lib/common.rb'

grid = Grid.new( :io => ARGF.read.chomp )

price1,price2 = 0,0
seen = {}

grid.each do |p,v|

  plots,fences = 0,0
  hfs = Hash.new { |h,k| h[k]=[] }
  vfs = Hash.new { |h,k| h[k]=[] }

  queue = [p]
  while queue.length > 0
    pp = queue.pop
    next if seen.key?(pp)
    plots += 1
    seen[pp] = true

    pp.hvadjacent.each do |adj|

      if grid[adj] != v
        fences += 1

        # Keep track of the start and end point of each length 1 horizontal and vertical fence
        # segment. Then ( for example ) for each hfs, sort ascending, iterate, and if the start
        # point of the next segment is not the end point of the last segment - then those
        # segments are not adjacent so we have a new segment.  The :o (orientation) is a hack
        # to account for colinear and adjacent segments, but where the fence is not actually
        # continuous as it is the top vs bottom ( for example ) fence of different sections.
        # This scenario was true in the example, and in the actual input
        #
        # AAAAAA
        # AAABBA
        # AAABBA  <--
        # ABBAAA  <--
        # ABBAAA
        # AAAAAA
        #

        dx = (adj.x - pp.x)
        dy = (adj.y - pp.y)
        hfs[pp.y] << {:p=>pp.x,:o=>:u} << {:p=>pp.x+1,:o=>:u} if dy == -1
        hfs[pp.y+1] << {:p=>pp.x,:o=>:d} << {:p=>pp.x+1,:o=>:d} if dy == 1
        vfs[pp.x] << {:p=>pp.y,:o=>:l} << {:p=>pp.y+1,:o=>:l} if dx == -1
        vfs[pp.x+1] << {:p=>pp.y,:o=>:r} << {:p=>pp.y+1,:o=>:r} if dx == 1
      end

      next if seen.key?(adj)
      queue << adj if ! seen.key?(adj) && grid[adj] == v
    end
  end

  segments = 0
  [hfs,vfs].each do |fs|
    fs.each do |_,vals|
      prev = nil
      vals.sort{|a,b| a[:p]<=>b[:p] }.each_slice(2) do |seg|
        segments += 1 if prev.nil? || seg.first != prev
        prev = seg.last
      end
    end
  end

  price1 += plots * fences
  price2 += plots * segments

end
p price1,price2
