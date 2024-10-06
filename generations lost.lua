-- #region RAM Adresses

local timerNextScreen = 0xBCAB

-- #endregion

local prevCRAM = nil

-- функция которая переключает между памятными доменами
function UseAndCheckMemoryDomain(memorydomain)
	if memory.usememorydomain(memorydomain) then
		console.log("Using " .. memorydomain);
	else
		console.log("Cant use " .. memorydomain);
	end
end

-- функция которая сравнивает 2 массива
function CompareArrays(array1, array2)
	if #array1 ~= #array2 then
		return false
	end
	for i = 1, #array1 do
		if array1[i] ~= array2[i] then
			return false
		end
	end
	return true
end

function init()
    client.reboot_core()
end

init()

local offset = 0xEAEC2

while true do
    -- console.log("memory.getcurrentmemorydomain() = " .. memory.getcurrentmemorydomain());
    -- if memory.getcurrentmemorydomain() == "68K RAM" then
        
        if emu.framecount() % 50 == 0 then            
            -- UseAndCheckMemoryDomain("CRAM");
            local curCRAM = memory.read_bytes_as_array(0, memory.getmemorydomainsize("CRAM"), "CRAM")
            -- console.writeline(curCRAM)
            if prevCRAM == nil then
                prevCRAM = curCRAM
            end
            if CompareArrays(prevCRAM, curCRAM) then
                prevCRAM = curCRAM
            else
                console.log("offset =" .. offset)
                console.log("DONE")
                client.pause()
                -- prevCRAM = curCRAM
            end
            memory.write_s16_be(offset, 0x0000, "MD CART")
            offset = offset - 2
            client.reboot_core()
        end
    -- else
    --     UseAndCheckMemoryDomain("68K RAM");
    -- end
    emu.frameadvance();
end