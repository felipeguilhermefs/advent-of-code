local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()
	return content
end

local EMPTY = -1

local function part1(filemap)
	local decompressed = {}
	local isEmpty = false
	local sid = 0
	for char in filemap:gmatch("%d") do
		local digit = tonumber(char)

		for _ = 1, digit do
			if isEmpty then
				table.insert(decompressed, EMPTY)
			else
				table.insert(decompressed, sid)
			end
		end

		if not isEmpty then
			sid = sid + 1
		end

		isEmpty = not isEmpty
	end

	local low, high = 1, #decompressed
	while low < high do
		while decompressed[low] ~= EMPTY and low < high do
			low = low + 1
		end
		while decompressed[high] == EMPTY and high > low do
			high = high - 1
		end

		if low < high then
			local tmp = decompressed[low]
			decompressed[low] = decompressed[high]
			decompressed[high] = tmp
		end
	end

	local checksum = 0
	for i, value in pairs(decompressed) do
		if value == EMPTY then
			break
		end
		checksum = checksum + (i - 1) * value
	end
	return checksum
end

local FILEMAP = readInput()

print("Part 1", part1(FILEMAP))
