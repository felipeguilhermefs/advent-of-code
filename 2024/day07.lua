local ADD = "+"
local MUL = "*"
local CONCAT = "||"

local EXEC = {
	[ADD] = function(a, b)
		return a + b
	end,
	[MUL] = function(a, b)
		return a * b
	end,
	[CONCAT] = function(a, b)
		return tonumber(a .. b)
	end,
}

local function readInput()
	local records = {}
	for line in io.lines(arg[1]) do
		local values = {}
		for value in line:gmatch("(%d+)") do
			table.insert(values, tonumber(value))
		end
		table.insert(records, values)
	end
	return records
end

local function isPossible(ops, values, expected, actual, i)
	if actual > expected then
		return false
	end

	if i > #values then
		return actual == expected
	end

	for _, op in pairs(ops) do
		if isPossible(ops, values, expected, EXEC[op](actual, values[i]), i + 1) then
			return true
		end
	end
	return false
end

local function run(records, ops)
	local sum = 0
	for _, values in pairs(records) do
		if isPossible(ops, values, values[1], values[2], 3) then
			sum = sum + values[1]
		end
	end
	return string.format("%0.f", sum)
end

local RECORDS = readInput()

print("Part1", run(RECORDS, { ADD, MUL }))
print("Part2", run(RECORDS, { ADD, MUL, CONCAT }))
