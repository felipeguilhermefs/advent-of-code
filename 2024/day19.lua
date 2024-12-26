local HashMap = require("ff.collections.hashmap")

local function readInput(filepath)
	local patterns, designs = HashMap.new(), {}
	for line in io.lines(filepath) do
		if #patterns == 0 then
			for pattern in line:gmatch("%a+") do
				local prefix = pattern:sub(1, 1)
				local suffixes = patterns:get(prefix, {})
				table.insert(suffixes, pattern)
				patterns:put(prefix, suffixes)
			end
		elseif line ~= "" then
			table.insert(designs, line)
		end
	end

	return patterns, designs
end

local function countPossible(design, patterns, cache)
	if design == "" then
		return 1
	end

	return cache:compute(design, function()
		local total = 0
		local prefix = design:sub(1, 1)
		local prefixes = patterns:get(prefix, {})
		for _, pattern in pairs(prefixes) do
			if design:match("^" .. pattern) then
				local suffix = design:sub(#pattern + 1)
				local count = countPossible(suffix, patterns, cache)
				total = total + count
			end
		end

		return total
	end)
end

return function(filepath)
	local patterns, designs = readInput(filepath)

	local cache = HashMap.new()
	local count, total = 0, 0
	for _, design in pairs(designs) do
		local possible = countPossible(design, patterns, cache)
		if possible > 0 then
			count = count + 1
		end
		total = total + possible
	end
	return count, total
end
