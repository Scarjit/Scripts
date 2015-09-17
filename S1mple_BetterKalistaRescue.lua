version = "1.0"
myHero = GetMyHero()
if myHero.charName ~= 'Kalista' then return end
team = "blue"

function p(arg)
	print("<font color=\"#570BB2\">"..arg.."</font>")
end

function IniMenu()
	Config = scriptConfig("Better Rescue", "s1mple_betterkalistarescue")
	Config:addParam("active", "Activated", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("caminhealth", "Rescue Ally's below this Health (%)", SCRIPT_PARAM_SLICE, 6, 1, 100, 1)
	
	--subDisplay
	Config:addSubMenu("Display Settings", "subDisplay")
	Config.subDisplay:addParam("cstate", "Display Rescue State", SCRIPT_PARAM_ONOFF, true)
	Config.subDisplay:addParam("cstats", "Display Ally Stats", SCRIPT_PARAM_ONOFF, true)
	Config.subDisplay:addParam("cdebug", "Display Debug Stats", SCRIPT_PARAM_ONOFF, false)
	--subRandom
	Config:addSubMenu("Random Stuff", "subRand")
	Config.subRand:addParam("cdebugcolorfade", "Debug color fade", SCRIPT_PARAM_ONOFF, false)
	
end

function OnLoad()
	print("<font color=\"#570BB2\">S1mple_BetterKalistaRescue Version:</font> "..version.." <font color=\"#570BB2\">loading</font>")
	IniMenu()
	if myHero.team == 100 then
		team = "blue"
	else
		team = "red"
	end
	p("S1mple_BetterKalistaRescue loaded")
end

--Bot Base 400, 400, 182.21 (team == 100)
--Top Base 14300,14300,171.9 (team ~= 100)

red = ARGB(255, 255,0,0)
green = ARGB(255,9,255,0)
Spell = myHero:GetSpellData(SPELL_4)
b_spellup = false
b_rsc = true
b_isinner = false
b_isouter = false
b_aisinner = false
b_aisouter = false
b_isbound = false
i_allyhealth = 0
i_allymaxhealth = 0
i_allyhealthpercentage = 0
fader = 255
fadeg = 0
fadeb = 0
ally = nil

function OnTick()
if Config.active == false then return end
	if b_isbound == false then
		for i=0,heroManager.iCount,1 do
			for i2=0,heroManager:getHero(i).buffCount,1 do
				buff = heroManager:getHero(i):getBuff(i2)
				if buff.name ~= nil and buff.valid == true and buff.name == "kalistacoopstrikeally" then
					b_isbound = true
					ally = heroManager:getHero(i)
					p("Found ally: "..ally.name)
					i_allyhealth = math.round(ally.health)
					i_allymaxhealth = math.round(ally.maxHealth)	
				end
			end
		end
	end
	
	if ally ~= nil then
		i_allyhealth = math.round(ally.health)
		i_allymaxhealth = math.round(ally.maxHealth)
		i_allyhealthpercentage =  math.round(i_allyhealth/i_allymaxhealth*100)
		Xa = ally.x
		Za = ally.z
		Xy = myHero.x
		Zy = myHero.z
		Rinner = 800
		Router = 1800
		minner = Rinner^2
		mouter = Router^2
	
		if team == "blue" then
			X = 400 --Only Valid for Bot team
			Z = 400 --Only Valid for Bot team
		else
			X = 14350 --Only Valid for Bot team
			Z = 14350 --Only Valid for Bot team
		end
		n = ((X-Xy)^2)+((Z-Zy)^2)
		na = ((X-Xa)^2)+((Z-Za)^2)
		--Own stuff
		if n <= minner then
			b_isinner = true
		else
			b_isinner = false
		end
		
		if n <= mouter then
			b_isouter = true
		else
			b_isouter = false
		end
		
		--Ally Stuff
		if na <= minner then
			b_aisinner = true
		else
			b_aisinner = false
		end
		
		if na <= mouter then
			b_aisouter = true
		else
			b_aisouter = false
		end
		
		if b_aisinner == true then
			b_rsc = false
		else
			b_rsc = true
		end
		
		if myHero:CanUseSpell(SPELL_4) == 0 then
			b_spellup = true
		else
			b_spellup = false
		end
		
		if b_spellup == true then
			if b_rsc == true then
				if i_allyhealthpercentage <= Config.caminhealth then
					CastSpell(SPELL_4)
					p("Saving "..ally.name)
				end
			end
		end
	end
end



function OnDraw()
if Config.active == false then return end
	if Config.subDisplay.cstate == true then
		if b_rsc == true and b_isbound == true then
				DrawText("Ally rescue ALLOWED", 25, 850, 10, green)
		elseif b_isbound == true then
				DrawText("Ally rescue FORBIDDEN", 25, 850, 10, red)
		end
	end
	
	if b_isbound == true then
		if Config.subDisplay.cstats == true then
			DrawText("Ally Health:        "..i_allyhealth,18,850,40,green)
			DrawText("Ally Maxhealth: "..i_allymaxhealth,18,850,60,green)
			DrawText("Ally healthpercentage: "..i_allyhealthpercentage.."%",18,850,80,green)
			DrawText("Force Rescue at: "..Config.caminhealth.."%",18,850,100,green)
		end
	end
	
	if Config.subDisplay.cdebug == true and Config.subRand.cdebugcolorfade == false then
		DrawText("X: "..math.round(myHero.x), 18, 100, 140, red)
		DrawText("Y: "..math.round(myHero.y), 18, 100, 160, red)
		DrawText("Z: "..math.round(myHero.z), 18, 100, 180, red)
		DrawText("Spellstate: "..myHero:CanUseSpell(SPELL_4),18,100,200,red) -- 0 = ready and in range | 8 = ready out of range
	end
		if Config.subDisplay.cdebug == true and Config.subRand.cdebugcolorfade == true then
		DrawText("X: "..math.round(myHero.x), 18, 100, 140, ARGB(255, fader,fadeg,fadeb))
		DrawText("Y: "..math.round(myHero.y), 18, 100, 160, ARGB(255, fader,fadeg,fadeb))
		DrawText("Z: "..math.round(myHero.z), 18, 100, 180, ARGB(255, fader,fadeg,fadeb))
		DrawText("Spellstate: "..myHero:CanUseSpell(SPELL_4),18,100,200, ARGB(255, fader,fadeg,fadeb)) -- 0 = ready and in range | 8 = ready out of range
		if(fader >= 0 and fadeb == 0) then
			fader = fader - 1
			fadeg = fadeg + 1
		end
		if(fadeg >= 0 and fader == 0) then
			fadeg = fadeg - 1
			fadeb = fadeb + 1
		end
		if(fadeb >= 0 and fadeg == 0)then
			fadeb = fadeb - 1
			fader = fader + 1
		end
	end
end


--(X-X1)^2+(Z-Z1)^2 <= R^2 if in range