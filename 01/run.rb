
l1,l2 = [],[]
ARGF.each_line do |line|
  a,b = line.split(/\s+/).map(&:to_i)
  l1 << a
  l2 << b
end
l1.sort!
l2.sort!

p l1.zip(l2).reduce(0){ |sum,p| sum+(p.first-p.last).abs }
p l1.reduce(0){ |sum,item| sum+l2.count(item)*item }
