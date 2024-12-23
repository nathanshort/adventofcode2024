
def doit( secret, sums )

  seen = {}
  prevones = secret % 10
  seq = []

  2000.times do 

    number = secret * 64
    secret = secret ^ number
    secret = secret % 16777216

    number = secret / 32
    secret = secret ^ number
    secret = secret % 16777216

    number = secret * 2048
    secret = secret ^ number
    secret = secret % 16777216

    ones = secret % 10
    diff = ones - prevones
    seq << diff

    seq.shift if seq.length > 4
    if seq.length == 4
      key = seq.join(",")
      if ! seen.key?(key)
        sums[key] += ones
        seen[key] = true
      end
    end
    prevones = ones
  end
end


secrets = ARGF.read.split(/\n/).map(&:to_i)

sums = Hash.new { |h, k| h[k] = 0 }
secrets.each{ |s| doit( s, sums ) }
p sums.values.max
