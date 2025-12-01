local function parse(filepath)
	local f = assert(io.open(filepath, "rb"), "Open File")
	local content = f:read("*a")
	f:close()
	return content:gmatch("(%a)(%d+)")
end

return function(filepath)
	local zeros, loops = 0, 0
	local position = 50
	for direction, ticks in parse(filepath) do
		if direction == "L" then
			ticks = ticks * -1
		end

		local next = position + ticks

		loops = loops + math.abs(next) // 100
		if position > 0 and next <= 0 then
			loops = loops + 1
		end

		position = next % 100

		if position == 0 then
			zeros = zeros + 1
		end
	end

	return zeros, loops
end
