local function buildRack(filepath)
	local rack = {}
	for line in io.lines(filepath) do
		local key = nil
		for server in line:gmatch("(%a+)") do
			if key == nil then
				key = server
				rack[key] = {}
			else
				table.insert(rack[key], server)
			end
		end
	end
	return rack
end

local function countPaths(rack, from, to, counter)
	if from == to then
		return 1
	end

	counter = counter or {}
	if counter[from] then
		return counter[from]
	end

	local count = 0
	local outputs = rack[from] or {}

	for _, output in pairs(outputs) do
		count = count + countPaths(rack, output, to, counter)
	end

	counter[from] = count

	return count
end

return function(filepath)
	local rack = buildRack(filepath)

	local part1 = countPaths(rack, "you", "out")

	local part2 = countPaths(rack, "svr", "fft") * countPaths(rack, "fft", "dac") * countPaths(rack, "dac", "out")

	return part1, part2
end
