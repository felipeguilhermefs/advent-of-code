local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")

local function buildRack(filepath)
	local rack = HashMap.new()
	-- for line in io.lines("sample.in") do
	for line in io.lines(filepath) do
		local key = nil
		for server in line:gmatch("(%a+)") do
			if key == nil then
				key = server
				rack:put(key, Set.new())
			else
				rack:get(key):add(server)
			end
		end
	end
	return rack
end

local function countPaths(rack, from, to, counter)
	if from == to then
		return 1
	end

	if counter:contains(from) then
		return counter:get(from)
	end

	local count = 0

	for output in pairs(rack:get(from, {})) do
		count = count + countPaths(rack, output, to, counter)
	end

	counter:put(from, count)

	return count
end

return function(filepath)
	local rack = buildRack(filepath)

	local part1 = countPaths(rack, "you", "out", HashMap.new())

	local part2 = countPaths(rack, "svr", "fft", HashMap.new())
		* countPaths(rack, "fft", "dac", HashMap.new())
		* countPaths(rack, "dac", "out", HashMap.new())

	return part1, part2
end
