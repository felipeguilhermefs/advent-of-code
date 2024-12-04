local f = assert(io.open(arg[1], "rb"))
local memorymap = f:read("*a")
f:close()

local function part1()
	local res = 0
	for base, multiplier in memorymap:gmatch("mul%((%d+),(%d+)%)") do
		res = res + base * multiplier
	end
	return res
end

local function part2()
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

print("Part 1", part1())
print("Part 2", part2())
