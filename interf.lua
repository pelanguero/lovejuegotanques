interf={elementos={},even=3,ini={jugadores =1,modo=2,numMuertes=20,capturas= 3,rondas=1,time=120}} 
local font = love.graphics.newFont( "arial_/arial_narrow_7.ttf",20 )
local color ={244/255,208/255,63/255}   
function cajas(ele,ref) 
            
    local t = love.graphics.newText( font, ele.txt)
    local w, h = t:getDimensions()

    local p = love.graphics.newText( font, ref)            
            love.graphics.rectangle("line",(ele.x-2)+w*1.1+10,ele.y-2,40,h)
            love.graphics.draw(p,(ele.x-2)+w*1.1+12,ele.y,0,ele.escalax,ele.escalay)
end 

function dibujarText(ele)   
        --local font = love.graphics.getFont()              
        local t = love.graphics.newText( font, ele.txt)     
        local w, h = t:getDimensions()
        love.graphics.draw(t,ele.x,ele.y,0,1,1) 

        if ele.tipo == 1 then
           -- love.graphics.rectangle("line",ele.x-2,ele.y,w*1.1,h*1.6)
        end 
        if ele.tipo == 2 then
            cajas(ele,interf.ini.jugadores)             
        end 
        if ele.tipo == 3 then
            cajas(ele,interf.ini.numMuertes)                    
        end 
        if ele.tipo == 4 then
            cajas(ele,interf.ini.modo) 
            
        end
        if ele.tipo == 5 then
            cajas(ele,interf.ini.capturas)             
        end 
        if ele.tipo == 6 then
            cajas(ele,interf.ini.rondas)             
        end
        if ele.tipo == 7 then
            cajas(ele,interf.ini.time)             
        end
        if ele.tipo == 8 then 
            love.graphics.rectangle("line",ele.x-4,ele.y-4,w*1.2,h*1.1)
        end
        if ele.tipo == 10 then 
            love.graphics.rectangle("line",ele.x-4,ele.y-4,w*1.2,h*1.1)
        end 
            
    
end 
function addElement(tipo,x,y,val,seg,id,ty,tp)
    --interf.addUIElement(x,y,tipo,frase,escalax,escalay,tx,ty,transp,id,tColorT,tColorF,im,seg)
              
        local t = love.graphics.newText( font, val)     
        local w, h = t:getDimensions()
    if tp == 1 then 
        interf.addUIElement(x,y,tipo,val,1,1,1,1,0.23,id,1,1,1,seg)
    end 
    if tp == 2 then         
        interf.addUIElement(x,y,tipo,val,1,1,1,1,0.23,0,1,1,1,1)
        interf.addUIElement(w+200,y,8," + ",1,1,1,ty,0.23,8,1,1,1,1)
        interf.addUIElement(w+230,y,8," - ",1,1,1,ty,0.23,9,1,1,1,1)
    end 

end 
    
function event(x,y,ele)
             
            t = love.graphics.newText( font, ele.txt)
            w, h = t:getDimensions()         
            if x > ele.x and x < ele.x+w*1.1 and y > ele.y and y < ele.y+h*1.1 then
                color ={244/255,208/255,63/255}
                if ele.id == 2 then
                interf.even = ele.seg 
                end
                if ele.id == 4 then                    
                    if interf.ini.jugadores < 4 then 
                    interf.ini.jugadores =interf.ini.jugadores +1
                    end 
                end
                if ele.id == 5 then
                    if interf.ini.jugadores > 1 then 
                    interf.ini.jugadores =interf.ini.jugadores -1
                    end 
                end 
                if ele.id == 7 then
                    interf.ini.modo = ele.seg
                end
                -----Opciones modo
                if ele.id == 8 then
                    if interf.ini.modo == 1 then                        
                        if  interf.ini.numMuertes < 100 then 
                            interf.ini.numMuertes = interf.ini.numMuertes + 5 
                        end 
                    end
                    if interf.ini.modo == 2 then
                        if ele.ty == 5 then
                            if  interf.ini.capturas < 6 then 
                                interf.ini.capturas = interf.ini.capturas + 1 
                            end                            
                        end 
                        if ele.ty == 4 then
                            if  interf.ini.rondas < 3 then 
                                interf.ini.rondas = interf.ini.rondas + 1 
                            end
                            
                        end                                
                
                    end
                    if interf.ini.modo == 3 or interf.ini.modo == 4 then
                        if ele.ty == 5 then
                            if  interf.ini.time < 600 then 
                                interf.ini.time = interf.ini.time + 25 
                            end                            
                        end 
                        if ele.ty == 4 then
                            if  interf.ini.rondas < 3 then 
                                interf.ini.rondas = interf.ini.rondas + 1 
                            end
                            
                        end                                
                
                    end   
                end 
                if ele.id == 9 then 
                    if interf.ini.modo == 1 then
                        if  interf.ini.numMuertes > 20 then 
                            interf.ini.numMuertes = interf.ini.numMuertes - 5 
                        end 
                    end
                    if interf.ini.modo == 2 then
                        if ele.ty == 5 then
                            if  interf.ini.capturas > 3 then 
                                interf.ini.capturas = interf.ini.capturas - 1 
                            end
                        end    
                       
                        if ele.ty == 4 then
                            if  interf.ini.rondas > 1 then 
                                interf.ini.rondas = interf.ini.rondas - 1 
                            end                            
                        end                               
                
                    end
                    if interf.ini.modo == 3 or interf.ini.modo == 4 then
                        if ele.ty == 5 then
                            if  interf.ini.time > 120 then 
                                interf.ini.time = interf.ini.time - 25 
                            end                            
                        end 
                        if ele.ty == 4 then
                            if  interf.ini.rondas > 1 then 
                                interf.ini.rondas = interf.ini.rondas - 1 
                            end 
                            
                        end                                
                
                    end
                end
                if ele.id == 10 then
                    interf.even = 4
                end 
                ----------
            end         
end   

function interf.addUIElement(x,y,tipo,frase,escalax,escalay,tx,ty,transp,id,tColorT,tColorF,im,seg)    
    local ele={} 
    ele.id=id    
    ele.x=x
    ele.y=y
    ele.tipo=tipo
    ele.txt=frase
    ele.escalax=escalax
    ele.escalay=escalay
    ele.tcolor=color    
    ele.tColorT=tColorT
    ele.tx=tx
    ele.ty=ty
    ele.transp=transp
    ele.im=im
    ele.seg=seg
    
    table.insert(interf.elementos,ele)  
end
function validar()
    interf.elementos = nil
    interf.elementos = {}
    if interf.even == 1 then        
        pagina1()
    end
    if interf.even == 2 then
        pagina2()
    end
    if interf.even == 3 then
        pagina3()
    end

end

function interf.dibijarElementos()    
    validar()
     for i=1,#interf.elementos,1 do       
            dibujarText(interf.elementos[i])                     
    end 
    love.graphics.print(interf.even) 
end

function interf.mousehandler(x, y, button)
       if button == 1 then
          for i =1,#interf.elementos,1 do
                event(x,y,interf.elementos[i]) 
          end
       end        
end 

function pagina1()
        
        addElement(1,100,100,"Jugar",2,2,1,1)
        --addElement(1,100,200,"Personalizar",1,3,1,1)
        addElement(1,100,300,"Salir",1,2,1,1)
        love.graphics.setBackgroundColor(46/255,64/255,83/255)        
end 
function pagina3()
        
    
    addElement(10,100,100,"Seguir jugando",2,10,1,1)
    --addElement(10,100,200,"Configuraciones",1,3,1,1)
    addElement(10,100,300,"Salir pantalla inicio",1,2,1,1)        
end 
function pagina2() 
   -- addElement(tipo,x,y,val,seg,id,ty,tp)
        addElement(1,100,100,"Modo de juego: ",1,0,1,1)     
        addElement(10,160,130,"Team Slayer",1,7,1,1)     
        addElement(10,160,160,"Capture The Flag",2,7,1,1)     
        addElement(10,160,190,"King Of The Hill",3,7,1,1)     
        addElement(10,160,220,"Crazy Ball",4,7,1,1)                
              
        interf.addUIElement(100,260,2,"Jugadores: ",1,1,1,1,0.23,0,1,1,1,2)
        interf.addUIElement(270,260,8," + ",1,1,1,1,0.23,4,1,1,1,1)
        interf.addUIElement(300,260,8," - ",1,1,1,1,0.23,5,1,1,1,1)

        interf.addUIElement(100,290,4,"Modo de juego:",1,1,1,1,0.23,0,1,1,1,1)

        if interf.ini.modo ==1 then
            addElement(3,100,320,"Numero de muertes:",1,1,1,2)
        end  
        if interf.ini.modo ==2 then
            addElement(6,100,320,"Rondas: ",2,1,4,2)
            addElement(5,100,350,"Capturas: ",2,1,5,2)
        end 
        if interf.ini.modo ==3 then 
            addElement(7,100,320,"tiempo: ",2,1,5,2)
            addElement(6,100,350,"Rondas: ",2,1,4,2)
        end 
        if interf.ini.modo ==4 then
            addElement(7,100,320,"tiempo: ",2,1,5,2)
            addElement(6,100,350,"Rondas: ",2,1,4,2)
        end 

        addElement(1,100,390,"Jugar",2,10,1,1)
        
        interf.addUIElement(100,420,1,"Salir",1,1,1,1,0.23,2,1,1,1,1)        

        
end 
 

 


return interf