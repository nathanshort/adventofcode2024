
def valid?( rules, update )
  update.each_with_index do |item,index|
    r = rules[item]
    next if r.nil?
    r.each do |rr|
      ri = update.index(rr)
      return [ index, ri ] if ri && ri < index
    end
  end
  true
end

a,b = ARGF.read.split(/\n\n/)
rules = Hash.new { |h, k| h[k] = [] }
a.split(/\n/).map{ |x| x.split(/\|/).map(&:to_i) }.each { |p| rules[p[0]] << p[1] }
updates = b.split(/\n/).map{ |x| x.split(/,/).map( &:to_i) }

valid_score, invalid_score = 0,0

updates.each do |u|
  valid = valid?( rules, u)
  if valid == true
    valid_score += u[u.length/2]
  else
   loop do
      u[valid[0]],u[valid[1]] = u[valid[1]],u[valid[0]]
      valid = valid?(rules,u)
      break if valid == true
   end
   invalid_score += u[u.length/2]
  end
end

p valid_score
p invalid_score
