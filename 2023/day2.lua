local function part1()
	local game = 0
	local result = 0
	local cubes = { ["red"] = 12, ["green"] = 13, ["blue"] = 14 }
	for line in io.lines("input2.txt") do
		game = game + 1

		local valid = true
		for n, color in line:gmatch("(%d+) (%w+)") do
			local count = tonumber(n)
			if count > cubes[color] then
				valid = false
			end
		end
		if valid then
			result = result + game
		end
	end
	return result
end

local function part2()
	local result = 0
	for line in io.lines("input2.txt") do
		local cubes = { ["red"] = 1, ["green"] = 1, ["blue"] = 1 }

		for n, color in line:gmatch("(%d+) (%w+)") do
			local count = tonumber(n)
			if count > cubes[color] then
				cubes[color] = count
			end
		end
		local power = cubes["red"] * cubes["green"] * cubes["blue"]
		result = result + power
	end
	return result
end

print("Part 1:", part1())
print("Part 2:", part2())
