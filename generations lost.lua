-- #region RAM Adresses

local timerNextScreen = 0xBCAB

-- #endregion

-- #region ROM Adresses

local headerEnd = 0x220
local usefullMemoryEnd = 0xEAEC3

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

-- Копирование массива с помощью встроенной функции
local function CopyArray(source)
	local dest = {}
	for i = 1, #source do
		dest[i] = source[i]
	end
	return dest
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

-- Функция для создания массива из нулей заданного размера
local function CreateZeroArray(size)
	local zeroArray = {}
	for i = 1, size do
		zeroArray[i] = 0x00
	end
	return zeroArray
end

function init()
    client.reboot_core()
    
    if client.ispaused() then
        client.unpause()
    end
end

init()

-- Вычисляем размер диапазона и 10% от него
local range = usefullMemoryEnd - headerEnd
local sizeToWrite = math.floor(range * 0.1)  -- Размер массива, который будет записан (10% от диапазона)

-- Создаём массив из 0x00 размером 10% от диапазона
-- local zeroArray = CreateZeroArray(sizeToWrite)


local offset = usefullMemoryEnd
-- local offset = 0xb7cf4
-- local offset = 0xd1760
-- local offset = 0xE60F2
-- local offset = 0xaec9b
-- memory.write_s32_be(offset, 0x00000000, "MD CART")

while true do
    -- console.log("memory.getcurrentmemorydomain() = " .. memory.getcurrentmemorydomain());
    
    -- if memory.read_s32_be(offset) == 0x00000000 then
    --     offset = offset - sizeToWrite            
    -- end

    if offset <= headerEnd then
        console.log("usefullMemory header")
        break
    end

    if emu.framecount() % 30 == 0 and emu.framecount() ~= 0 then            
        local curCRAM = memory.read_bytes_as_array(0, memory.getmemorydomainsize("CRAM"), "CRAM")

        if #prevCRAM == 0  then
            prevCRAM = CopyArray(curCRAM)    
        end

        if CompareArrays(prevCRAM, curCRAM) then
            prevCRAM = CopyArray(curCRAM)
            console.log("offset = " .. string.format("%x", offset))
        else
            console.log("prevCRAM =")
            console.writeline(prevCRAM)
            console.log("curCRAM =")
            console.writeline(curCRAM)
            console.log("offsetDec = " .. offset)
            console.log("offsetHex = $" .. string.format("%x", offset) .. "-$" .. string.format("%x", offset+sizeToWrite))
            console.log("length = $" .. string.format("%x", sizeToWrite) .. "(" .. sizeToWrite .. ")")
            console.log("DONE")
            -- client.pause()
            prevCRAM = {}
            offset = offset + sizeToWrite
            if sizeToWrite <= 1 then
                break                
            end
            sizeToWrite = math.floor(sizeToWrite/2)
        end
        client.reboot_core()
        memory.write_bytes_as_array(offset, CreateZeroArray(sizeToWrite), "MD CART")
        offset = offset - sizeToWrite
    end
    emu.frameadvance();
end