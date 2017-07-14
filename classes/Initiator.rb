require_relative 'Triangle'
require_relative 'Values'

def initEucl(a,b,c)
  set = [a,b,c]
  set.sort!
  
	w1 = Math::PI  / set[0];
	w2 = Math::PI / set[1];
  w3 = Math::PI / set[2];
	
  if set[0] == 2
    x = 0
    y=Math::tan(w2)
  else
    x = (Math::tan(w2)) / (Math::tan(w1)+Math::tan(w2))
    y = (Math::tan(w2)*Math::tan(w1)) / (Math::tan(w1)+Math::tan(w2))
  end
  
  t = Triangle.new(0,Vector[0,0],Vector[1,0],Vector[x,y])
  t.e1 = Edge.new(0,Vector[0,0],Vector[1,0])
  t.e2 = Edge.new(0,Vector[1,0],Vector[x,y])
  t.e3 = Edge.new(0,Vector[x,y],Vector[0,0])
  t.setAngles(a,b,c)
  t.level = 0
  return t
end

def initHyp(a,b,c)
  set = [a,b,c]
  set.sort!
  
  w1 = Math::PI  / set[0];
	w2 = Math::PI / set[1];
  w3 = Math::PI / set[2];
  
  scale = $scale
  
  if set[0] == 2 #put right angle in middle
    rsq = 1.0 / ( Math::cos(w2)**2 + Math::cos(w3)**2 - 1 )
    r = Math::sqrt(rsq)
    
    d = Vector[ r * Math::cos(w3), r * Math::cos(w2)]
    
    b = d[0] - r * Math::sqrt(1 - Math::cos(w2)**2)
    c = d[1] - r * Math::sqrt(1 - Math::cos(w3)**2)
    
    stop = Math::PI + Math::acos( ( d[0] - b ) / r )
    start = Math::PI + Math::asin( ( d[1] - c ) / r )
    
    b *= scale
    c *= scale
    
    t = Triangle.new(-1,Vector[0,0],Vector[b,0],Vector[0,c])
    
    t.e1 = Edge.new(-1,Vector[0,0],Vector[b,0])
    t.e3 = Edge.new(-1,Vector[0,c],Vector[0,0])
    
    r *= scale
    d = scale*d
    t.e2 = Edge.new(-1,d,r,true)
    t.e2.setSS(start,stop)
  else #no right angle
    #length on x axis
    tmpCalc = ( Math::cos(Math::PI/set[2]) + Math::cos(Math::PI/set[0])*Math::cos(Math::PI/set[1]) ) / ( Math::sin(Math::PI/set[0])*Math::sin(Math::PI/set[1]) )
    c = Math::sqrt( ( tmpCalc - 1 ) / ( tmpCalc + 1 ) )
    #unit vector in right direction for e3 (b in skizze)
    unitB = Vector[Math::cos(Math::PI/set[0]),Math::sin(Math::PI/set[0])]
    tmpCalc = ( Math::cos(Math::PI/set[1]) + Math::cos(Math::PI/set[0])*Math::cos(Math::PI/set[2]) ) / ( Math::sin(Math::PI/set[0])*Math::sin(Math::PI/set[2]) )
    bLength = Math::sqrt( ( tmpCalc - 1 ) / ( tmpCalc + 1 ) )
    
    newB = bLength*unitB
    
    #compute last edge
    #d1 = (1+c*c)/(2*c)
    #r = Math::sqrt( ( (1+newB[0]**2+newB[1]**2-newB[0]*((1+c*c)/c))/(2*newB[1]) + ((1-c*c)/(2*c))**2 ).abs )
    #d2 = Math::sqrt( ( r**r - ()**2 ).abs )
    d1 = (1+c*c)/(2*c)
    tmpC = Vector[c,0]
    d2 = ( (newB.norm()**2 - tmpC.norm()**2)/(2) - ((c**2+1)*(newB[0]-tmpC[0]))/(2*c) ) / (newB - tmpC)[1]
    newCenter = Vector[d1,d2]
    r = Math::sqrt( newCenter.norm()**2 - 1 )
    
    r *= scale
    d = scale * newCenter
    
    c *= scale
    newB = scale*newB
    
    t = Triangle.new(-1,Vector[0,0],Vector[c,0],newB)
    puts newB
    t.e1 = Edge.new(-1,Vector[0,0],Vector[c,0])
    t.e2 = Edge.new(-1,d,r,true)
    t.e3 = Edge.new(-1,newB,Vector[0,0])
    
    #start
    lol = newB - d
    startComplex = Complex(lol[0],lol[1])
    #stop
    lol2 = Vector[c,0] - d
    stopComplex = Complex(lol2[0],lol2[1])
    
    t.e2.setSS(startComplex.arg(),stopComplex.arg())
  end
  
  
  t.setAngles(a,b,c)
  t.level = 0
  return t
end

def initSpher

end
