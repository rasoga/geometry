require 'matrix'
require 'complex'

require_relative 'Values'

class Edge
  attr_accessor :p,:q,:t,:c, :start, :stop
  
  def initialize(t,a,b,c=false) # a,b punkte oder center,radius, c=circle(yes/N0)
    @t = t
    @c = c
    
    @ep = $ep #0.0005
    
    if a[0].abs < @ep #possible fix
      a = Vector[0,a[1]]
    end
    if a[1].abs < @ep
      a = Vector[a[0],0]
    end
    if @t == 0 #only in eucl case both are points !!!!!!!!!!!!!!!!!! wirklich wichtig das hier...
      if b[0].abs < @ep
        b = Vector[0,b[1]]
      end
      if b[1].abs < @ep
        b = Vector[b[0],0]
      end
    end
    @p = a
    @q = b
    
    @start = 10000
    @stop = 10000
  end
  
  def setSS(start,stop)
    #fix values, since angles always positiv...check for order so that dist < PI
    small = [start,stop].min
    big = [start,stop].max
    if (start -stop ).abs > Math::PI
      @start = big - 2 * Math::PI
      @stop = small
    else
      @start = small
      @stop = big
    end
  end
  
  def reflPoint(d)
    if @c
      if ( d - @p ).norm() < @ep
        new = Float::INFINITY
      else
        new = @p + ( @q / (d-@p).magnitude )**2 * (d - @p)
        if new.norm() < @ep
          new = Vector[0,0]
        end
      end
    else #FUCK IT sometimes p=q?
      line = @q - @p
      hypo = d - @p
      ortho = @p + ( ( line.inner_product(hypo) ) / ( line.inner_product(line) ) ) * line
      new = 2 * ortho - d
      if new.norm() < @ep
        new = Vector[0,0]
      end
    end
    if new != Float::INFINITY
      if (new - d).norm() < @ep #rechnerungenauigkeit
        return d
      end
    end
    return new
  end
  
  # perhaps checked for shit
  def vertices
    return [@p,@q]
  end
  
  def lineGetSamePoint(l1,l2)
    if (l1[0]-l2[0]).norm() < @ep or (l1[0]-l2[1]).norm() < @ep
    #if l1[0] == l2[0] or l1[0] == l2[1]
      return l1[0]
    else
      return l1[1]
    end
  end
  
  def getOther(li,po) #get other point on li which is not po
    if (li[0] - po).norm() < @ep
    #if li[0] == po
      return li[1]
    else
      return li[0]
    end
  end
  
  def reflEdge(e) 
    begin
    if @c #check if this is a circle or not
      if e.c #other is a circle
        #newP = reflPoint(e.p) DO NOT REFLECT CENTER
        tmpA = e.p + e.q * (e.p-@p).normalize #one point
        tmpB = e.p - e.q * (e.p-@p).normalize #second point on line
        newA = reflPoint(tmpA)
        newB = reflPoint(tmpB)
        #if circles crosses self.center
        if newA == Float::INFINITY or newB == Float::INFINITY
          #unclear if orientation is right
          newP = reflPoint(PtonCircle(e.p,e.q,e.start))
          newQ = reflPoint(PtonCircle(e.p,e.q,e.stop))
          
          newE = Edge.new(@t,newP,newQ)
          return newE
        end
        newP = 0.5 * (newA + newB)
        newQ = (newP - newA).magnitude
        
        newStopPt = reflPoint(PtonCircle(e.p,e.q,e.stop))
        newStartPt = reflPoint(PtonCircle(e.p,e.q,e.start))
        
        newE = Edge.new(@t,newP,newQ,true)
        
        newE.setSS(AnglefromPt(newStopPt,newP),AnglefromPt(newStartPt,newP))
        return newE
      else #this is circle other is line
        #check if line goes through origin of this circle
        if ( ((e.q[1] - e.p[1])*(@p[0] - e.q[0])) - ((@p[1] - e.q[1])*(e.q[0] - e.p[0])) ).abs < @ep #lass ruhig mal das abs weg .... weird shit :D
          newP = reflPoint(e.p)
          newQ = reflPoint(e.q)
          return Edge.new(-1,newQ,newP)
        else #not colinear
          newP = reflPoint(e.p) 
          newQ = reflPoint(e.q)
          #new circle should pass through origin
          newCenter = Ptfrom3(newP,newQ,@p)
          newRad = (newP - newCenter).magnitude
          newE = Edge.new(-1,newCenter,newRad,true)
          newStart = AnglefromPt(newP,newCenter)
          newStop = AnglefromPt(newQ,newCenter)
          newE.setSS(newStart,newStop)
          return newE
        end
      end
    else #this is a line
      if e.c #other is a circle
        newp = reflPoint(e.p)
        newE = Edge.new(@t,newp,e.q,true)
        newStopPt = reflPoint(PtonCircle(e.p,e.q,e.stop))
        newStartPt = reflPoint(PtonCircle(e.p,e.q,e.start))
        newE.setSS(AnglefromPt(newStopPt,newp),AnglefromPt(newStartPt,newp))
        return newE
      else #other is also a line !!!!!! RUBYS ARRAY INTERSECTIONS DOES NOT WORK
        inters = lineGetSamePoint(vertices,e.vertices)
        if inters == @p
          other = getOther(e.vertices,@p)
          re = reflPoint(other)
          newE = Edge.new(@t,re,@p)
        else
          other = getOther(e.vertices,@q)
          re = reflPoint(other)
          newE = Edge.new(@t,@q,re)
        end
        return newE
      end
    end
    rescue => e
      puts "Error during processing: #{$!}"
      puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    end
  end
  
  def Ptfrom3(a,b,d) #definetely works
      ncenter = Vector[0,0]
      left = 0.5 * (a-d)
      r1 = b-a
      r2 = b-d
      turn = Matrix[[0,-1.0],[1.0,0]]
      nr1 = turn*r1
      nr2 = turn*r2
      builder = [nr2,(-1)*nr1]
      #now solve left = (nr2  -nr1)(s  t)
      solverMat = Matrix.build(2,2){|row,col| builder[col][row]}
      invMat = solverMat.inverse
      solution = invMat * left
      ncenter = 0.5 * (a+b) + solution[1]*nr1
      return ncenter
  end
  
  def PtonCircle(center, radius, angle)
    newX = center[0] + radius * Math::cos(angle)
    newY = center[1] + radius * Math::sin(angle)
    if newX.abs < @ep
      newX = 0.0
    end
    if newY.abs < @ep
      newY = 0.0
    end
    return Vector[newX,newY]
  end
  
  def AnglefromPt(point,center)
    shift = point - center
    inC = Complex(shift[0],shift[1])
    #always return positive
    if inC.arg() < 0.0
      return inC.arg() + 2 * Math::PI
    else
      return inC.arg()
    end
  end
end
