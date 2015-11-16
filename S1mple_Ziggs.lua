--[[
   _____ __                 _       __      __  _                    _              _____ __                 _       _____           _       _       
  / ____/_ |               | |      \ \    / / (_)                  | |            / ____/_ |               | |     / ____|         (_)     | |      
 | (___  | |_ __ ___  _ __ | | ___   \ \  / /__ _  __ _  __ _ _ __  | |__  _   _  | (___  | |_ __ ___  _ __ | | ___| (___   ___ _ __ _ _ __ | |_ ___ 
  \___ \ | | '_ ` _ \| '_ \| |/ _ \   \ \/ / _ \ |/ _` |/ _` | '__| | '_ \| | | |  \___ \ | | '_ ` _ \| '_ \| |/ _ \\___ \ / __| '__| | '_ \| __/ __|
  ____) || | | | | | | |_) | |  __/    \  /  __/ | (_| | (_| | |    | |_) | |_| |  ____) || | | | | | | |_) | |  __/____) | (__| |  | | |_) | |_\__ \
 |_____/ |_|_| |_| |_| .__/|_|\___|     \/ \___|_|\__, |\__,_|_|    |_.__/ \__, | |_____/ |_|_| |_| |_| .__/|_|\___|_____/ \___|_|  |_| .__/ \__|___/
                     | |                           __/ |                    __/ |                     | |                             | |            
                     |_|                          |___/                    |___/                      |_|                             |_|            
	
	Credits:
		

License Disclaimer:
	This Script is licensed under:
		Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
		Read the License here:
		http://creativecommons.org/licenses/by-nc-sa/4.0/

		TL;DR:
		You may:
			Copy and redistribute the Script
			Modify the Script as you like
		You have to:
			Give credit to the Original Owner (S1mpleScripts)
		You may not:
			Use this Script for Commercial Purpoeses
			Change the License of any Part of this Script
]]--

myHero = GetmyHero
if myHero.charName ~= "Veigar" then return end
if _ENV.FILE_NAME ~= "S1mple_Veigar.lua" then
	print("[S1mple_Veigar] <font color=\"#570BB2\">Please rename S1mple_Veigar's .lua File</font>")
	print("[S1mple_Veigar] <font color=\"#570BB2\">too: S1mple_Veigar.lua</font>")
	return
end

--Localize LUA Core functions
local sqrt, max, deg, asin, cos, pi, floor, ceil, sin, huge, random, round = math.sqrt, math.max, math.deg, math.asin, math.cos, math.pi, math.floor, math.ceil, math.sin, math.huge, math.random, math.round

--Initialize Global Vars
	local autoupdate = true --Change to false if you don't wan't autoupdates
	local LocalVersion = "2.0"
	local name = "S1mple_Veigar"
	local debug = false
	local VeigarQ = { range = 950, width = 50, speed = 2000, delay = .25, collision = false } --Have to get number of Colliding Enemy's
	local VeigarW = { range = 900, width = 112.5, speed = huge, delay = 1.25, collision = false }
	local VeigarE = { range = 700, width = 375, speed = huge, delay = .5, collision = false }
	local VeigarR = { range = 650, speed = huge, delay = .25, collision = false } --Not a Skillshot
	local ts = TargetSelector(TARGET_LESS_CAST, 2000, DAMAGE_MAGIC, true)
	local c_red = ARGB(255, 255,0,0)
	local c_green = ARGB(255,9,255,0)
	local c_blue = ARGB(255,51,51,255)
	local predictions = {}
	local Veigar = scriptConfig("S1mple_Veigar", "s1mple_veigar")
	--local enemyMinions = minionManager(MINION_ENEMY, 2000, player, MINION_SORT_HEALTH_ASC)
	local updated = false
	local enemyMinions = {}

--END INI VARS

--Keydown Fix
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
local originalKD = _G.IsKeyDown;
_G.IsKeyDown = function(theKey)
	if (type(theKey) ~= 'number') then
		local tn = tonumber(theKey);
		if (tn ~= nil) then
			return originalKD(tn);
		else
			return originalKD(GetKey(theKey));
		end;
	else
		return originalKD(theKey);
	end
end
--End Keydown Fix

function OnLoad()
	findupdates()
	if updated == true then return end
	findprediction()
	Config()
	findorbwalker()

	p("Loaded "..name)
end

function OnTick()
	if not Veigar then return end
	if updated == true then return end
	
	for i=1, objManager.maxObjects do 
		local obj = objManager:GetObject(i)
		if obj ~= nil and obj.valid and obj.type == 'obj_AI_Minion' and obj.visible and GetDistance(obj,myHero) then
			table.insert(enemyMinions, obj)
		end
	end

	ts:update()
	ChkConfig()
	Harras()
	Combo()
	Laneclear()

end


function OnDraw()
	if not Veigar then return end
	if updated == true then
		DrawText("S1mple_Veigar has updated, please reload (2xF9)", 30,50,50,4294967295)
	end
	if updated == false then
		if Veigar.draws.qrange then
			DrawCircle2(myHero.x, myHero.y, myHero.z, VeigarQ.range, ARGB(255,0,0,255))
		end
		if Veigar.draws.erange then
			DrawCircle2(myHero.x, myHero.y, myHero.z, VeigarW.range, ARGB(255,0,255,255))
		end
		if Veigar.draws.wrange then
			DrawCircle2(myHero.x, myHero.y, myHero.z, VeigarE.range, ARGB(255,255,0,255))
		end
		if Veigar.draws.rrange then
			DrawCircle2(myHero.x, myHero.y, myHero.z, VeigarR.range, ARGB(255,255,255,255))
		end
		if Veigar.draws.rdmg and myHero:CanUseSpell(_R) == 0 then
			local enemys = GetEnemyHeroes()
			for _,v in pairs(enemys) do
				if GetDistance(v, myHero) <= VeigarR.range+300 and v.visible and v.dead == false then
					local lvl = myHero:GetSpellData(_R).level
					local ap = GetAp(myHero)
					local eap = GetAp(v)
					local dmg = 125 + lvl*125 + ap + (eap * 0.8)
					local dmgp = dmg * (100/(100+v.magicArmor))
					dmgp = dmgp - (dmgp * (Veigar.adv.r.buffer/100))
					local barPos = GetUnitHPBarPos(v) --THANKS Jori
					local barOffset = GetUnitHPBarOffset(v)
					do -- For some reason the x offset never exists
						local t = {
							["Darius"] = -0.05,
							["Renekton"] = -0.05,
							["Sion"] = -0.05,
							["Thresh"] = 0.03,
						}
						barOffset.x = t[v.charName] or 0
					end
					local baseX = barPos.x - 69 + barOffset.x * 150
					local baseY = barPos.y + barOffset.y * 50 + 12.5
					if dmgp <= v.health then
						DrawTextA(round(dmgp).."",18,baseX,baseY,ARGB(255,0,255,0))
					else
						DrawTextA("Killable",18,baseX,baseY,ARGB(255,255,0,0))
					end
				end
			end
		end
	end
end
--[[
SCRIPT_PARAM_ONOFF = 1
SCRIPT_PARAM_ONKEYDOWN = 2
SCRIPT_PARAM_ONKEYTOGGLE = 3
SCRIPT_PARAM_SLICE = 4
SCRIPT_PARAM_INFO = 5
SCRIPT_PARAM_COLOR = 6
SCRIPT_PARAM_LIST = 7
]]

--[[==============================Start Config==============================]]--

function Config()
	
	Veigar:addSubMenu("Spell Settings", "adv")
		Veigar.adv:addSubMenu("Q Settings", "q")

			Veigar.adv.q:addParam("sec1", "Combo Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.q:addParam("combocast", "Cast in Combo Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.q:addParam("combominmana", "Minimum Mana to Cast in Combo Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.q:addParam("combohs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.q:addParam("sec2", "Harras Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.q:addParam("harrascast", "Cast in Harras Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.q:addParam("harrasminmana", "Minimum Mana to Cast in Harras Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.q:addParam("harrashs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.q:addParam("sec3", "Laneclear Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.q:addParam("laneclearcast", "Cast in Laneclear Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.q:addParam("laneclearminmana", "Minimum Mana to Cast in Laneclear Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.q:addParam("laneclearhs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.q:addParam("sec4", "Other Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.q:addParam("qallowhit", "Only Cast if clear View to Enemy",SCRIPT_PARAM_ONOFF, false)
			Veigar.adv.q:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, predictions)


		Veigar.adv:addSubMenu("W Settings", "w")
			Veigar.adv.w:addParam("sec1", "Combo Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.w:addParam("combocast", "Cast in Combo Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.w:addParam("combominmana", "Minimum Mana to Cast in Combo Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.w:addParam("combohs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.w:addParam("sec2", "Harras Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.w:addParam("harrascast", "Cast in Harras Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.w:addParam("harrasminmana", "Minimum Mana to Cast in Harras Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.w:addParam("harrashs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.w:addParam("sec3", "Laneclear Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.w:addParam("laneclearcast", "Cast in Laneclear Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.w:addParam("laneclearminmana", "Minimum Mana to Cast in Laneclear Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.w:addParam("laneclearhs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.w:addParam("sec4", "Other Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.w:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, predictions)

		Veigar.adv:addSubMenu("E Settings", "e")
			Veigar.adv.e:addParam("sec1", "Combo Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.e:addParam("combocast", "Cast in Combo Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.e:addParam("combominmana", "Minimum Mana to Cast in Combo Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.e:addParam("combohs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.e:addParam("sec2", "Harras Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.e:addParam("harrascast", "Cast in Harras Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.e:addParam("harrasminmana", "Minimum Mana to Cast in Harras Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.e:addParam("harrashs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.e:addParam("sec3", "Laneclear Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.e:addParam("laneclearcast", "Cast in Laneclear Mode",SCRIPT_PARAM_ONOFF, false)
			Veigar.adv.e:addParam("laneclearminmana", "Minimum Mana to Cast in Laneclear Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)
			Veigar.adv.e:addParam("laneclearhs", "Hitchance",SCRIPT_PARAM_SLICE, 2, 0, 5, 1)

			Veigar.adv.e:addParam("sec4", "Other Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.e:addParam("champonly","Only cast on Champions", SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.e:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, predictions)

		Veigar.adv:addSubMenu("R Settings", "r")
			Veigar.adv.r:addParam("sec1", "Combo Mode Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.r:addParam("combocast", "Cast in Combo Mode",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.r:addParam("combominmana", "Minimum Mana to Cast in Combo Mode %",SCRIPT_PARAM_SLICE, 0, 0, 100, 1)

			Veigar.adv.r:addParam("sec4", "Other Settings", SCRIPT_PARAM_INFO, "")
			Veigar.adv.r:addParam("kill", "Only Cast if target is Killable",SCRIPT_PARAM_ONOFF, true)
			Veigar.adv.r:addParam("buffer", "Buffer",SCRIPT_PARAM_SLICE, 5, 0, 25, 1)

		Veigar:addSubMenu("Other", "other")
			Veigar.other:addTS(ts)
			--Use BOL 1.0 Target Selector instead / Get SAC:R Target
			Veigar.other:addSubMenu("Humanizer", "human")
				Veigar.other.human:addParam("sec1", "Jitter", SCRIPT_PARAM_INFO, "")
				Veigar.other.human:addParam("qjitter", "Q Jitter",SCRIPT_PARAM_SLICE, 0, 0, 50, 1)
				Veigar.other.human:addParam("wjitter", "W Jitter",SCRIPT_PARAM_SLICE, 0, 0, 50, 1)
				Veigar.other.human:addParam("ejitter", "E Jitter",SCRIPT_PARAM_SLICE, 0, 0, 50, 1)
				Veigar.other.human:addParam("sec2", "Delay Time (In Secounds)", SCRIPT_PARAM_INFO, "")
				Veigar.other.human:addParam("qdelay", "Q Delay",SCRIPT_PARAM_SLICE, 0, 0, 10, 0.1)
				Veigar.other.human:addParam("wdelay", "W Delay",SCRIPT_PARAM_SLICE, 0, 0, 10, 0.1)
				Veigar.other.human:addParam("edelay", "E Delay",SCRIPT_PARAM_SLICE, 0, 0, 10, 0.1)
				Veigar.other.human:addParam("rdelay", "R Delay",SCRIPT_PARAM_SLICE, 0, 0, 10, 0.1)
			Veigar.other:addParam("logicchk", "LogicCheck", SCRIPT_PARAM_SLICE, 500,0,1500,1)
		Veigar:addSubMenu("Key Bindings", "key")
			Veigar.key:addParam("combokey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN,false, 32)
			Veigar.key:addParam("harraskey", "Harras Key", SCRIPT_PARAM_ONKEYDOWN,false, 67)
			Veigar.key:addParam("laneclearkey", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN,false, 86)
		Veigar:addSubMenu("Draws", "draws")
			Veigar.draws:addParam("qrange", "Draw Q", SCRIPT_PARAM_ONOFF, true)
			Veigar.draws:addParam("wrange", "Draw W", SCRIPT_PARAM_ONOFF, true)
			Veigar.draws:addParam("erange", "Draw E", SCRIPT_PARAM_ONOFF, true)
			Veigar.draws:addParam("rrange", "Draw R", SCRIPT_PARAM_ONOFF, true)
			Veigar.draws:addParam("rdmg", "Draw R Damage", SCRIPT_PARAM_ONOFF, true)
			Veigar.draws:addParam("lfcresolution", "Cirlce Quality", SCRIPT_PARAM_SLICE, 300, 75, 2000, 0)
			Veigar.draws:addParam("lfcthickness", "Circle Thickness", SCRIPT_PARAM_SLICE,1,1,5,1)

end

function ChkConfig()

	if Veigar.other.human.qdelay ~= round(Veigar.other.human.qdelay,1) then
		Veigar.other.human.qdelay = (round(Veigar.other.human.qdelay,1))
	end
	if Veigar.other.human.wdelay ~= round(Veigar.other.human.wdelay,1) then
		Veigar.other.human.wdelay = (round(Veigar.other.human.wdelay,1))
	end
	if Veigar.other.human.edelay ~= round(Veigar.other.human.edelay,1) then
		Veigar.other.human.edelay = (round(Veigar.other.human.edelay,1))
	end
	if Veigar.other.human.rdelay ~= round(Veigar.other.human.rdelay,1) then
		Veigar.other.human.rdelay = (round(Veigar.other.human.rdelay,1))
	end
end


--[[==============================End Config==============================]]--
--[[==============================Start Scriptlogic==============================]]--

function Harras()
	if not Veigar.key.harraskey then return end
	local target = nil
	if Veigar.adv.q.harrascast and Veigar.adv.q.harrasminmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarQ.range then
			CastQ(target, "Harras")
		end
	end
	target = nil

	if Veigar.adv.w.harrascast and Veigar.adv.w.harrasminmana  then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarW.range then
			CastW(target, "Harras")
		end
	end
	target = nil

	if Veigar.adv.e.harrascast and Veigar.adv.e.harrasminmana  then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarE.range then
			CastE(target, "Harras")
		end
	end
	target = nil

end

function Combo()
	if not Veigar.key.combokey then return end
	local target = nil
	if Veigar.adv.q.combocast and Veigar.adv.q.combominmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarQ.range then
			CastQ(target, "Combo")
		end
	end
	target = nil

	if Veigar.adv.w.combocast and Veigar.adv.w.combominmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarW.range then
			CastW(target, "Combo")
		end
	end
	target = nil

	if Veigar.adv.e.combocast and Veigar.adv.e.combominmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarE.range then
			CastE(target, "Combo")
		end
	end
	target = nil

	if Veigar.adv.r.combocast and Veigar.adv.r.combominmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Crosshair:GetTarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarR.range then
			CastR(target, "Combo")
		end
	end
	target = nil
end

function Laneclear()
	if not Veigar.key.laneclearkey then return end
	local target = nil
	if Veigar.adv.q.laneclearcast and Veigar.adv.q.laneclearminmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Minions:GetLowestHealthMinion()
			p(target.charName)
		end
		if _G.SxOrb and target == nil then
			target = sxtarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarQ.range then
			CastQ(target, "Laneclear")
		end
	end
	target = nil

	if Veigar.adv.w.laneclearcast and Veigar.adv.w.laneclearminmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Minions:GetLowestHealthMinion()
		end
		if _G.SxOrb and target == nil then
			target = sxtarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarW.range then
			CastW(target, "Laneclear")
		end
	end
	target = nil

	if Veigar.adv.e.laneclearcast and Veigar.adv.e.laneclearminmana then
		if _G.AutoCarry and Veigar.other.sac then
			target = _G.AutoCarry.Minions:GetLowestHealthMinion()
		end
		if _G.SxOrb and target == nil then
			target = sxtarget()
		end
		if not target then
			ts:update()
			target = ts.target
		end
		if target and GetDistance(target, myHero) <= VeigarE.range then
			CastE(target, "Laneclear")
		end
	end
	target = nil
end

function CastQ(target, mode)
	if not target or target.dead or myHero.dead or myHero:CanUseSpell(_Q) ~= 0 then return end
	local hs = huge
	local cpred = predictions[Veigar.adv.q.pred]

	if mode == "Combo" then
		hs = Veigar.adv.q.combohs
	elseif mode == "Harras" then
		hs = Veigar.adv.q.harrashs
	elseif mode == "Laneclear" then
		hs = Veigar.adv.q.laneclearhs
	end

	if cpred == "SPrediction" then
		CastPosition, Chance, PredPos = SPred:Predict(target, VeigarQ.range, VeigarQ.speed, VeigarQ.delay, VeigarQ.width, Veigar.adv.q.qallowhit, myHero)
	elseif cpred == "HPrediction" then
		CastPosition, Chance = HPred:GetPredict(HpredQ, target, myHero)
	elseif cpred == "VPrediction" then
		CastPosition, Chance = VPred:GetLineCastPosition(target, VeigarQ.delay, VeigarQ.width, VeigarQ.range, VeigarQ.speed, myHero, Veigar.adv.q.qallowhit, huge)  
	end
	if not Chance or not CastPosition then return end

	if Chance >= hs then
		local hx = CastPosition.x+random(Veigar.other.human.qjitter*-1,Veigar.other.human.qjitter)
		local hz = CastPosition.z+random(Veigar.other.human.qjitter*-1,Veigar.other.human.qjitter)
		if LogicCheck(target,hx,hz) == true then
			local delay = 0
			if Veigar.other.human.qdelay > 1 then
				delay = random(Veigar.other.human.qdelay-1,Veigar.other.human.qdelay-2)
			else
				delay = 0
			end
			DelayAction(function ()
				CastSpell(_Q,hx,hz)
			end, delay)
		end
	end
end

--[[
local VeigarQ = { range = 950, width = 50, speed = 2000, delay = .25, collision = false } --Have to get number of Colliding Enemy's
local VeigarW = { range = 900, width = 112.5, speed = huge, delay = 1.25, collision = false }
local VeigarE = { range = 700, width = 375, speed = huge, delay = .5, collision = false }
local VeigarR = { range = 650, speed = huge, delay = .25, collision = false } --Not a Skillshot
]]
function CastW(target, mode)
	if not target or target.dead or myHero.dead or myHero:CanUseSpell(_W) ~= 0 then return end
	local hs = huge
	local cpred = predictions[Veigar.adv.w.pred]

	if mode == "Combo" then
		hs = Veigar.adv.w.combohs
	elseif mode == "Harras" then
		hs = Veigar.adv.w.harrashs
	elseif mode == "Laneclear" then
		hs = Veigar.adv.w.laneclearhs
	end
	if cpred == "SPrediction" then
		CastPosition, Chance, PredPos = SPred:Predict(target, VeigarW.range, VeigarW.speed, VeigarW.delay, VeigarW.width, false, myHero)
	elseif cpred == "HPrediction" then
		CastPosition, Chance = HPred:GetPredict(HpredW, target, myHero)
	elseif cpred == "VPrediction" then
		CastPosition, Chance = VPred:GetCircularCastPosition(target, VeigarW.delay, VeigarW.width, VeigarW.range, VeigarW.speed, myHero, false)  
	end
	if not Chance or not CastPosition then return end

	if Chance >= hs then
		local hx = CastPosition.x+random(Veigar.other.human.wjitter*-1,Veigar.other.human.wjitter)
		local hz = CastPosition.z+random(Veigar.other.human.wjitter*-1,Veigar.other.human.wjitter)
		if LogicCheck(target,hx,hz) == true then
			local delay = 0
			if Veigar.other.human.wdelay > 1 then
				delay = random(Veigar.other.human.wdelay-1,Veigar.other.human.wdelay-2)
			else
				delay = 0
			end
			DelayAction(function ()
				if target.dead == false then
					CastSpell(_W,hx,hz)
				end
			end, delay)
		end
	end
end

function CastE(target, mode)
	if not target or target.dead or myHero.dead or myHero:CanUseSpell(_E) ~= 0 then return end
	local hs = huge
	local cpred = predictions[Veigar.adv.e.pred]

	if mode == "Combo" then
		hs = Veigar.adv.e.combohs
	elseif mode == "Harras" then
		hs = Veigar.adv.e.harrashs
	elseif mode == "Laneclear" then
		hs = Veigar.adv.e.laneclearhs
	end
	if cpred == "SPrediction" then
		CastPosition, Chance, PredPos = SPred:Predict(target, VeigarE.range, VeigarE.speed, VeigarE.delay, VeigarE.width, false, myHero)
	elseif cpred == "HPrediction" then
		CastPosition, Chance = HPred:GetPredict(HpredE, target, myHero)
	elseif cpred == "VPrediction" then
		CastPosition, Chance = VPred:GetCircularCastPosition(target, VeigarE.delay, VeigarE.width, VeigarE.range, VeigarE.speed, myHero, false)  
	end
	if not Chance or not CastPosition then return end

	if Chance >= hs then
		local hx = CastPosition.x+random(Veigar.other.human.ejitter*-1,Veigar.other.human.ejitter)
		local hz = CastPosition.z+random(Veigar.other.human.ejitter*-1,Veigar.other.human.ejitter)
		if LogicCheck(target,hx,hz) == true then
			local delay = 0
			if Veigar.other.human.edelay > 1 then
				delay = random(Veigar.other.human.edelay-1,Veigar.other.human.edelay-2)
			else
				delay = 0
			end
			DelayAction(function ()
				if target.dead == false then
					CastSpell(_E,hx,hz)
				end
			end, delay)
		end
	end
end

function CastR(target)
	if not target or target.dead or myHero.dead or myHero:CanUseSpell(_R) ~= 0 then return end
	if Veigar.adv.r.kill then
		local lvl = myHero:GetSpellData(_R).level
		local ap = GetAp(myHero)
		local eap = GetAp(target)
		local dmg = 125 + lvl*125 + ap + (eap * 0.8)
		local dmgp = dmg * (100/(100+target.magicArmor))
		dmgp = dmgp - (dmgp * (Veigar.adv.r.buffer/100))
		if debug then
			p("Damage wo Mres: "..dmg)
			p("Damage w Mres: "..dmgp)
			p("Enemy Life: "..target.health)
			p("My AP: "..Game.MyHero().ap)
			p("Target AP: "..target.ap)
			p("Ult lvl: "..Game.MyHero():GetSpellData(3).level)
			p("M res: "..100/(100+target.magicArmor)*100)
			p("Damage w Mres+Buffer: "..dmgp)
		end
		if target.health <= dmgp then
			local delay = 0
			if Veigar.other.human.rdelay > 1 then
				delay = random(Veigar.other.human.edelay-1,Veigar.other.human.rdelay-2)
			else
				delay = 0
			end
			DelayAction(function ()
				if target.dead == false then
					CastSpell(_R,target)
				end
			end, delay)
		end


	else
		local delay = 0
		if Veigar.other.human.rdelay > 1 then
			delay = random(Veigar.other.human.edelay-1,Veigar.other.human.rdelay-2)
		else
			delay = 0
		end
		DelayAction(function () CastSpell(_R, target) end,delay)
	end
end

function LogicCheck(target,hx,hz)
	local chk = true
	if getDistanceC(target.x,target.z,hx,hz) >= Veigar.other.logicchk then
		chk = false
	end
	return chk
end

function sxtarget()
	local eminions = _G.SxOrb.enemyMinions
	local target = nil
	for _,k in pairs(eminions) do
		if target == nil then
			target = k
		else
		if target.health <= k.health then
			target = k
		end
		end
	end
	return target
end
--[[==============================End Script Logic==============================]]--
--[[==============================Start Libary==============================]]--

function p(arg)
	if arg ~= nil then
		print("[S1mple_Veigar] <font color=\"#570BB2\">"..arg.."</font>")
	end
end
function findorbwalker() --Thanks to http://forum.botoflegends.com/user/431842-orianna/ for this Simple solution
	if _G.Reborn_Loaded then
		local SAC=true
		p("Sida's Auto Carry found")
		p("Using SAC:R targets")
		Veigar.other:addParam("sac", "Use SAC:R targets", SCRIPT_PARAM_ONOFF, true)
	elseif not _G.Reborn_Loaded and FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		local SxOrb=true
		require("SxOrbWalk")
		DelayAction(function() Veigar:addSubMenu("SxOrbWalk","orbWalk") end,5)
		DelayAction(function() _G.SxOrb:LoadToMenu(Veigar.orbWalk) end,5)
		p("SxOrbWalk found")
	elseif SAC==false and SxOrb==false then
		p("No Orbwalker found")
		p("If you use MMA or Nebelwolfies, laneclear wont work")
	end
end

function findprediction()
	local strpred = ""
	if FileExist(LIB_PATH.."SPrediction.lua") then
		--require("SPrediction")
		--SPred = SPrediction()
		--strpred = strpred..", ".."SPrediction"
		--table.insert(predictions,"SPrediction")
	end
	if FileExist(LIB_PATH.."HPrediction.lua") then
		--require("HPrediction")
		--HPred = HPrediction()
		--strpred = strpred..", ".."HPrediction"
		--table.insert(predictions,"HPrediction")
		--HpredQ = HPSkillshot({type = "DelayCircle", delay = VeigarQ.delay, range = VeigarQ.range, radius = VeigarQ.width, speed = VeigarQ.speed})
		--HpredW = HPSkillshot({type = "DelayCircle", delay = VeigarW.delay, range = VeigarW.range, radius = VeigarW.width, speed = VeigarW.speed})
		--HpredE = HPSkillshot({type = "DelayCircle", delay = VeigarE.delay, range = VeigarE.range, radius = VeigarE.width, speed = VeigarE.speed})
	end
	if FileExist(LIB_PATH.."VPrediction.lua") then
		require("VPrediction")
		VPred = VPrediction()
		strpred = strpred..", ".."VPrediction"
		table.insert(predictions,"VPrediction")
	end
	p("Available Predictions:")
	strpred = replace_char(1,strpred,"")
	strpred = replace_char(1,strpred,"")
	p(strpred)
end

function perc(current, max)
	if not current or not max then
		p("[ERROR] perc() current or max missing")
		return 100
	end
	return ((current/max)*100)
end

function GetAp(unit) --by Xivia
    local unit = unit or myHero
    return(unit.ap + (unit.ap * unit.apPercent))
end

function getDistanceC(X,Y,X1,Y1)
	--(X-X1)^2+(Z-Z1)^2 <= R^2 if in range
	return sqrt(((X-X1)^2)+((Y-Y1)^2))
end

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

-- Lag free circles (by barasia, vadash and viseversa)
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = max(8,round(180/deg((asin((chordlength/(2*radius)))))))
  quality = 2 * pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * cos(theta), y, z - radius * sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end
function round(num) 
 if num >= 0 then return floor(num+.5) else return ceil(num-.5) end
end
function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, Veigar.draws.lfcthickness, color, Veigar.draws.lfcresolution) 
    end
end


--[[==============================Start Libary==============================]]--
--[[==============================Start Updater==============================]]--


local serveradress = "scarjit.de"
local scriptadress = "/S1mpleScripts/Scripts/BolStudio/Veigar"

function findupdates()
	if not autoupdate then return end
	local ServerVersionDATA = GetWebResult(serveradress , scriptadress.."/S1mple_Veigar.version")
	if ServerVersionDATA then
		local ServerVersion = tonumber(ServerVersionDATA)
		if ServerVersion then
			if ServerVersion > tonumber(LocalVersion) then
				p("Updating S1mple_Veigar, don't press F9")
				update()
			end
		else
			p("An error occured, while updating, please reload")
		end
	else
		p("Could not connect to update Server")
	end
end

function update()
	DownloadFile("http://"..serveradress..scriptadress.."/S1mple_Veigar.lua",SCRIPT_PATH.."S1mple_Veigar.lua", function ()
		p("Updated, press 2xF9")
		updated = true
	end)
end

--[[==============================End Config==============================]]--


