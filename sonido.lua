
local sonido={sun={"/sonidos/bala1.mp3","/sonidos/bala2.mp3","/sonidos/bala3.mp3"},
        mina={"/sonidos/mina.wav"},
        imp={"/sonidos/impact.mp3"},
        dead={"/sonidos/dead1.mp3","/sonidos/dead2.mp3"}}

function sonido.play(s)
    local source = love.audio.newSource( s, "static" )
    love.audio.play(source)
end 
return sonido