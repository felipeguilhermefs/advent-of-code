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

local function part2(filemap)
	local decompressed = {}
	local free = {}
	local files = {}
	local isFree = false
	local sid = 0

	for char in filemap:gmatch("%d") do
		local digit = tonumber(char)

		for _ = 1, digit do
			if isFree then
				table.insert(decompressed, EMPTY)
			else
				table.insert(decompressed, sid)
			end
		end

		if isFree then
			table.insert(free, { #decompressed + 1 - digit, digit, EMPTY })
		else
			table.insert(files, { #decompressed + 1 - digit, digit, sid })
			sid = sid + 1
		end

		isFree = not isFree
	end

	for i = #files, 1, -1 do
		local file = files[i]

		for j = 1, #free do
			local empty = free[j]
			if empty[1] < file[1] and file[2] <= empty[2] then
				for k = empty[1], empty[1] + file[2] - 1 do
					decompressed[k] = file[3]
				end
				for k = file[1], file[1] + file[2] - 1 do
					decompressed[k] = EMPTY
				end
				empty[2] = empty[2] - file[2]
				empty[1] = empty[1] + file[2]
				break
			end
		end
	end

	local checksum = 0
	for i, value in pairs(decompressed) do
		if value ~= EMPTY then
			checksum = checksum + (i - 1) * value
		end
	end
	return checksum
end

print("Part 1", part1(FILEMAP))
print("Part 2", part2(FILEMAP))
