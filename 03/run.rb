
memory = ARGF.read
p memory.scan(/mul\((\d+),(\d+)\)/).sum{ |p| p[0].to_i * p[1].to_i }

sum = 0
doit = true
memory.scan(/mul\((\d+),(\d+)\)|(do\(\))|(don't\(\))/).each do |match|
  if doit && ! match[0].nil?
    sum += match[0].to_i * match[1].to_i
  elsif ! match[2].nil?
    doit = true
  elsif ! match[3].nil?
    doit = false
  end
end
p sum

