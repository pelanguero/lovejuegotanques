pantallaActual=1;
pantallas={}
for i=1,2 do 
pantallas[i]=0;
end

love.load()

end

love.update(dt)
if pantallaActual==1 then
    --eventos de mouse para elegir la opcion en el menu
end
if pantallaActual==2 then
    --eventos de teclado para el juego en si
    
end
end

love.draw()
pantallas[pantallaActual].dibujarCapas()
end
