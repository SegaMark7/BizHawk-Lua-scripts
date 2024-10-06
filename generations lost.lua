-- #region RAM Adresses

local timerNextScreen = 0xBCAB

-- #endregion

function UseAndCheckMemoryDomain(memorydomain)
	if memory.usememorydomain(memorydomain) then
		console.log("Using " .. memorydomain);
	else
		console.log("Cant use " .. memorydomain);
	end
end


while true do
    -- console.log("memory.getcurrentmemorydomain() = " .. memory.getcurrentmemorydomain());
    if memory.getcurrentmemorydomain() == "68K RAM" then
        
        if emu.framecount() % 50 == 0 then            
            -- console.log("emu.framecount() = " .. emu.framecount());
            client.reboot_core()
        end
    else
        UseAndCheckMemoryDomain("68K RAM");
    end
    emu.frameadvance();
end