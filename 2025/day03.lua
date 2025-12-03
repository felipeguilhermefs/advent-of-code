local ASCII_ZERO = 48

local function int(byte, sig)
	return (byte - ASCII_ZERO) * math.pow(10, sig - 1)
end

local function maxout(line, count)
	local index = 1
	local result = 0
	for position = count, 1, -1 do
		local max = index
		for i = index, #line - position + 1 do
			if line:byte(i) > line:byte(max) then
				max = i
			end
		end

		result = result + int(line:byte(max), position)

		index = max + 1
	end
	return result
end

return function(filepath)
	local part1, part2 = 0, 0
	for line in io.lines(filepath) do
		part1 = part1 + maxout(line, 2)
		part2 = part2 + maxout(line, 12)
	end
	return part1, string.format("%12.0f", part2)
end
