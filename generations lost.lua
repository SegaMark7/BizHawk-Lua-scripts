-- #region RAM Adresses

local timerNextScreen = 0xBCAB

-- #endregion

-- #region ROM Adresses

local headerEnd = 0x220
local usefullMemoryEnd = 0xEAEC3

-- #endregion

local OrigCRAM = {}

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

local function isAllZeros(array)
    for _, value in ipairs(array) do
        if value ~= 0 then
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

local index = 0
local UsefullOffset = {}

-- Вычисляем размер диапазона и 10% от него
local range = usefullMemoryEnd - headerEnd
local sizeToWrite = math.floor(range * 0.1)  -- Размер массива, который будет записан (10% от диапазона)

-- Создаём массив из 0x00 размером 10% от диапазона
-- local zeroArray = CreateZeroArray(sizeToWrite)

local startOffset = headerEnd
local curOffset = headerEnd
local endOffset = usefullMemoryEnd
-- local offset = usefullMemoryEnd
-- local offset = 0xb7cf4
-- local offset = 0xd1760
-- local offset = 0xE60F2
-- local offset = 0xaec9b
-- memory.write_s32_be(offset, 0x00000000, "MD CART")
memory.write_bytes_as_array(curOffset, CreateZeroArray(sizeToWrite), "MD CART")

while true do
    -- console.log("Scanning with sizeToWrite = " .. sizeToWrite)
    -- console.log("memory.getcurrentmemorydomain() = " .. memory.getcurrentmemorydomain());  

    if emu.framecount() % 30 == 0 and emu.framecount() ~= 0 then 
        
        
        
        local curCRAM = memory.read_bytes_as_array(0, memory.getmemorydomainsize("CRAM"), "CRAM")
        
        
        -- if isAllZeros(curCRAM) then
        --     console.log("MudaOffset = $" .. string.format("%x", curOffset) .. "-$" .. string.format("%x", curOffset+sizeToWrite))                
        --     goto continue
        -- end
        
        
        if #OrigCRAM == 0 and not isAllZeros(curCRAM) then
            OrigCRAM = CopyArray(curCRAM)  
            -- console.log("OrigCRAM = CopyArray(curCRAM)")
        end

        if CompareArrays(OrigCRAM, curCRAM) then
            
            -- OrigCRAM = CopyArray(curCRAM)
            
            console.log("MudaOffset = $" .. string.format("%x", curOffset) .. "-$" .. string.format("%x", curOffset+sizeToWrite))                
            -- console.log("curCRAM =")
            -- console.writeline(curCRAM)
            -- console.log("prevCRAM =")
            -- console.writeline(OrigCRAM)
        else
            TempOffset={}
            TempOffset.startAdr = curOffset
            TempOffset.endAdr = curOffset+sizeToWrite
            table.insert(UsefullOffset, TempOffset)

            console.log("UsefullOffsetDec = " .. curOffset .. "-" .. curOffset+sizeToWrite)
            console.log("UsefullOffsetHex = $" .. string.format("%x", curOffset) .. "-$" .. string.format("%x", curOffset+sizeToWrite))
            console.log("length = $" .. string.format("%x", sizeToWrite) .. "(" .. sizeToWrite .. ")")
            console.log("prevCRAM =")
            console.writeline(OrigCRAM)
            console.log("curCRAM =")
            console.writeline(curCRAM)
 
        end

        ::continue::
        if curOffset >= endOffset then
            console.log("index = " .. index)
            console.log("sizeToWrite= " .. sizeToWrite)
            console.log("#UsefullOffset = " .. #UsefullOffset)
            index = index + 1
            if index > #UsefullOffset then
                console.log("#UsefullOffset > index")
                index = 0            
                UsefullOffset = {}
                sizeToWrite = math.floor(sizeToWrite/2)
                
                if sizeToWrite <= 1 then
                    break
                end
            else
                curOffset = UsefullOffset[index].startAdr
                endOffset = UsefullOffset[index].endAdr
            end
    
        else 
            curOffset = curOffset + sizeToWrite
        end

        client.reboot_core()
        memory.write_bytes_as_array(curOffset, CreateZeroArray(sizeToWrite), "MD CART")
        
    end
    emu.frameadvance();
end

console.log("DONE");