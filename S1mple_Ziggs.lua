--[[
	S1mple Ziggs by S1mple
	
	Credit's:
	Orianna for helping me out with the Orbwalker Detection
	PvPSuite for the Keydown Fix
	KuroXNeko for the Banner on my Thread
	
	TODO:
		Additional TargetSelector's
		Codecleanup
		Bugfixes
		????
		
]]--
local chkupdates = false --Set to "true" to check for updates without downloading them
local autoupdate = false --Set to "true" for autoupdate
local iskeydownfix = true
local version = "1.9"
local lolversion = "5.18"
local Update_HOST = "raw.github.com"
local Update_PATH = "/Scarjit/Scripts/master/S1mple_Ziggs.lua?rand="..math.random(1,10000)
local Update_FILE_PATH = "S1mple_Ziggs.lua"
local Changelog_PATH = "/Scarjit/Scripts/master/S1mple_Ziggs.changelog?rand="..math.random(1,10000)
local Update_URL = "https://"..Update_HOST..Update_PATH
versions = {"0", "1.5","1.6","1.7","1.8","1.9","2.0"}

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
	tlsarray = {"LRTS"}
	rpreds = {"VPrediction", "S1mplePredict", "On Target"}
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

function ChkUpdate()
	if not chkupdates then return end
	if autoupdate then return end
	p("Checking for Updates")
			local ServerData = GetWebResult(Update_HOST, "/Scarjit/Scripts/master/S1mple_Ziggs.version")
		if ServerData then
			ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
			if ServerVersion then
				if tonumber(version) < ServerVersion then
					p("Update found")
					p("Local Version: "..version" <==> ServerVersion: "..ServerVersion)
					p("Please update manually or turn autoupdate on")
				else
					p("No Update found")
				end
			end
		else
			p("Update Check failed")
		end
	
end	

function OnLoad()

	p("S1mple_Ziggs Version</font> "..version.." <font color=\"#570BB2\">loading</font>")
	findorbwalker()
	ChkUpdate()
	Update()
	--Config START
	Config:addParam("active", "Activated", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("hc", "Accuracy (Default: 2)", SCRIPT_PARAM_SLICE, 2, -1, 5, 1)
	Config:addParam("version", "Current Version", SCRIPT_PARAM_INFO, version)
	Config:addParam("otherchangelog", "Choose Changelog", SCRIPT_PARAM_LIST, 0, versions)
	Config:addParam("dspotherchanglelog", "Display selected Changelog", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("leagueversion", "Build for League of Legends Version: ", SCRIPT_PARAM_INFO, lolversion)
	
	Config:addTS(ts)
	Config:addSubMenu("Draws", "draws")
	Config:addSubMenu("Keys", "keys")
	Config:addSubMenu("Humanizer", "human")
	Config:addSubMenu("Advanced", "adv")
	
	Config.adv:addSubMenu("Laneclear", "lc")
	Config.adv.lc:addParam("laneclearpredhealth", "Don't cast spells on Minions below: ", SCRIPT_PARAM_SLICE,5,0,100,1)
	
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
	Config.adv.r:addParam("rinfo1", "Use the Sliders below to use different", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo2", "Predictions, based on Target Distance.", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo3", "===========WARNING============", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo4", "Do not put Phase 1 above Phase 2 or", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo5", "Phase 2 above Phase 3.", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo6", "Otherwise it might break the Script", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo7", "===============================", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("phase1", "Phase 1", SCRIPT_PARAM_SLICE, 1800, 1, 5300, 1)
	Config.adv.r:addParam("phase2", "Phase 2", SCRIPT_PARAM_SLICE, 3000, 2, 5300, 1)
	Config.adv.r:addParam("phase3", "Phase 3", SCRIPT_PARAM_SLICE, 5300, 3, 5300, 1)
	Config.adv.r:addParam("phase1pred", "Phase 1 Prediction: ", SCRIPT_PARAM_LIST, 0, rpreds)
	Config.adv.r:addParam("phase2pred", "Phase 2 Prediction: ", SCRIPT_PARAM_LIST, 0, rpreds)
	Config.adv.r:addParam("phase3pred", "Phase 3 Prediction: ", SCRIPT_PARAM_LIST, 0, rpreds)
	Config.adv.r:addParam("rrand", "Additional Random Distance: " , SCRIPT_PARAM_SLICE, 0, 0, 250, 1)
	Config.adv.r:addParam("tsl", "Target Selection Mode:" , SCRIPT_PARAM_LIST, 0, tlsarray) --NYI
	Config.adv.r:addParam("rinfotmp", "Additional Target Selection Modes", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfotmp", "will come with Update 2.0", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo8", "If you choose VPrediction, please choose", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("rinfo9", "a HitChance below", SCRIPT_PARAM_INFO, "")
	Config.adv.r:addParam("phase1hs", "Phase 1 Hitchance", SCRIPT_PARAM_SLICE, 2, 0, 5,1)
	Config.adv.r:addParam("phase2hs", "Phase 2 Hitchance", SCRIPT_PARAM_SLICE, 2, 0, 5,1)
	Config.adv.r:addParam("phase3hs", "Phase 3 Hitchance", SCRIPT_PARAM_SLICE, 2, 0, 5,1)
	
	Config.human:addParam("delayflee", "Delay Double W in Fleemode", SCRIPT_PARAM_SLICE, 0, 0, 4, 1)
	
	Config.draws:addParam("drawq", "Draw Q",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("draww", "Draw W",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawe", "Draw E",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawr", "Draw R (lags alot)",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawrmini", "Draw R on Minimap",SCRIPT_PARAM_ONOFF,false)
	Config.draws:addParam("drawenemy", "Draw Selected Enemy", SCRIPT_PARAM_ONOFF, false)
	Config.draws:addParam("drawenemyult", "Draw Selected Enemy (Forceult)", SCRIPT_PARAM_ONOFF, false)
	Config.draws:addParam("drawwalljumpmini", "Draw Walljumps on Minimap", SCRIPT_PARAM_ONOFF, false)
	Config.draws:addParam("drawwalljumprange", "Draw Walljump in Range", SCRIPT_PARAM_SLICE, 2000, 0, 10000, 10)
--	Config.draws:addParam("waypoints", "Draw Waypoints", SCRIPT_PARAM_ONOFF, false)
	
	Config.keys:addParam("combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.keys:addParam("harras", "Harras Key", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	Config.keys:addParam("laneclear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, 86)
	Config.keys:addParam("lasthit", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config.keys:addParam("flee", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, 71)
	Config.keys:addParam("forceult", "Forceult", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	Config.keys:addParam("walljump", "Walljump", SCRIPT_PARAM_ONKEYDOWN, false, 85)
	
	Config.keys:permaShow("combo")
	Config.keys:permaShow("harras")
	Config.keys:permaShow("laneclear")
	Config.keys:permaShow("lasthit")
	Config.keys:permaShow("flee")
	Config.keys:permaShow("forceult")
	Config.keys:permaShow("walljump")
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
			if ((value.health/value.maxHealth)*100) <= Config.adv.lc.laneclearpredhealth then return end
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
		local b_castlc = false
		if not prefminion then return end
		if myHero:CanUseSpell(SPELL_1) == READY and b_castlc == false and Config.adv.q.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.q.laneclearminmana then
			b_castlc = true
			CastQ(prefminion)
		end
		if myHero:CanUseSpell(SPELL_2) == READY and b_castlc == false and Config.adv.w.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.w.laneclearminmana then
			b_castlc = true
			CastW(prefminion)
		end
		if myHero:CanUseSpell(SPELL_3) == READY and b_castlc == false and Config.adv.e.laneclearcast and not prefminion.dead and ((myHero.mana/myHero.maxMana)*100) >= Config.adv.e.laneclearminmana then
			b_castlc = true
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
	if Config.keys.walljump == true then
		Jump()
	end
end

function OnDraw()
if Config.active == false then return end
	ts:update()
	if ts.target ~= nil then	
		DrawText("Normal Target: "..ts.target.charName, 18, 100, 140, c_green)
	end
		if LongRangeTargetSelector() ~= nil and myHero:CanUseSpell(SPELL_4) == READY then	
		DrawText("Ultimate Target: "..LongRangeTargetSelector().charName, 18, 100, 160, c_green)
	end
	
	if Config.draws.drawq == true and myHero:CanUseSpell(_Q) == 0 then
		DrawCircle3D(X,Y,Z,850,5,c_red)
		DrawCircle3D(X,Y,Z,1400,5,c_red)
	end
	if Config.draws.draww == true and myHero:CanUseSpell(_W) == 0 then
		DrawCircle3D(X,Y,Z,1000,5,c_blue)
	end
	if Config.draws.drawe == true and myHero:CanUseSpell(_E) == 0 then
		DrawCircle3D(X,Y,Z,900,5,c_blue)
	end
	if Config.draws.drawr == true and myHero:CanUseSpell(_R) == 0 then
		DrawCircle3D(X,Y,Z,5300,5,c_green)
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
	
	--DrawText("Current Time: "..os.time(),18,100,50,c_red)
	--DrawText("Max Mana: "..myHero.maxMana, 18, 100, 60, c_red)
	--DrawText("Current Mana: "..myHero.mana, 18,100,80,c_red)
	--DrawText("Mana Percentage: "..((myHero.mana/myHero.maxMana)*100), 18, 100, 100, c_red)
	--DrawText("Location:"..tostring(math.round(myHero.x)).." : "..tostring(math.round(myHero.y)).." : "..tostring(math.round(myHero.z)),20, 100,160, c_red)
	--DrawText("Mouse:"..tostring(math.round(mousePos.x)).." : "..tostring(math.round(mousePos.y)).." : "..tostring(math.round(mousePos.z)),20, 100,180, c_red)

	if Config.adv.r.phase1 > Config.adv.r.phase2 then
		DrawText("Phase 1 is greater then Phase 2", 20, 100,180, c_red)
	end
	if Config.adv.r.phase2 > Config.adv.r.phase3 then
		DrawText("Phase 2 is greater then Phase 3", 20, 100,200, c_red)
	end
	if Config.adv.r.phase1 > Config.adv.r.phase3 then
		DrawText("Phase 1 is greater then Phase 3", 20, 100,220, c_red)
	end
	if Config.keys.walljump == true or Config.draws.drawwalljumpmini == true then
		MarkJumps()
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
	--[[
		Phase 1 <= 600
		Phase 2 601 - 2000
		Phase 3 2001 - 5300
		All 3 Phases can be overriden in Advanced Config
	]]--
	local randdstx = 0
	local randdstz = 0
	
	local target = LongRangeTargetSelector() -- Next Version Better LRTS
	
	if target == nil or target.dead == true or myHero:CanUseSpell(SPELL_4) ~= READY then return end
	local distance = getDistance(myHero.x, myHero.z, target.x, target.z)
	if not distance then return end
	if distance >= 6000 then return end
	
	if Config.adv.r.rrand ~= 0 then
		randdstx = math.random((Config.adv.r.rrand*-1),Config.adv.r.rrand)
		randdstz = math.random((Config.adv.r.rrand*-1),Config.adv.r.rrand)
	end
	--PHASE 1
	if distance < Config.adv.r.phase1 then
		if rpreds[Config.adv.r.phase1pred] == "VPrediction" then
			local  CastPosition, HitChance, Position = VP:GetCircularCastPosition(target, ZiggsR.delay, ZiggsR.width, ZiggsR.range, ZiggsR.speed, myHero, false)
			if CastPosition and HitChance >= Config.adv.r.phase1hs and GetDistance(CastPosition) <= 5850 then
				CastSpell(_R, CastPosition.x+randdstx, CastPosition.z+randdstz)
			end
		end
		if rpreds[Config.adv.r.phase1pred] == "S1mplePredict" then
			preX, preZ = S1mplePredict(target)
			if preX and preZ then
				CastSpell(_R,preX+randdstx, preZ+randdstz)
			end
		end
		if rpreds[Config.adv.r.phase1pred] == "On Target" then
			CastSpell(_R,target.x+randdstx, target.z+randdstz)
		end
		p("Phase 1 Ultimate casted using: "..rpreds[Config.adv.r.phase1pred])
	else
		--PHASE 2
		if distance < Config.adv.r.phase2 then
			if rpreds[Config.adv.r.phase2pred] == "VPrediction" then
				local  CastPosition, HitChance, Position = VP:GetCircularCastPosition(target, ZiggsR.delay, ZiggsR.width, ZiggsR.range, ZiggsR.speed, myHero, false)
				if CastPosition and HitChance >= Config.adv.r.phase2hs and GetDistance(CastPosition) <= 5850 then
					CastSpell(_R, CastPosition.x+randdstx, CastPosition.z+randdstz)
				end
			end
			if rpreds[Config.adv.r.phase2pred] == "S1mplePredict" then
				preX, preZ = S1mplePredict(target)
				if preX and preZ then
					CastSpell(_R,preX+randdstx, preZ+randdstz)
				end
			end
			if rpreds[Config.adv.r.phase2pred] == "On Target" then
				CastSpell(_R,target.x+randdstx, target.z+randdstz)
			end
			p("Phase 2 Ultimate casted using: "..rpreds[Config.adv.r.phase2pred])
			return
		else
		--PHASE 3
			if distance < Config.adv.r.phase3 then
				if rpreds[Config.adv.r.phase3pred] == "VPrediction" then
					local  CastPosition, HitChance, Position = VP:GetCircularCastPosition(target, ZiggsR.delay, ZiggsR.width, ZiggsR.range, ZiggsR.speed, myHero, false)
					if CastPosition and HitChance >= Config.adv.r.phase3hs and GetDistance(CastPosition) <= 5850 then
						CastSpell(_R, CastPosition.x+randdstx, CastPosition.z+randdstz)
					end
				end
				if rpreds[Config.adv.r.phase3pred] == "S1mplePredict" then
					preX, preZ = S1mplePredict(target)
					if preX and preZ then
						CastSpell(_R,preX+randdstx, preZ+randdstz)
					end
				end
				if rpreds[Config.adv.r.phase3pred] == "On Target" then
					CastSpell(_R,target.x+randdstx, target.z+randdstz)
				end
				p("Phase 3 Ultimate casted using: "..rpreds[Config.adv.r.phase3pred])
				return
			end
		end
	end
end

function OnUnload()
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

--[[========= S1mple Libary =========]]--

function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

function getDistance(X,Y,X1,Y1)
	--(X-X1)^2+(Z-Z1)^2 <= R^2 if in range
	return math.sqrt(((X-X1)^2)+((Y-Y1)^2))
end

--[[========= Walljumps =========]]--
--startX,startY,start,Z,endX,endY,endZ
jumps = {{5948,52,2458,5424,51,2458},{8348,52,3276,8395,51,2798},{6398,50,3460,6775,49,3814},{11780,-71,4554,11973,52,4753},{9338,-71,4490,8969,53,4541},{9722,71,3908,9659,58,3513},{9446,-62,4146,9124,54,3859},{8022,54,4258,7972,51,4738},{3080,57,6014,3319,52,6224},{3924,51,7408,3865,52,7736},{2224,52,8256,2017,50,7936},{2874,51,9156,2516,52,9107},{2916,52,8348,3168,51,8848},{3078,54,10010,3334,-65,10249},{4024,51,8056,4340,49,8154},{9496,58,3146,9404,49,2810},{8942,52,4962,9142,-71,5402},{7822,52,6008,8012,-11,6240},{5724,52,7806,6024,68,8206},{4624,71,10756,4374,49,11250},{5374,-71,10756,5532,57,11136},{5448,71,10326,584,55,10350},{5284,57,11818,5356,58,12092},{6524,56,12006,6564,54,11722},{8522,53,11356,8172,51,11106},{11072,67,9106,11172,52,9706},{11772,50,8856,11588,64,8726},{11722,56,8356,12075,52,8106},{12620,52,6642,12920,52,6942},{12768,52,6124,13160,57,5946},{12306,59,5826,11972,51,5728},{7124,52,6058,7030,56,5546},{7224,55,10206,7074,56,10606},{6824,56,10950,6418,56,11168},{10712,52,7034,10322,52,6958},{11072,52,7208,11048,52,7500},{11122,52,7806,11022,63,8156},{10772,63,8306,10322,60,8406},{9222,53,7058,8872,-71,6608},{7054,53,8744,6874,-70,8626},{7572,53,8956,7822,52,9306}}
function MarkJumps()
	for key, value in pairs(jumps) do
		local n = ((myHero.x-value[1])^2+(myHero.z-value[3])^2)
		n = math.sqrt(math.round(n))
		if n <= Config.draws.drawwalljumprange then
			if Config.draws.drawwalljumpmini == true then
				DrawCircleMinimap(value[1], value[2], value[3], 100, 2, c_green)
				DrawCircleMinimap(value[4], value[5], value[6], 100, 2, c_green)
			end
			if Config.keys.walljump == true then
				DrawCircle3D(value[1], value[2], value[3], 100, 2, c_green)
				DrawLine3D(value[1],value[2],value[3],value[4],value[5],value[6], 3, c_green)
				DrawCircle3D(value[4], value[5], value[6], 100, 2, c_green)
			end
		end
	end
end

function Jump()
	for key, value in pairs(jumps) do
		local n = ((mousePos.x-value[1])^2+(mousePos.z-value[3])^2)
		n = math.sqrt(math.round(n))
		if n <= 100 then
				myHero:MoveTo(value[1],value[3])
		end
		if math.round(myHero.x) == value[1] and math.round(myHero.z) == value[3] then
			local v5 = value[4]-value[1]
			local v6 = value[6]-value[3]
			local cp1 = (value[1]-v5/2)
			local cp2 = (value[3]-v6/2)
			CastSpell(_W,cp1,cp2)
		end
	end
	
	for key, value in pairs(jumps) do --Reverse jump
		local n = ((mousePos.x-value[4])^2+(mousePos.z-value[6])^2)
		n = math.sqrt(math.round(n))
		if n <= 100 then
				myHero:MoveTo(value[4],value[6])
		end
		if math.round(myHero.x) == value[4] and math.round(myHero.z) == value[6] then
			local v7 = value[1]-value[4]
			local v8 = value[3]-value[6]
			local cp3 = (value[4]-v7/2)
			local cp4 = (value[6]-v8/2)
			CastSpell(_W,cp3,cp4)
		end
	end
end

