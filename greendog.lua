-- данный скрипт должен случайно переключать уровни между 0x0D и 0x14

local rb     = mainmemory.read_u8
local wb     = mainmemory.writebyte
local rbrom     = memory.read_u8
local rbsrom    = memory.read_s8

console.log("\nstart")
local newLvl = 0x00--rb(0x15)
local levels = {0x0D,0x14}
while true do
	lvl=rb(0x15)
	if lvl > 9 and lvl~=newLvl then
		while newLvl==0 or newLvl==0x12 or newLvl==0x13 do
			newLvl=math.random(0x0A,0x1E);
		end		
		console.log("\nnewLvl: "..newLvl)
		wb(0x15,newLvl)
	end
	--console.log()
	emu.frameadvance()
end