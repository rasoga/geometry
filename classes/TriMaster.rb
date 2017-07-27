require_relative 'Triangle'
require_relative 'Initiator'
require_relative 'Values'

class TriMaster
  attr_accessor :list,:type,:maxLvl,:maxExp
  
  def initialize(a,b,c)
    @list = []
    set = [a,b,c]
    set.sort!
    
    #check if values fit space
    val = ( b*c+a*c+a*b == a*b*c)
    if b*c+a*c+a*b == a*b*c
      @list.push(initEucl(a,b,c))
      @type = 0
    elsif b*c+a*c+a*b < a*b*c
      @list.push(initHyp(a,b,c))
      @type = -1
    else
      #@list.push(initSphe(a,b,c)) needs implementing
      @type = 1
    end
    
    @ep = $ep
    @maxLvl = 0
    @maxExp = set[2]
  end
  
  def addTri(t)
    #check if triangle already exists...there should at max one...because we filter every time
    #puts t.c
    #puts t.p1
    #puts t.c.norm()
    #== check if triangle is too near the border in hyperbolic case
    if t.isHyp? and t.c.norm() > ( $scale - $cutVal )
      return
    end
    
    tmp = -1
    dist = 0
    for i in 0..@list.length-1
      l = @list[i]
      if l.level > (( @maxLvl - @maxExp )-2 ) # -2 for convienience...just in case
        if l.isEucl?
          dist = (l.c - t.c).inner_product(l.c - t.c)
        elsif l.isHyp?
          dist = (l.c - t.c).inner_product(l.c - t.c) #fix
        else
          dist = (l.c - t.c).inner_product(l.c - t.c) #fix
        end
        if dist < @ep
          tmp = i
        end
      end
    end
    
    unless tmp == -1
      if t.level < @list[tmp].level
        @list.delete_at(tmp)
        @list.push(t)
      end
    else
      @list.push(t)
    end
    
    #check for new max lvl
    if @maxLvl < t.level
      @maxLvl = t.level
    end
  end
  
  def reflect
    #puts " =start reflecting"
    counter = 0
    lol = @list.length - 1
      lol.downto(0) do |i|
        #only if update nec. around start nothing will happen
        if @list[i].level > ( @maxLvl - @maxExp ) 
          addTri(@list[i].reflect(1))
          addTri(@list[i].reflect(2))
          addTri(@list[i].reflect(3))
          counter += 1
        end
    end
    #puts " *" + counter.to_s + " Triangles reflected"
  end
  
  def time_diff(start_time, end_time)
    seconds_diff = (start_time - end_time).to_i.abs

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60

    seconds = seconds_diff

    "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end
end
