

def part2( possible, targets, allpossible )

  target = targets.pop
  return if target == nil

  possible.each do |ra|

    rb = ( ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) ) ^ 3 ) % 8
    next if rb != target
    rb = ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) ) ^ 3
    rb = ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) )
    rc = ra / ( 2 ** (( ra % 8 ) ^ 2) )
    rb = ( ra % 8 ) ^ 2
    rb = ra % 8

    minra = ra*8
    nextpossible = [minra]

    # as ra is truncated, find all possible values that would result
    # in the same ra - and try them all
    answer = minra/8
    try = 1
    loop do
      option = (minra+try)/8
      break if option != ra
      nextpossible << minra+try
      try += 1
    end

    if targets.length == 1
      allpossible << nextpossible
    else
      part2( nextpossible, targets.dup, allpossible )
    end
  end
end



def runprogram( ra, rb, rc, program )
  pc = 0
  out = []

  loop do
    opcode=program[pc]
    break if opcode.nil?
    operand=program[pc+1]
    literal = operand
    combo =
      case literal
      when 4
        ra
      when 5
        rb
      when 6
        rc
      else
        literal
      end

    inc = true

    case opcode
    when 0
      ra/= 2**combo
    when 1
      rb^= literal
    when 2
      rb = combo%8
    when 3
      if ra != 0
        inc = false
        pc = literal
      end
    when 4
      rb^=rc
    when 5
      out << combo%8
    when 6
      rb=ra/2**combo
    when 7
      rc=ra/2**combo
    end
    pc += 2 if inc
  end
  out
end

d = ARGF.read.scan(/\d+/).map(&:to_i)
ra,rb,rc,program = d[0],d[1],d[2],d[3..]

#
# 2,4 rb = ra % 8
# 1,2 rb = rb ^ 2
# 7,5 rc = ra/(2**rb)
# 4,7 rb = rb ^ rc
# 1,3 rb = rb ^ 3
# 5,5 print rb % 8
# 0,3 ra = ra/(2**3)
# 3,0 jump to beginning if ra != 0

# rb = ra % 8
# rb = ( ra % 8 ) ^ 2
# rc = ra / ( 2 ** (( ra % 8 ) ^ 2) )
# rb = ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) )
# rb = ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) ) ^ 3
# print 2. ( ( ( ra % 8 ) ^ 2) ^ ( ra / ( 2 ** (( ra % 8 ) ^ 2) ) ) ^ 3 ) % 8 = 2
# ra = ra / 8
#

# when we exit, ra is 0.  as ra = (ra/8).floor right before exit, the last ra
# can be one of
possible = [0,1,2,3,4,5,6,7]

targets = [2,4,1,2,7,5,4,7,1,3,5,5,0,3,3,0]
allpossible = []
part2( possible, targets, allpossible )

winners = []
allpossible.flatten.each do |option| 
  winners << option if runprogram( option, rb, rc, program ) == program
end
p winners.min
