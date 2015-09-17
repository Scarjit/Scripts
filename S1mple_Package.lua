version = "1.0"
function OnLoad()
	print("Scarjit's Package Listener Version"..version)
end



local fileName = "packetdump.txt"

function toHex(int)
    return "0x"..string.format("%04X ",int)
end

function OnRecvPacket(p)
if p:DecodeF() == myHero.networkID then
	if p.header ~= 0x007E then
        print("Received packet " .. toHex(p.header))
		
		b_infile = false
		
        local file = io.open(SCRIPT_PATH .. fileName, "a")
		while true do
			line = file:read()
			if line == nil then break end
				print(line)
				if string.find(line, toHex(p.header)) then
					b_infile = true
				end
				
				if b_infile == false then
					file:write(toHex(p.header).."\n")
				end
			end	
		
		
		
        --file:write(DumpPacketData(p))
        file:close()
	end
	end
end