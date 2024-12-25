require_relative '../lib/common'


def path2dir( path )
  dirs = []
  path.each_cons(2) do |a,b|
    dirs << '>' if a.x < b.x
    dirs << '<' if a.x > b.x
    dirs << '^' if a.y > b.y
    dirs << 'v' if a.y < b.y
  end
  dirs
end


def allpaths( start, eend, grid )

  paths = []
  q = [{path:[start],seen:{}}]

  while ! q.empty?
    x = q.pop
    path = x[:path]
    point=path.last
    if point == eend
      paths << path
      next
    end

    x[:seen][point] = 1
    point.hvadjacent.each do |adj|
      next if ! grid[adj] || grid[adj] == 'X' || x[:seen][adj]
      q.push({path:path+[adj],seen:x[:seen].dup})
    end
  end
  paths
end


def docost_helper( path, pad, depth, maxdepth  )

  return path.length if depth > maxdepth
  cost = 0
  (['A']+path).each_cons(2) { |a,b| cost += docost( a, b, depth, maxdepth ) }
  cost
end


def docost( start, eend, depth, maxdepth  )

  key = [start,eend,depth]
  return $cache[key] if $cache.key?(key)

  bestcost = 1_000_000_000_000_000_000
  pad = depth == 0 ? $npad : $dpad
  paths = allpaths( pad.find{ |p,v| v==start }.first, pad.find{ |p,v| v==eend }.first, pad )

  paths.each do |path|
    path_as_cursor = path2dir(path)
    pathcost = docost_helper( path_as_cursor + ['A'], $dpad, depth + 1, maxdepth )
    bestcost = [bestcost,pathcost].min
  end

  $cache[key] = bestcost
  bestcost
end

codes = ARGF.read.split(/\n/).map{ |x| x.split(//)}
$npad = Grid.new(io:"789\n456\n123\nX0A")
$dpad = Grid.new(io:"X^A\n<v>")

[2,25].each do |maxdepth| 

  $cache = {}
  complexity = 0
  cur = 'A'
  codes.each do |code|
    cost = 0
    code.each do |c|
      cost += docost(cur,c,depth=0,maxdepth )
      cur = c
    end
    complexity += cost * code.join.scan(/\d+/).first.delete_prefix("0").to_i
  end
  p complexity
end
