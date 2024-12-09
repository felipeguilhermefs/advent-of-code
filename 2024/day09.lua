local EMPTY = -1

local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()
	return content
end

local function unzip(filemap)
	local disk = {}
	local isEmpty = false
	local sid = 0
	for char in filemap:gmatch("%d") do
		local digit = tonumber(char)

		for _ = 1, digit do
			if isEmpty then
				table.insert(disk, EMPTY)
			else
				table.insert(disk, sid)
			end
		end

		if not isEmpty then
			sid = sid + 1
		end

		isEmpty = not isEmpty
	end
	return disk
end

local function unzipIndexed(filemap)
	local disk = {}
	local free = {}
	local files = {}
	local isFree = false
	local sid = 0

	for char in filemap:gmatch("%d") do
		local digit = tonumber(char)

		for _ = 1, digit do
			if isFree then
				table.insert(disk, EMPTY)
			else
				table.insert(disk, sid)
			end
		end

		-- Keep index and size of each space.
		if isFree then
			table.insert(free, { #disk + 1 - digit, digit, EMPTY })
		else
			table.insert(files, { #disk + 1 - digit, digit, sid })
			sid = sid + 1
		end

		isFree = not isFree
	end

	return disk, files, free
end

local function defragFull(disk)
	local low, high = 1, #disk
	while low < high do
		-- Low looks for empty spaces
		while disk[low] ~= EMPTY and low < high do
			low = low + 1
		end
		-- High looks for non empty spaces
		while disk[high] == EMPTY and high > low do
			high = high - 1
		end

		-- move non empty space to empty space
		if low < high then
			local tmp = disk[low]
			disk[low] = disk[high]
			disk[high] = tmp
		end
	end
end

local function defragKeepFiles(disk, files, free)
	-- Look from last file to first
	for i = #files, 1, -1 do
		local file = files[i]

		-- Look at every empty space
		for j = 1, #free do
			local empty = free[j]

			-- File should fit and be after empty space for the left shift
			if empty[1] < file[1] and file[2] <= empty[2] then
				-- Copy the file to empty space
				for k = empty[1], empty[1] + file[2] - 1 do
					disk[k] = file[3]
				end
				-- Free the previous file space
				for k = file[1], file[1] + file[2] - 1 do
					disk[k] = EMPTY
				end

				-- Update the free space index
				empty[2] = empty[2] - file[2]
				empty[1] = empty[1] + file[2]

				-- We are done for this file
				break
			end
		end
	end
end

local function checksum(arr)
	local sum = 0
	for i, value in pairs(arr) do
		if value ~= EMPTY then
			sum = sum + (i - 1) * value
		end
	end
	return sum
end

local function part1(filemap)
	local disk = unzip(filemap)

	defragFull(disk)

	return checksum(disk)
end

local function part2(filemap)
	local disk, files, free = unzipIndexed(filemap)

	defragKeepFiles(disk, files, free)

	return checksum(disk)
end

local FILEMAP = readInput()
print("Part 1", part1(FILEMAP))
print("Part 2", part2(FILEMAP))
