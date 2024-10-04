-- console.log(memory.getmemorydomainlist());

-- #region VRAM Adresses

local tileMapAdresses = {};
local vdpTileMapAdr = 0xC000;--0x0600;

-- #endregion

local tileMapData = {0x00, 0x00, 0x00, 0x00, 0x00, 00, 0x00, 00, 0x00, 00,
 0x00, 00, 0x00, 00, 0x00, 00,
0x00, 01, 0x00, 02, 0x00, 03, 0x00, 03, 0x00, 03, 0x00, 03, 0x00, 03, 0x00, 03,};

-- Инициализация
function UseAndCheckMemoryDomain(memorydomain)
	if memory.usememorydomain(memorydomain) then
		console.log("Using " .. memorydomain);
	else
		console.log("Cant use " .. memorydomain);
	end
end

-- Поиск TileMap данных
function FindTileMapData(tileMapData, memorydomain)
	local memorydomainSize = memory.getmemorydomainsize(memorydomain);
	local startAdr = memorydomainSize - #tileMapData;
	-- цикл от startAdr до 0
	for i = startAdr, 0, -1 do
		if CompareArrays(memory.read_bytes_as_array(i, #tileMapData, memorydomain), tileMapData) then
			return i;
		end
	end
	console.log("Cant find tileMapData in " .. memorydomain);
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

-- #region Main 

UseAndCheckMemoryDomain("VRAM");
-- local tileMapAdresse = FindTileMapData();
-- console.log("tileMapAdresse in VRAM is " .. tileMapAdresse);

local vdpTileMapData = memory.read_bytes_as_array(vdpTileMapAdr, 0x1f);
-- вывести на консоль значения vdpTileMapData
for i = 1, #vdpTileMapData do
	console.log("vdpTileMapData[" .. i .. "] = " .. vdpTileMapData[i]);
end

UseAndCheckMemoryDomain("MD CART");

local tileMapAdress = FindTileMapData(vdpTileMapData, "MD CART");
console.log("tileMapAdresse in MD CART is " .. tileMapAdress);

-- while true do
-- 	-- Code here will run once when the script is loaded, then after each emulated frame.
-- 	emu.frameadvance();
-- end

-- #endregion

