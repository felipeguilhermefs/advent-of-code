local function readDays()
	local days = {}
	if arg[1] then
		table.insert(days, tonumber(arg[1]))
	else
		for i = 1, 25 do
			table.insert(days, i)
		end
	end
	return days
end

local function result(filepath)
	local results = {}

	for line in io.lines(filepath) do
		table.insert(results, line)
	end

	return table.unpack(results)
end

local function runDay(d)
	local day = string.format("day%02d", d)
	local run = require(day)

	local part1, part2 = run(day .. ".txt")

	local result1, result2 = result(day .. ".res")

	assert(tostring(part1) == result1, string.format("Error part 1, expected %s got %s", result1, part1))
	assert(tostring(part2) == result2, string.format("Error part 2, expected %s got %s", result2, part2))

	print(string.format("Day %02d OK", d))
end

local function main()
	local days = readDays()
	for _, day in pairs(days) do
		runDay(day)
	end
end

main()
