local function add(a, b)
	return a + b
end
local function mul(a, b)
	return a * b
end
local function concat(a, b)
	return tonumber(a .. b)
end

local function readInput(filepath)
	local records = {}
	for line in io.lines(filepath) do
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
		if isPossible(ops, values, expected, op(actual, values[i]), i + 1) then
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

return function(filepath)
	local records = readInput(filepath)

	return run(records, { add, mul }), run(records, { add, mul, concat })
end
