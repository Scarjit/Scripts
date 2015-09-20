--[[
	S1mple Lissandra
]]--

myHero = GetMyHero()
if myHero.charName ~= "Lissandra" then return end
require "VPrediction"


local version = "1.0"
local autoupdate = false
local chkupdates = false
local Update_HOST = "raw.github.com"
local Update_PATH = "/Scarjit/Scripts/master/S1mple_Lissandra.lua?rand="..math.random(1,10000)
local Update_FILE_PATH = "S1mple_Lissandra.lua"
local Changelog_PATH = "/Scarjit/Scripts/master/S1mple_Lissandra.changelog?rand="..math.random(1,10000)
local Update_URL = "https://"..Update_HOST..Update_PATH

function Update()
	if not autoupdate then 
		p("Autoupdate's disabled")
	return 
	end
		p("Updating S1mple_Ziggs")
		local ServerData = GetWebResult(Update_HOST, "/Scarjit/Scripts/master/S1mple_Lissandra.version")
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
			local ServerData = GetWebResult(Update_HOST, "/Scarjit/Scripts/master/S1mple_Lissandra.version")
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

function p(arg)
	print("<font color=\"#570BB2\">"..arg.."</font>")
end	

function CreateConfig()

end

function OnLoad()
	p("S1mple_Lissandra Version</font> "..version.." <font color=\"#570BB2\">loading</font>")
	ChkUpdate()
	Update()
	CreateConfig()
	p("S1mple_Lissandra loaded")
end	

function OnTick()
	
end

function OnDraw()
	
end

function CastQ()

end

function CastW()

end

function CastE()

end

function CastR()

end
