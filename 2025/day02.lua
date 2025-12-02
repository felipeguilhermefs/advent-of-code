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
local function generate(low, times)
	local seq = tonumber(low:sub(1, #low // times)) or 1

	return function()
		local id = replicate(seq, times)
		seq = seq + 1
		return id
	end
end

local function part1(filepath)
	local sum = 0

	for low, high in parse(filepath) do
		local min, max = tonumber(low), tonumber(high)

		for id in generate(low, 2) do
			if id >= min and id <= max then
				sum = sum + id
			end

			if id > max then
				break
			end
		end
	end

	return sum
end

local function part2(filepath)
	local sum = 0

	for low, high in parse(filepath) do
		local min, max = tonumber(low), tonumber(high)

		local seen = {}
		for split = 2, #high do
			for id in generate(low, split) do
				if id >= min and id <= max and not seen[id] then
					seen[id] = true
					sum = sum + id
				end

				if id > max then
					break
				end
			end
		end
	end

	return sum
end

return function(filepath)
	return part1(filepath), part2(filepath)
end
