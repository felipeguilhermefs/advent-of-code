local unpack = unpack or table.unpack

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

	return unpack(results)
end

local function runDay(d)
	local day = string.format("day%02d", d)
	local run = require(day)

	local part1, part2 = run(day .. ".in")

	local result1, result2 = result(day .. ".out")

	print("\n#############################")
	print(string.format("Day %02d:", d))
	if tostring(part1) == result1 then
		print("\tPart 1 OK")
	else
		print(string.format("\tPart 1 ERROR: Expected %s, got %s", result1, part1))
	end
	if tostring(part2) == result2 then
		print("\tPart 2 OK")
	else
		print(string.format("\tPart 2 ERROR: Expected %s, got %s", result2, part2))
	end
	print("#############################\n")
end

local function main()
	local days = readDays()
	for _, day in pairs(days) do
		runDay(day)
	end
end

main()
