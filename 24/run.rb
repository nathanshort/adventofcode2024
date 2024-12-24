
aa,bb = ARGF.read.split(/\n\n/)

gates = {}
circuit,rcircuit = {},{}

aa.split(/\n/).each do |a|
  gate, value = a.split(/: /)
  gates[gate] = value.to_i
end

bb.split(/\n/).each do |b|
  d = b.split(/ /)
  sorted = [d[0],d[2]].sort
  circuit[d[4]] = [sorted[0],d[1],sorted[1]]
  rcircuit[[sorted[0],d[1],sorted[1]]] = d[4]
end

def solve( forr, g, c)
  return g[forr] if g.key?(forr)
  o1,op,o2 = c[forr]
  a1,a2 = solve(o1,g,c),solve(o2,g,c)
  g[forr] =
    case op
    when "AND"
      a1 & a2
    when "OR"
      a1 | a2
    when "XOR"
      a1 ^ a2
    end
  g[forr]
end


def find(a,op,b,rcircuit)
  [[a,op,b],[b,op,a]].each do |option|
    return rcircuit[option] if rcircuit.key?(option)
  end
  return nil
end


def reconfigure( a, b, rcircuit )

  tmp = {}
  rcircuit.each do |k,v|
    if v == a
      tmp[k] = b
    elsif v == b
      tmp[k] = a
    else
      tmp[k] = v
    end
  end
  tmp
end

# part 1
circuit.keys.each do |k|
  solve( k, gates, circuit )
end
p gates.keys.select{ |k| k[0] == 'z' }.sort.reverse.map{ |v|gates[v]}.join.to_i(2) 


num_outputs = gates.count{ |k,_| k[0] == 'z' }
swapped = []
t = 0
carry = nil

loop do

  break if t >= num_outputs-1

  key = sprintf( "%02d", t )
  xkey = "x"+key
  ykey = "y"+key
  zkey = "z"+key

  if t == 0
    carry = find( xkey, 'AND', ykey, rcircuit )
    t+= 1
    next
  end

  x_xor_y = find( xkey,'XOR',ykey,rcircuit )
  if x_xor_y.nil?
    p "BAD 1 SHOULDNT HAPPEN x_xor_y"
    exit
  end
  x_and_y = find( xkey,'AND',ykey,rcircuit )

  x_xor_y__xor__carry = find( x_xor_y,'XOR',carry, rcircuit )
  if x_xor_y__xor__carry.nil?
    swapped << x_xor_y << x_and_y
    rcircuit = reconfigure( x_xor_y, x_and_y, rcircuit )
    t = 0
    next
  elsif x_xor_y__xor__carry != zkey
    swapped << zkey << x_xor_y__xor__carry
    rcircuit = reconfigure( zkey, x_xor_y__xor__carry, rcircuit )
    t = 0
    next
  end

  carry_and = find( x_xor_y,'AND',carry, rcircuit )
  if carry_and.nil?
    p "BAD 1 SHOULDNT HAPPEN carry_and"
    exit
  end
  next_carry = find( x_and_y,'OR',carry_and, rcircuit )
  if next_carry.nil?
    p "BAD 1 SHOULDNT HAPPEN next_carry"
    exit
  end

  carry = next_carry
  t += 1
end

puts swapped.sort.join(",")


