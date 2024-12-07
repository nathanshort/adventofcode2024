
class PointNd

  attr_reader :components

  def initialize( components )
    @components = components
  end

  def ==(other)
    @components == other.components
  end

  alias eql? ==

  def hash
    hash = nil
    components.each do |c|
      hash = ( hash ? hash ^ c.hash : c.hash )
    end
    hash
  end

  def adjacent
    if ! @adjacent
      @adjacent = []
      product_operands = []
      ( @components.count - 1 ).times do 
       product_operands << [-1,0,1]
      end
      cartesian = [-1,0,1].product( *product_operands )
      cartesian.each do |p|
        new_components = []
        @components.each_with_index do |c,index|
        new_components[index] = c + p[index]
      end
      p = PointNd.new( new_components)
      @adjacent << p if p != self
      end
    end
    @adjacent
  end

end


class Point 

  attr_accessor :x, :y
  
  def initialize( x, y )
    @x, @y = x, y
  end
  
  def ==(other)
    other.x == @x && other.y == @y 
  end

  alias eql? ==

        def hash
          @x.hash ^ @y.hash
        end

  def <=>( other )
    ysort = ( @y <=> other.y )
    xsort = ( @x <=> other.x )
    ysort != 0 ? ysort : xsort 
  end

  def hvadjacent() 
    [ Point.new( @x - 1, @y ),
      Point.new( @x + 1, @y ),
      Point.new( @x, @y + 1 ),
      Point.new( @x, @y - 1 )
    ]
   end

  def adjacent() 
    [ Point.new( @x - 1, @y ),
      Point.new( @x - 1, @y - 1 ),
      Point.new( @x, @y - 1 ),
      Point.new( @x + 1, @y - 1 ),
      Point.new( @x + 1, @y ),
      Point.new( @x + 1, @y + 1 ),
      Point.new( @x, @y + 1 ),
      Point.new( @x - 1, @y + 1 )
    ]
   end

  def to_s
    "(#{@x},#{@y})"
  end
end


class Cursor

  attr_accessor :location, :heading, :ygrows

  # set :ygrows to :north or :south
  # :north -> north moves, increase the y
  # :south -> south moves, increase the y
  # defaut is :north
  def initialize( args )
    @heading = args[:heading]
    @location = Point.new( args[:x] || 0, args[:y] || 0 )
    @ygrows = args[:ygrows] || :north
  end

  def initialize_copy( original )
    @location = original.location.dup
  end

  def move( args )
    case args[:direction]
      when 'N'
        @location.y -= args[:by]
      when 'S'
        @location.y += args[:by]
      when 'W'
         @location.x -= args[:by]
      when 'E'
        @location.x += args[:by]
      end
  end

  def turn( args )
    turns = %w[N E S W]
    case args[:direction]
      when 'L'
        @heading = turns[ turns.index( @heading ) - 1 ]
      when 'R'
        @heading = turns[ ( turns.index( @heading ) + 1 ) % turns.count ]
    end
  end

  def next_forward( args )
    factor = ( @ygrows == :south ) ? { 'N' => -1, 'S' => 1, 'E' => 1, 'W' => -1}
             : { 'N' => 1, 'S' => -1, 'E' => 1, 'W' => -1}

    x, y = @location.x, @location.y
    case @heading
    when 'N','S' 
      y += args[:by] * factor[@heading]
    when 'E','W'
      x += args[:by] * factor[@heading]
    end
    Point.new(x,y)
  end 

  def forward( args )
    factor = ( @ygrows == :south ) ? { 'N' => -1, 'S' => 1, 'E' => 1, 'W' => -1}
             : { 'N' => 1, 'S' => -1, 'E' => 1, 'W' => -1}

    case @heading
      when 'N','S' 
        @location.y += args[:by] * factor[@heading]
      when 'E','W'
        @location.x += args[:by] * factor[@heading]
    end
  end

  def rotate( args )
    case args[:direction]
      when 'L'
        tmp = @location.dup
        @location.x = -tmp.y
        @location.y = tmp.x
      when 'R'
        tmp = @location.dup
        @location.x = tmp.y
        @location.y = -tmp.x
    end
  end
end
  



class Grid

  include Enumerable 
  attr_accessor :points, :xmin, :ymin, :xmax, :ymax

  def []( point )
    @points[point]
  end

  def []=(point,value)
    @points[point] = value
    if @ymax.nil? || point.y > ymax
      @ymax = point.y
    end
    if @ymin.nil? || point.y < ymin
      @ymin = point.y
    end

    if @xmax.nil? || point.x > xmax
      @xmax = point.x
    end
    if @xmin.nil? || point.x < xmin
      @xmin = point.x
    end
  end

  def covers?(point)
    point.x >= @xmin && point.x <= @xmax && point.y >= @ymin && point.y <= @ymax
  end

  def initialize( args = {} ) 
    @points = {}
    @xmin, @ymin, @xmax, @ymax = 0,0,0,0

    if args[:nooriginy]
      @ymin, @ymax = nil, nil
    end
    if args[:nooriginx]
      @xmin, @xmax = nil, nil
    end

    if args[:io]
      yindex = 0
      args[:io].each_line.with_index do |line,liney|
        @ymax = yindex
        empty_line = true
        line.chomp.chars.each_with_index do |c,x|
          if block_given?
            x,y,c = yield( x,yindex,c )
          end
          if ! args[:spotsonly] || args[:spotsonly].include?(c)
            @points[Point.new(x,yindex)] = c
            empty_line = false
          end
          @xmax = x if @xmax < x
        end
        yindex += args[:expandemptyy] if empty_line && !args[:expandemptyy].nil?
        yindex += 1
     end
    end

    if args[:expandemptyx]
      byx = Hash.new { |h, k| h[k] = [] }
      @points.each{ |p,v| byx[p.x] << [p,v] }

      accums = []
      accum = 0
      width.times do |x|
        accum += args[:expandemptyx] if ! byx.key?(x)
        accums[x] = accum
      end

      accums.to_enum.with_index.reverse_each do |xoff,i| 
        next if xoff == 0
        byx[i].each do |p,v|
          @points[Point.new(p.x+xoff,p.y)] = v
          @points.delete(p)
        end
      end
      @xmax += accums.last
    end

  end

  def height
    @ymax - @ymin + 1
  end

  def width
    @xmax - @xmin + 1
  end

  def initialize_copy( original )
    @points = original.points.dup
  end

  def show
    (@ymin..@ymax).each do |y|
      (@xmin..@xmax).each do |x| 
        print @points[Point.new(x,y)] || " "
      end
      print "\n"
   end
   print "\n\n"
  end

  def each( &block )
    if block_given?
      points.keys.sort.each do |k|
        block.call( k, points[k] )
      end
    else
      to_enum(:each)
    end
  end

  def eweach( &block )
    if block_given?
      (@ymin..@ymax).each do |y|
        @xmax.downto(@xmin).each do |x| 
          block.call( Point.new(x,y), points[Point.new(x,y)] )
        end
      end
    else
      to_enum(:rleach)
    end
  end

  def sneach( &block )
    if block_given?
      @ymax.downto(@ymin).each do |y|
        (@xmin..@xmax).each do |x| 
          block.call( Point.new(x,y), points[Point.new(x,y)] )
        end
      end
    else
      to_enum(:sneach)
    end
  end

  def edge_points( &block )
    ( @ymin..@ymax).each do |y| 
      xs = ( y == @ymin || y == @ymax) ? (0..@xmax).to_a : [ 0, @xmax ]
      xs.each do |x| 
        block.call( Point.new( x,y ))
      end
    end
  end


  def outside_points( negx, posx, negy, posy, &block )
    ( @ymin - negy .. ( @ymax + posy ) ).each do |y|
      ( @xmin - negx .. ( @xmax + posx ) ).each do |x|
        if x < @xmin || x > @xmax || y < @ymin || y > @ymax
          block.call( Point.new(x,y) )
        end
      end
    end
  end

  def ==( other )
    other.points == @points
  end

  def hash
    val = nil
    points.each do |p,v|
      val = ( val ? p.hash ^ v.hash ^ val.hash : p.hash ^ v.hash )
    end
    val
  end

end


class RepeatingGrid < Grid

  def initialize( args = {} )
    super( args )
  end

  def []( point )

    return @points[point] if point.x >= @xmin && point.x <= @xmax &&
                             point.y >= @ymin && point.y <= @ymax

    effectivex,effectivey = nil
    if point.x < @xmin
      effectivex = (width - (@xmin-point.x).abs ) % width
    elsif point.x > @xmax
      effectivex = @xmin + (point.x % width)
    else
      effectivex = point.x
    end

    if point.y < @ymin
      effectivey = (height - (@ymin-point.y).abs ) % height
    elsif point.y > @ymax
      effectivey = @ymin + (point.y % height)
    else
      effectivey = point.y
    end

    @points[Point.new(effectivex,effectivey)]
  end
end


class ShiftedGrid < Grid

  attr_accessor :xoff, :yoff

  def initialize( args = {} )
    super( args )
    @xoff, @yoff = 0,0
  end

  def xmin
    @xmin + @xoff
  end

  def xmax
    @xmax + @xoff
  end

  def each( &block )
    if block_given?
      points.keys.sort.each do |k|
        block.call( Point.new(k.x+@xoff,k.y+@yoff), points[k] )
      end
    else
      to_enum(:each)
    end
  end
end


