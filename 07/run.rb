
rows = ARGF.each_line.map { |line| line.scan(/\d+/).map(&:to_i) }

hits = []
rows.each do |row|

  target = row.first
  values = row[1..]
  hit = false

  [:add,:mul,:cat].repeated_permutation(values.count-1).each do |ops|
    sum = values[0]
    i = 1
    ops.each do |op|
      case op
      when :add
        sum = sum + values[i]
      when :mul
        sum = sum * values[i]
      when :cat
        sum = "#{sum}#{values[i]}".to_i
      end
      i+= 1
      break if sum > target
    end
    hit = true if sum == target
  end
  hits << target if hit
end

p hits.flatten.sum
