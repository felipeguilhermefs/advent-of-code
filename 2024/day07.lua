local function isPossible(test, values, i, acc)
	acc = acc or 0
	i = i + 1
	if acc == test then
		return true
	end

	if acc > test then
		return false
	end

	if i > #values then
		return false
	end

	if isPossible(test, values, i, (acc or 0) + values[i]) then
		return true
	end

	return isPossible(test, values, i, (acc or 1) * values[i])
end

local function part1()
	local sum = 0
	for line in io.lines(arg[1]) do
		local test = {}
		for value in line:gmatch("(%d+)") do
			table.insert(test, tonumber(value))
		end
		if isPossible(test[1], test, 1) then
			sum = sum + test[1]
		end
	end
	return sum
end

print("Part1", part1())
