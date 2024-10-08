local function calibration(line)
	local first
	local last
	for digit in string.gmatch(line, "%d") do
		if not first then
			first = digit
		end
		last = digit
	end
	if first then
		return tonumber(first .. last)
	end
	return 0
end

local function part1()
	local result = 0
	for line in io.lines("input.txt") do
		result = result + calibration(line)
	end

	return result
end

local function part2()
	local numbers = {
		["one"] = "o1e",
		["two"] = "t2o",
		["three"] = "t3e",
		["four"] = "4",
		["five"] = "5e",
		["six"] = "6",
		["seven"] = "7n",
		["eight"] = "e8t",
		["nine"] = "n9e",
	}

	local result = 0
	for line in io.lines("input.txt") do
		for number, sub in pairs(numbers) do
			line = string.gsub(line, number, sub)
		end

		result = result + calibration(line)
	end

	return result
end

print("Part 1:", part1())
print("Part 2:", part2())
