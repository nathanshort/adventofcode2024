
data = ARGF.read.chomp.split(//).map(&:to_i)

id, rid = 0, data.length / 2
index, rindex = 0, data.length - 1
defrag = []
rremaining = data[rindex]

while index < rindex

  data[index].times { defrag << id }
  spaces = data[index+1]

  while spaces > 0
    tofill = [spaces,rremaining].min
    tofill.times { defrag << rid }
    spaces -= tofill
    rremaining -= tofill

    if rremaining == 0
      rindex -= 2
      rid -= 1
      rremaining = data[rindex]
    end
  end

  index += 2
  id += 1
end

# if any left at the end
rremaining.times { defrag << rid } if rremaining
p defrag.each_with_index.sum{ |item,index| item*index }


# part 2
id, index = 0,0
files, spaces = [],[]

data.each_with_index do |item,itemindex|

  if itemindex.even?
    files << { :index=>index, :id => id, :len => data[itemindex] }
    id += 1
  else
    spaces << { :index=>index, :len => data[itemindex] }
  end
  index += data[itemindex]
end

moved = []
rindex = files.length-1

while rindex >= 0

  file = files[rindex]
  to_move_to_index = spaces.index { |s| s[:len] >= file[:len] && s[:index] < file[:index]}
  if to_move_to_index != nil

    space = spaces[to_move_to_index]
    moved << { :id=>file[:id],:len=>file[:len],:index=>space[:index] }

    remaining = space[:len] - file[:len]
    if remaining == 0
      spaces.delete_at( to_move_to_index )
    else
      spaces[to_move_to_index] =
        {:index => space[:index]+file[:len], :len => space[:len]-file[:len]}
    end
    files.delete_at(rindex)
  end
  rindex -= 1
end

sum = 0
(files|moved).each { |file| file[:len].times { |t| sum += (file[:index]+t) * file[:id] } }
p sum
