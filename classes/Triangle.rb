require 'matrix'
#require 'math'
require_relative 'Values'
require_relative 'Edge'

class Triangle
  attr_accessor :p1,:p2,:p3,:e1,:e2,:e3,:w1,:w2,:w3,:c,:type,:level,:parent
  
  def initialize(t=0,p=Vector[0,0],q=Vector[1,0],r=Vector[0,1])
    @ep = $ep
    @type = t
    @p1 = p
    @p2 = q
    @p3 = r
    @level = 0 #level saves the minimal number of reflections to generate that triangle
    @parent = 0 #just in case
    case t
    when 0 
      @c = (p+q+2*r)/4.0
    when -1
      tmpC=0.5 * ( p / (1+p.norm()*p.norm()) + q / (1+q.norm()*q.norm()) ) + r / (1+r.norm()*r.norm())
      @c = tmpC / ( 1 + Math.sqrt(1 - tmpC.norm()*tmpC.norm()) )
      @c = $scale**2 * @c #ÖÖÖÖHM....wieso man scale^2?
      if @c[0].abs < @ep
        @c = Vector[0,@c[1]]
      end
      if @c[1].abs < @ep
        @c = Vector[@c[0],0]
      end
      # use euclidian case...other seems weird
      @c = (p+q+2*r)/4.0
    else 
      @c = Vector[0,0]
    end
  end
  
  def updateCenter #assume edges are present
    #winkelhalbierende p1
    turn = Matrix[[0,-1.0],[1.0,0]]
    
  end
  
  def setAngles(a,b,c)
    @w1 = a
    @w2 = b
    @w3 = c
  end  
  
  def edges
    return [@e1, @e2, @e3]
  end
  
  def type?
    return @type
  end
  
  def isEucl?
    @type == 0 ? true : false
  end
  def isHyp?
    @type == -1 ? true : false
  end
  def isSpher?
    @type == 1 ? true : false
  end
  
  def reflect(e) #reflect on edge 1,2,3
    case @type
    when 0
      ret=reflEucl(e)
    when -1
      ret=reflHyp(e)
      ret.updateCenter()
    else
      ret=reflSpher(e)
    end
    ret.parent = self
    return ret
  end
  
  def reflEucl(e)
    #compute nec values
    case e
    when 1
      new = @e1.reflPoint(@p3)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(0,@p1,@p2,new)
      newT.e1 = @e1
      newT.e2 = @e1.reflEdge(@e2)
      newT.e3 = @e1.reflEdge(@e3)
    when 2
      new = @e2.reflPoint(@p1)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(0,new,@p2,@p3)
      newT.e1 = @e2.reflEdge(@e1)
      newT.e2 = @e2
      newT.e3 = @e2.reflEdge(@e3)
    else
      new = @e3.reflPoint(@p2)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(0,@p1,new,@p3)
      newT.e1 = @e3.reflEdge(@e1)
      newT.e2 = @e3.reflEdge(@e2)
      newT.e3 = @e3
    end
    
    newT.setAngles(@w1,@w2,@w3)
    newT.level = @level + 1
    
    return newT
  end
  
  def reflHyp(e)
    #compute nec values
    case e
    when 1
      new = @e1.reflPoint(@p3)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(-1,@p1,@p2,new)
      newT.e1 = @e1
      newT.e2 = @e1.reflEdge(@e2)
      newT.e3 = @e1.reflEdge(@e3)
    when 2
      new = @e2.reflPoint(@p1)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(-1,new,@p2,@p3)
      newT.e1 = @e2.reflEdge(@e1)
      newT.e2 = @e2
      newT.e3 = @e2.reflEdge(@e3)
    else
      new = @e3.reflPoint(@p2)
      if new.norm() < @ep
        new *= 0
      end
      newT = Triangle.new(-1,@p1,new,@p3)
      newT.e1 = @e3.reflEdge(@e1)
      newT.e2 = @e3.reflEdge(@e2)
      newT.e3 = @e3
    end
    
    newT.setAngles(@w1,@w2,@w3)
    newT.level = @level + 1
    
    return newT
  end
  
  def reflSpher(e)
    return self
  end
  
  def reflPointOnLine(a,b,c) #line through a,b...refl c
    line = b - a
    hypo = c - a
    ortho = a + ( ( line.inner_product(hypo) ) / ( line.inner_product(line) ) ) * line
    new = 2 * ortho - c
    if new.norm() < @ep
      new *= 0
    end
    return new
  end
  def checkLVL(i)
  
  end
  
  def print
    puts "this Triangle:"
    puts @p1
    puts @p2
    puts @p3
    puts "end"
  end
end
