local autoupdate = false --Set to "true" for autoupdate
local version = "1.5"
local Update_HOST = "raw.github.com"
local Update_PATH = "/Scarjit/Scripts/master/S1mple_Ziggs.lua?rand="..math.random(1,10000)
local Update_FILE_PATH = "S1mple_Ziggs.lua"
local Update_URL = "https://"..Update_HOST..Update_PATH


myHero = GetMyHero()
if myHero.charName ~= 'Ziggs' then return end
	
require "VPrediction"
	
--BEGINN INI VARS
	ts = nil
	c_red = ARGB(255, 255,0,0)
	c_green = ARGB(255,9,255,0)
	c_blue = ARGB(255,51,51,255)
	ZiggsQ = { range = 850, width = 155, speed = 1750, delay = .25, collision=true }
	ZiggsW = { range = 1000, width = 225, speed = math.huge, delay = .25, collision=false }
	ZiggsE = { range = 900, width = 350, speed = 1750, delay = .12, collision=false }
	ZiggsR = { range = 5300, width = 600, speed = 1750, delay = 0.5, collision=false }
	VP = VPrediction()
	ts = TargetSelector(TARGET_LESS_CAST, 1500, DAMAGE_MAGIC, true)
	Config = scriptConfig("S1mple_Ziggs", "s1mple_ziggs")
	currentXN = 0
	currentYN = 0
	currentZN = 0
	
--END INI VARS

function p(arg)
	print("<font color=\"#570BB2\">"..arg.."</font>")
end	

function findorbwalker() --Thanks to http://forum.botoflegends.com/user/431842-orianna/ for this Simple solution
	if _G.Reborn_Loaded then
		SAC=true
	elseif not _G.Reborn_Loaded and FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		SxOrb=true
		require("SxOrbWalk")
		DelayAction(function() Config:addSubMenu("SxOrbWalk","orbWalk") end,5)
		DelayAction(function() _G.SxOrb:LoadToMenu(Config.orbWalk) end,5)
	elseif SAC~=true and SxOrb~= true then
		p("=================")
		p("=================")
		p("SxOrb or SAC:R is required.")
		p("=================")
		p("=================")
	end
end

function Update()
	if not autoupdate then return end
		p("Updating S1mple_Ziggs")
		local ServerData = GetWebResult(Update_HOST, "/Scarjit/Scripts/master/S1mple_Ziggs.version")
		if ServerData then
			ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
			if ServerVersion then
				if tonumber(version) < ServerVersion then
					p("Update found")
					p("Local Version: "..version" <==> ServerVersion: "..ServerVersion)
					p("Updating, don't press F9")
					DelayAction(function() DownloadFile(Update_URL, Update_FILE_PATH, function () p("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
				else
					p("No Update found")
				end
			end
		else
			p("Autoupdate failed")
		end
end	

function OnLoad()

	p("S1mple_Ziggs Version</font> "..version.." <font color=\"#570BB2\">loading</font>")
	findorbwalker()
	Update()
	--Config START
	Config:addParam("active", "Activated", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("hc", "Accuracy (Default: 2)", SCRIPT_PARAM_SLICE, 2, -1, 5, 1)
	Config:addParam("version", "Current Version", SCRIPT_PARAM_INFO, version)
	Config:addTS(ts)
	Config:addSubMenu("Draws", "draws")
	Config:addSubMenu("Keys", "keys")
	Config:addSubMenu("Humanizer", "human")
	Config.human:addParam("predictmove", "Predict's enemy Pos for Forceult", SCRIPT_PARAM_ONOFF, true)
	Config.human:addParam("delayflee", "Delay Double W in Fleemode", SCRIPT_PARAM_SLICE, 0, 0, 4, 1)
	Config.draws:addParam("drawq", "Draw Q",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("draww", "Draw W",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawe", "Draw E",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawr", "Draw R (lags alot)",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawrmini", "Draw R on Minimap",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawenemy", "Draw Selected Enemy", SCRIPT_PARAM_ONOFF, false)
	Config.draws:addParam("drawenemyult", "Draw Selected Enemy (Forceult)", SCRIPT_PARAM_ONOFF, false)
--	Config.draws:addParam("waypoints", "Draw Waypoints", SCRIPT_PARAM_ONOFF, false)
	Config.keys:addParam("combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.keys:addParam("harras", "Harras Key", SCRIPT_PARAM_ONKEYDOWN, false, 99)
	Config.keys:addParam("laneclear", "Lane Clear (Uses Q/E)", SCRIPT_PARAM_ONKEYDOWN, false, 118)
	Config.keys:addParam("lasthit", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, 120)
	Config.keys:addParam("flee", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, 103)
	Config.keys:addParam("forceult", "Forceult", SCRIPT_PARAM_ONKEYDOWN, false, 103)
	Config.keys:permaShow("combo")
	Config.keys:permaShow("harras")
	Config.keys:permaShow("laneclear")
	Config.keys:permaShow("lasthit")
	Config.keys:permaShow("flee")
	Config.keys:permaShow("forceult")
	--Config END
	flee_recasttime = os.time()
	waypoints_ctime = os.time()
	enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)
	Config.active = true
	p("S1mple_Ziggs loaded")
end
X = 0
Y = 0
Z = 0

function LongRangeTargetSelector()
	local enemyHeros = GetEnemyHeroes()
	local preftarget = nil
	for key,value in pairs(enemyHeros) do
		--(X-X1)^2+(Z-Z1)^2 <= R^2 if in range
		local X1 = value.x
		local Z1 = value.z
		local n = math.sqrt((X-X1)^2+(Z-Z1)^2)
		if preftarget == nil  then
			if value.visible == true and n <= 5300 and value.dead == false then
				preftarget = value
			end
		else
			if preftarget.health > value.health and value.visible == true and n <= 5300 and value.dead == false then
				preftarget = value
			end
		end
	end
	return preftarget
end

function OnTick()
if SAC~=true and SxOrb~= true and GetGameTimer() <= 100 and myHero.dead and not Config.active then return end
ts:update()
X = myHero.x
Y = myHero.y
Z = myHero.z

	if Config.keys.combo == true then
		if ts.target == nil then return end
		tname = string.upper(string.sub(ts.target.charName, 0, 3))
		if tname ~= "SRU" then
			CastQ(ts.target)
			CastW(ts.target)
			CastE(ts.target)
		end
	end
	if Config.keys.harras == true then
		if ts.target == nil then return end
		CastQ(ts.target)
		CastW(ts.target)
		CastE(ts.target)
	end
	
	if Config.keys.lasthit == true then return end
	
	if Config.keys.laneclear == true then
		enemyMinions:update()
		local prefminion = nil
		local prefminion_inrange = 0
		for key,value in pairs(enemyMinions.objects) do
			prefminion_inrange_N = 0
			local X1 = value.x
			local Z1 = value.z
			local n = math.sqrt((X-X1)^2+(Z-Z1)^2)
			if n >= 550 then return end
				for key2,value2 in pairs(enemyMinions.objects) do
					local X2 = value2.x
					local Z2 = value2.z
					local n2 = math.sqrt((X-X2)^2+(Z-Z2)^2)
					if n2 >= 225 then 
						prefminion_inrange_N = prefminion_inrange_N+1
					end
				end
			if prefminion == nil then
				prefminion = value
				prefminion_inrange = prefminion_inrange_N
			end
			if prefminion_inrange < prefminion_inrange_N then
				prefminion = value
				prefminion_inrange = prefminion_inrange_N
			end
			
		end
		CastE(prefminion)
		CastW(prefminion)
	end
	
	if Config.keys.flee == true then
		myHero:MoveTo(mousePos.x, mousePos.z)
		CastE(myHero)
		if os.time() < flee_recasttime then return end
		flee_recasttime = os.time() + Config.human.delayflee
		CastW(myHero)
	end
	
	if Config.keys.forceult == true then
		CastR()
	end
end

function OnDraw()
if Config.active == false then return end
	ts:update()
	if ts.target ~= nil then	
		DrawText("Normal Target: "..ts.target.charName, 18, 100, 140, c_red)
		--DrawText("ts.mode: "..ts.mode, 18, 100, 160, c_red)
		--DrawText("ts.range: "..ts.range, 18, 100, 180, c_red)
	end
		if LongRangeTargetSelector() ~= nil and myHero:CanUseSpell(SPELL_4) == READY then	
		DrawText("Ultimate Target: "..LongRangeTargetSelector().charName, 18, 100, 240, c_red)
	end
	
	if Config.draws.drawq == true and myHero:CanUseSpell(_Q) == 0 then
		DrawCircle3D(X,Y,Z,850,5,c_red) -- Ziggs Min Cast Range Q
		DrawCircle3D(X,Y,Z,1400,5,c_red) -- Ziggs Max Cast Range Q
	end
	if Config.draws.draww == true and myHero:CanUseSpell(_W) == 0 then
		DrawCircle3D(X,Y,Z,1000,5,c_blue) -- Ziggs W
	end
	if Config.draws.drawe == true and myHero:CanUseSpell(_E) == 0 then
		DrawCircle3D(X,Y,Z,900,5,c_blue)  -- Ziggs E
	end
	if Config.draws.drawr == true and myHero:CanUseSpell(_R) == 0 then
		DrawCircle3D(X,Y,Z,5300,5,c_green)  -- Ziggs R
	end
	if Config.draws.drawrmini == true then
		DrawCircleMinimap(X,Y,Z,5300,1,c_green)
	end
	if Config.draws.drawenemy == true then
		if ts.target == nil then return end
			DrawCircle3D(ts.target.x,ts.target.y,ts.target.z,100,5,c_blue)
			DrawCircle3D(ts.target.x,ts.target.y,ts.target.z,80,5,c_blue)
			DrawCircle3D(ts.target.x,ts.target.y,ts.target.z,60,5,c_blue)
			DrawCircle3D(ts.target.x,ts.target.y,ts.target.z,40,5,c_blue)
	end
	
	--DrawText("Current Time: "..os.time(),18,50,50,c_red)
end
function S1mplePredict(target)
	--The Waypoint's are Predicted based on Current Movement
	local currentX = target.x
	local currentY = target.y
	local currentZ = target.z
	if Config.draws.waypoints then
		DrawText(math.round(currentX).." : "..math.round(currentY).." : "..math.round(currentZ), 18,100,100,c_red)
	end
	if os.time() > waypoints_ctime  then
		waypoints_ctime = os.time() + 0.025
		currentXN = target.x
		currentYN = target.y
		currentZN = target.z
		local preX = (currentX-currentXN)+target.x
		local preY = (currentY-currentYN)+target.y
		local preZ = (currentZ-currentZN)+target.z
		if Config.draws.waypoints then
			DrawCircle3D(preX,preY,preZ, 40,5,c_red)
		end
		return preX, preZ
	end
	if Config.draws.waypoints then
		DrawText(math.round(currentXN).." : "..math.round(currentYN).." : "..math.round(currentZN), 18,100,120,c_red)
		DrawLine3D(currentX, currentY, currentZ, currentXN, currentYN, currentZN, 10, c_green)
	end
	return nil, nil
end

function CastQ(target)
	if target == nil then return end
	local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, ZiggsQ.delay, ZiggsQ.width, ZiggsQ.range, ZiggsQ.speed, myHero, true)
	if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < ZiggsQ.range then
		CastSpell(_Q,CastPosition.x, CastPosition.z)
	end
end

function CastW(target)
	if target == nil then return end
	local CastPosition, HitChance, Position = VP:GetCircularCastPosition(target, ZiggsW.delay, ZiggsW.width, ZiggsW.range, ZiggsW.speed, myHero, false)
	if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < ZiggsW.range then
		CastSpell(_W,CastPosition.x, CastPosition.z)
	end
end

function CastE(target)
	if target == nil then return end
	local CastPosition, HitChance, Position = VP:GetCircularCastPosition(target, ZiggsE.delay, ZiggsE.width, ZiggsE.range, ZiggsE.speed, myHero, false)
	if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < ZiggsE.range then
		CastSpell(_E,CastPosition.x, CastPosition.z)
	end
end

function CastR()
	target = LongRangeTargetSelector()
	if target == nil or target.dead == true or myHero:CanUseSpell(SPELL_4) ~= READY then return end
	if Config.human.predictmove then
		preX, preZ = S1mplePredict(target)
		if preX and preZ then
			CastSpell(_R,preX, preZ)
		end
	else
		CastSpell(_R,target.x, target.z)
	end
	p("Ultimate casted on: "..target.charName)
end