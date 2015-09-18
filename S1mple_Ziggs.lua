--[[
	S1mple Ziggs by S1mple
	
	Credit's:
	Orianna for helping me out with the Orbwalker Detection
	PvPSuite for the Keydown Fix
	KuroXNeko for the Banner on my Thread

]]--

local autoupdate = false --Set to "true" for autoupdate
local iskeydownfix = true
local version = "1.7"
local lolversion = "5.18"
local Update_HOST = "raw.github.com"
local Update_PATH = "/Scarjit/Scripts/master/S1mple_Ziggs.lua?rand="..math.random(1,10000)
local Update_FILE_PATH = "S1mple_Ziggs.lua"
local Changelog_PATH = "/Scarjit/Scripts/master/S1mple_Ziggs.changelog?rand="..math.random(1,10000)
local Update_URL = "https://"..Update_HOST..Update_PATH
versions = {"0", "1.5","1.6","1.7"}

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

--Keydown Fix
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
local originalKD = _G.IsKeyDown;
_G.IsKeyDown = function(theKey)
	if iskeydownfix then
		if (type(theKey) ~= 'number') then
			local theNumber = tonumber(theKey);
			if (theNumber ~= nil) then
				return originalKD(theNumber);
			else
				return originalKD(GetKey(theKey));
			end;
		else
			return originalKD(theKey);
		end
	end
end
--End Keydown Fix

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
	if not autoupdate then 
		p("Autoupdate's disabled")
	return 
	end
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
	Config:addParam("otherchangelog", "Choose Changelog", SCRIPT_PARAM_LIST, 0, versions) --Change on Update
	Config:addParam("dspotherchanglelog", "Display selected Changelog", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("leagueversion", "Build for League of Legends Version: ", SCRIPT_PARAM_INFO, lolversion)
	
	Config:addTS(ts)
	Config:addSubMenu("Draws", "draws")
	Config:addSubMenu("Keys", "keys")
	Config:addSubMenu("Humanizer", "human")
	Config:addSubMenu("Advanced", "adv")
	Config:addSubMenu("Reset", "rst")
	
	Config.rst:addParam("rsthlp0", "Resets all Settings to default", SCRIPT_PARAM_INFO, "")
	Config.rst:addParam("rsthlp1", "This can not be undone", SCRIPT_PARAM_INFO, "")
	Config.rst:addParam("rsthlp3", "Does not reset Keys", SCRIPT_PARAM_INFO, "")
	Config.rst:addParam("rsthlp4", "===How to reset===", SCRIPT_PARAM_INFO, "")
	Config.rst:addParam("rstslide", "Slide to 100 to unlock reset Button", SCRIPT_PARAM_SLICE, 0,0,100,1)
	Config.rst:addParam("rstbtn", "RESET", SCRIPT_PARAM_ONOFF, false)
	
	Config.adv:addSubMenu("Q", "q")	
	Config.adv.q:addParam("qcollision", "Q Minion Collision", SCRIPT_PARAM_ONOFF, true)
	Config.adv.q:addParam("combocast", "Cast in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.q:addParam("combominmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.q:addParam("harrascast", "Cast in Harras Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.q:addParam("harrasminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.q:addParam("laneclearcast", "Cast in Laneclear Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.q:addParam("laneclearminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	
	Config.adv:addSubMenu("W", "w")
	Config.adv.w:addParam("combocast", "Cast in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.w:addParam("combominmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.w:addParam("harrascast", "Cast in Harras Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.w:addParam("harrasminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.w:addParam("laneclearcast", "Cast in Laneclear Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.w:addParam("laneclearminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.w:addParam("fleecast", "Cast in Flee Mode", SCRIPT_PARAM_ONOFF, true)

	Config.adv:addSubMenu("E", "e")
	Config.adv.e:addParam("combocast", "Cast in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.e:addParam("combominmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.e:addParam("harrascast", "Cast in Harras Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.e:addParam("harrasminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.e:addParam("laneclearcast", "Cast in Laneclear Mode", SCRIPT_PARAM_ONOFF, true)
	Config.adv.e:addParam("laneclearminmana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 1)
	Config.adv.e:addParam("fleecast", "Cast in Flee Mode", SCRIPT_PARAM_ONOFF, true)
	
	Config.adv:addSubMenu("R", "r")
	Config.adv.r:addParam("predictmove", "Predict's enemy Pos for Forceult", SCRIPT_PARAM_ONOFF, true)
	
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
	Config.keys:addParam("harras", "Harras Key", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	Config.keys:addParam("laneclear", "Lane Clear (Uses Q/E)", SCRIPT_PARAM_ONKEYDOWN, false, 86)
	Config.keys:addParam("lasthit", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config.keys:addParam("flee", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, 71)
	Config.keys:addParam("forceult", "Forceult", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	
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
if Config.rst.rstslide ~= 100 and Config.rst.rstbtn == true then 
	Config.rst.rstbtn = false
end
if Config.rst.rstslide == 100 then
	if Config.rst.rstbtn == true then
		Config.rst.rstbtn = false
		Config.rst.rstslide = 0
		Config.active = true
		Config.hc = 2
		Config.adv.q.qcollision = true
		Config.adv.q.combocast = true
		Config.adv.q.combominmana = 10
		Config.adv.q.harrascast = true
		Config.adv.q.harrasminmana = 10
		Config.adv.q.laneclearcast = true
		Config.adv.q.laneclearminmana = 10
		Config.adv.w.combocast = true
		Config.adv.w.combominmana = 10
		Config.adv.w.harrascast = true
		Config.adv.w.harrasminmana = 10
		Config.adv.w.laneclearcast = true
		Config.adv.w.laneclearminmana = 10
		Config.adv.w.fleecast = true
		Config.adv.e.combocast = true
		Config.adv.e.combominmana = 10
		Config.adv.e.harrascast = true
		Config.adv.e.harrasminmana = 10
		Config.adv.e.laneclearcast = true
		Config.adv.e.laneclearminmana = 10
		Config.adv.e.fleecast = true
		Config.adv.r.predictmove = true
		Config.human.delayflee = 0
		Config.draws.drawq = false
		Config.draws.draww = false
		Config.draws.drawe = false
		Config.draws.drawr = false
		Config.draws.drawrmini = false
		Config.draws.drawenemy = false
		Config.draws.drawenemyult = false	
		p("S1mple_Ziggs RESETED")
		p("Please reconfigure your Settings, before reloading")
	end
end

if Config.dspotherchanglelog then
	Config.dspotherchanglelog = false
	Changelog(Config.otherchangelog)
end

if SAC~=true and SxOrb~= true and GetGameTimer() <= 100 and myHero.dead and not Config.active then return end
ts:update()
X = myHero.x
Y = myHero.y
Z = myHero.z

	if Config.keys.combo == true then
		if ts.target == nil then return end
		tname = string.upper(string.sub(ts.target.charName, 0, 3))
		if tname ~= "SRU" then
			if Config.adv.q.combocast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.q.combominmana then
				CastQ(ts.target)
			end
			if Config.adv.w.combocast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.w.combominmana then
				CastW(ts.target)
			end
			if Config.adv.e.combocast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.e.combominmana then
				CastE(ts.target)
			end
		end
	end
	if Config.keys.harras == true then
		if ts.target == nil then return end
		if Config.adv.q.harrascast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.q.harrasminmana then
			CastQ(ts.target)
		end
		if Config.adv.w.harrascast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.w.harrasminmana then
			CastW(ts.target)
		end
		if Config.adv.e.harrascast and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.e.harrasminmana then
			CastE(ts.target)
		end
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
		if not prefminion then return end
		if Config.adv.q.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.q.laneclearminmana then
			CastQ(prefminion)
		end
		if Config.adv.w.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.w.laneclearminmana then
			CastW(prefminion)
		end
		if Config.adv.e.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.e.laneclearminmana then
			CastE(prefminion)
		end
	end
	
	if Config.keys.flee == true then
		myHero:MoveTo(mousePos.x, mousePos.z)
		if Config.adv.e.fleecast then
			CastE(myHero)
		end
		if os.time() < flee_recasttime then return end
		flee_recasttime = os.time() + Config.human.delayflee
		if Config.adv.w.fleecast then
			CastW(myHero)
		end
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
	--DrawText("Max Mana: "..myHero.maxMana, 18, 50, 60, c_red)
	--DrawText("Current Mana: "..myHero.mana, 18,50,80,c_red)
	--DrawText("Mana Percentage: "..((myHero.mana/myHero.maxMana)*100), 18, 50, 100, c_red)
	if Config.rst.rstslide == 100 then
		DrawText("RESET BUTTON UNLOCKED", 38, 500, 250, c_red)
	end
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
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, ZiggsQ.delay, ZiggsQ.width, ZiggsQ.range, ZiggsQ.speed, myHero, Config.adv.q.qcollision)
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

function OnUnload()
	Config.rst.rstslide = 0
	p("Unloaded")
end

function Changelog(selectedversion)
	local b_currentVersion = false
	local b_chnotfound = true
	local ServerData = GetWebResult(Update_HOST, Changelog_PATH)
	local index = -1
	selectedversion = versions[tonumber(selectedversion)]
	
	for key,value in pairs(versions) do
		if value == selectedversion then 
			index = key
		end
	end
	if index == -1 then 
		p("Could not find Version: "..selectedversion) 
		return 
	end
	
	if ServerData then
		tabl = lines(ServerData)
		for i,v in pairs(tabl) do
			if v == selectedversion then
				b_currentVersion = true
				b_chnotfound = false
				print("<font color=\"#FFD700\">Version: </font>"..v)
			else
				if v == versions[index+1] then 
					b_currentVersion = false
				end
				if b_currentVersion then
					p(v)
				end
			end
		end
	else
		p("Could not connect to "..Update_HOST)
	end
	if b_chnotfound then
		if selectedversion ~= "0" then
			p("Could not find Changelog for Version: </font>"..selectedversion) 
		end
	end
end

--[[========= S1mple String Libary =========]]--

function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end