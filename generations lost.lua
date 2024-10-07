-- #region RAM Adresses

local timerNextScreen = 0xBCAB

-- #endregion

-- #region ROM Adresses

local headerEnd = 0x220

-- #endregion

local prevCRAM = {}

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
    
    if client.ispaused() then
        client.unpause()
    end
end

init()

local offset = 0xE60F2
-- local offset = 0xaec9b
memory.write_s16_be(offset, 0x0000, "MD CART")

while true do
    -- console.log("memory.getcurrentmemorydomain() = " .. memory.getcurrentmemorydomain());
    -- console.writeline(curCRAM)
    
    if memory.read_s16_be(offset) == 0x0000 then
        offset = offset - 2            
    end

    if offset == headerEnd then
        console.log("Reach header")
        break
    end

    if emu.framecount() % 30 == 0 and emu.framecount() ~= 0 then            
        local curCRAM = memory.read_bytes_as_array(0, memory.getmemorydomainsize("CRAM"), "CRAM")

        if #prevCRAM == 0  then
            for i = 1, #curCRAM do
                prevCRAM[i] = curCRAM[i]
            end
        end

        if CompareArrays(prevCRAM, curCRAM) then
            prevCRAM = curCRAM
            console.log("offset =" .. string.format("%x", offset))
        else
            console.log("prevCRAM =")
            console.writeline(prevCRAM)
            console.log("curCRAM =")
            console.writeline(curCRAM)
            console.log("offset =" .. string.format("%x", offset))
            console.log("DONE")
            break
            -- client.pause()
        end
        client.reboot_core()
        memory.write_s16_be(offset, 0x0000, "MD CART")
        offset = offset - 2
    end
    emu.frameadvance();
end