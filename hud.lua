hud={imagen_vida="",vida}
qy=math.floor(vi*45)+1   
  quad_v = love.graphics.newQuad( 1, qy, 197, 45, 197, 450)
  barra = love.graphics.newImage("barra_v.png")  

  love.graphics.draw( barra,quad_v,1,1 )