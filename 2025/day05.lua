local RangeTree = require("ff.collections.rangetree")

return function(filepath)
	local ranges = RangeTree.new()

	local part1 = 0
	local buildingRanges = true
	for line in io.lines(filepath) do
		if line == "" then
			buildingRanges = false
			goto continue
		end

		if buildingRanges then
			local low, high = line:match("(%d+)-(%d+)")
			ranges:insert(tonumber(low), tonumber(high))
		else
			if ranges:contains(tonumber(line)) then
				part1 = part1 + 1
			end
		end

		::continue::
	end

	local part2 = 0
	for low, high in pairs(ranges) do
		part2 = part2 + high - low + 1
	end

	return part1, part2
end
