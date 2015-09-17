
function p(arg)
	print("<font color=\"#570BB2\">"..arg.."</font>")
end

function OnLoad()
	P("S1mple_Test.lua loading")
	
	
	p("S1mple_Test.lua loaded")
end

b_isbound = false
ally = nil

function OnTick()

if b_isbound == false then
		for i=0,heroManager.iCount,1 do
			for i2=0,heroManager:getHero(i).buffCount,1 do
				buff = heroManager:getHero(i):getBuff(i2)
				if buff.name ~= nil and buff.valid == true then
					if(buff.name == "kalistacoopstrikeally")then
						b_isbound = true
						ally = heroManager:getHero(i)
						p("Found ally: "..heroManager:getHero(i).name)
						i_allyhealth = math.round(ally.health)
						i_allymaxhealth = math.round(ally.maxHealth)
					end
				end
			end
		end
	end
	
end

function OnDraw()

end