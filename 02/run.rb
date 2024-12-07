
def doit( report )

  direction = report[0] <=> report[1]
  i = 0
  while i < report.length - 1 
    dir = report[i] <=> report[i+1]
    distance  = ( report[i] - report[i+1]).abs
    break if dir != direction || distance < 1 || distance > 3
    i+=1
  end
  i == report.length-1
end


reports = ARGF.each_line.map{ |line| line.split(/\s+/).map(&:to_i) }

# part 1
p reports.count{ |r| doit(r) }

# part 2
safe = 0
reports.each do |report|
  report.combination( report.count - 1 ).to_a.each do |c|
    if doit( c )
      safe += 1
      break
    end
  end
end

p safe
