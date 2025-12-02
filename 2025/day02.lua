local function parse(filepath)
	local f = assert(io.open(filepath, "rb"), "Open File")
	local content = f:read("*a")
	f:close()
	return content:gmatch("(%d+)-(%d+)")
end

--Replicate a sequence a number of times
local function replicate(seq, times)
	local comb = {}
	for _ = 1, times do
		table.insert(comb, seq)
	end
	return tonumber(table.concat(comb))
end

-- Generate invalid ids after low boundary
local function generate(low, parts)
	local seq = tonumber(low:sub(1, math.floor(#low / parts))) or 1

	return function()
		local id = replicate(seq, parts)
		seq = seq + 1
		return id
	end
end

-- Sum invalid IDs spliting parts
local function sum(low, high, from_parts, to_parts)
	local total = 0

	local min, max = tonumber(low), tonumber(high)

	local seen = {}
	for split = from_parts, to_parts do
		for id in generate(low, split) do
			if id >= min and id <= max and not seen[id] then
				seen[id] = true
				total = total + id
			end

			if id > max then
				break
			end
		end
	end

	return total
end

return function(filepath)
	local part1 = 0
	local part2 = 0
	for low, high in parse(filepath) do
		part1 = part1 + sum(low, high, 2, 2)
		part2 = part2 + sum(low, high, 2, #high)
	end

	return part1, part2
end
