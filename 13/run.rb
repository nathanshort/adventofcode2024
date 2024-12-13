# Button A: X+94, Y+34
# Button B: X+22, Y+67
# Prize: X=8400, Y=5400

# PA*Ax + PB*Bx = Tx
# PA*Ay + PB*By = Ty
#
# solve for PA ( 'pushes on A' count ) in terms of PB
# PA*Ax = Tx - PB*Bx
# PA = ( Tx - PB*Bx ) / Ax
#
# substitute into 2nd equation
# PA*Ay + PB*By = Ty
# (( Tx - PB*Bx ) / Ax ) * Ay + PB*By = Ty
# (Ay*Tx-PB*Bx*Ay)/Ax + PB*By = Ty
# (Ay*Tx-PB*Bx*Ay)/Ax = Ty -PB*By
# Ay*Tx-PB*Bx*Ay = Ty*Ax - PB*By*Ax
# Ay*Tx - Ty*Ax = -PB*By*Ax + PB*Bx*Ay
# Ay*Tx - Ty*Ax = PB(-1*By*Ax + Bx*Ay)
# PB = (Ay*Tx - Ty*Ax)/(-1*By*Ax + Bx*Ay)

claws = ARGF.read.split(/\n\n/).map{ |claw| claw.scan(/\d+/).map(&:to_i) }

def doit( claws, tadd )
  claws.sum do |c|
    ax,ay,bx,by,tx,ty = c
    pb = (ay*(tx+tadd)-(ty+tadd)*ax)/(-1*by*ax + bx*ay)
    pa = ((tx+tadd)-pb*bx )/ax
    pa*ax+pb*bx == tx+tadd && pa*ay+pb*by == ty+tadd ? pa*3+pb : 0
  end
end

p doit(claws,0)
p doit(claws,10000000000000)

