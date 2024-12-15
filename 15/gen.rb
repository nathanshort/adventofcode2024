a,b =ARGF.read.split(/\n\n/)
ng = []
a.each_char do |c|
  if c == 'O'
    ng << "[]"
  elsif c == "\n" 
    ng << c
  elsif c == '@'
    ng << '@' << '.'
  else
    ng << c << c
  end
end

puts ng.join,"\n",b
