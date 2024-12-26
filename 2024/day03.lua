local function readInput(filepath)
	local f = assert(io.open(filepath, "rb"))
	local memorymap = f:read("*a")
	f:close()
	return memorymap
end

local function part1(memorymap)
	local res = 0
	for base, multiplier in memorymap:gmatch("mul%((%d+),(%d+)%)") do
		res = res + base * multiplier
	end
	return res
end

local function part2(memorymap)
	local res = 0
	local open = true
	for stm, base, multiplier in memorymap:gmatch("([don'tmul]+)%((%d*),*(%d*)%)") do
		if stm == "don't" then
			open = false
		elseif stm == "do" then
			open = true
		elseif stm:match("mul") and open then
			res = res + base * multiplier
		end
	end
	return res
end

return function(filepath)
	local memorymap = readInput(filepath)
	return part1(memorymap), part2(memorymap)
end
