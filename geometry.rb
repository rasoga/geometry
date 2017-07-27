require 'sinatra'
require "matrix"

require_relative 'classes/TriMaster'
require_relative 'tim/schottky'
require_relative 'tim/closed_surface'
require_relative 'tim/fdplot'

get '/' do
  erb :index
end

get '/triangulation' do
  @winkel = [2,3,6]
  @itteration = 10
  
  erb :triangulation
end

post '/triangulation' do
  @winkel = [params[:w1].to_i,params[:w2].to_i,params[:w3].to_i]
  @itteration = params[:itt].to_i
  
  @tri = TriMaster.new(@winkel[0],@winkel[1],@winkel[2])
  
  unless @tri.type == 1
    for i in 1..@itteration do
      @tri.reflect()
    end
  end
  
 # puts "PARAMS"
 # params.each do |p,q|
 #   puts p.to_s + " und "+q.to_s
 # end
  
  if @tri.type == 0 #coloring and stuff only in euclidian case
    @col = ["rgb(255,255,255)"]
    if params[:col] == "rand"
      #foreach triangle a color
      @tri.list.each do |a|
        strr = "rgb("+rand(255).to_s+","+rand(255).to_s+","+rand(255).to_s+")"
        @col.push(strr)
      end
    end
    if params[:col] == "bwrainbow"
      #foreach triangle a color determined by level
      rainbow = []
      for i in 0..10 do
        rainbow.push([25*i,25*i,25*i])
      end
      #fill with colors
      @tri.list.each do |a|
        alvl = a.level.to_i
        strr = "rgb("+rainbow[alvl%rainbow.length][0].to_s+","+rainbow[alvl%rainbow.length][1].to_s+","+rainbow[alvl%rainbow.length][2].to_s+")"
        @col.push(strr)
      end
    end
    if params[:col] == "rainbow"
      #foreach triangle a color determined by level
      rainbow = []
      step = ( 360.0 / ( @itteration + 1 ) ).to_i
      for i in 0..@itteration do
        rainbow.push(HsvToRgb(i*step,0.9,0.9))
      end
      #fill with colors
      @tri.list.each do |a|
        alvl = a.level.to_i
        strr = "rgb("+rainbow[alvl%rainbow.length][0].to_s+","+rainbow[alvl%rainbow.length][1].to_s+","+rainbow[alvl%rainbow.length][2].to_s+")"
        @col.push(strr)
      end
    end
    
    @maxNorm = 1
    
    #find maximal sup-norm
    @tri.list.each do |t|
      @maxNorm = t.p1[0].abs if t.p1[0].abs >= @maxNorm
      @maxNorm = t.p1[1].abs if t.p1[1].abs >= @maxNorm
      @maxNorm = t.p2[0].abs if t.p2[0].abs >= @maxNorm
      @maxNorm = t.p2[1].abs if t.p2[1].abs >= @maxNorm
      @maxNorm = t.p3[0].abs if t.p3[0].abs >= @maxNorm
      @maxNorm = t.p3[1].abs if t.p3[1].abs >= @maxNorm
    end
  end
  
  if @tri.type == 1
    
  end
  
  erb :triangulation
end

get '/schottky' do
  @itteration = 2
  @generators = 2

  erb :schottky
end

post '/schottky' do
  @itteration = params[:itt].to_i
  @generators = params[:gen].to_i
  
  if params[:kind] == "schottky"
    @kind = Schottky.generate_transformations(@generators)
  elsif params[:kind] == "closed"
    @kind = ClosedSurface.generate_transformations(@generators)
  else
    @kind = nil
  end
  
  if @kind    
    @plot = FDPlot.new(0.0,@kind,@itteration,false)
    
    @plot.plot.to_svg("public/blubber.svg", size: [700,700])
    
    theSVG = File.open("public/blubber.svg")
    @theSVG = theSVG.read
    theSVG.close
  end
  
  erb :schottky
end

# Helper functions

def HsvToRgb(h,s,v) #nach wikipedia
  hj = (h/60.0).floor
  f = (h/60.0) - hj
  p = v * ( 1 - s )
  q = v * ( 1 - s * f )
  t = v * ( 1 - s * ( 1 - f ) )
  case hj
    when 0 
      nrgb=[v,t,p]
    when 1 
      nrgb=[q,v,p]
    when 2 
      nrgb=[p,v,t]
    when 3 
      nrgb=[p,q,v]
    when 4 
      nrgb=[t,p,v]
    when 5 
      nrgb=[v,p,q]
    when 6 
      nrgb=[v,t,p]
  end
  return [(nrgb[0]*255).to_i,(nrgb[1]*255).to_i,(nrgb[2]*255).to_i]
end
