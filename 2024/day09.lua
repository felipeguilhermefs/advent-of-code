local EMPTY = -1

local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()
	return content
end

local function unzipIndexed(filemap)
	local disk = {}
	local indexFree = {}
	local indexFiles = {}
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
			table.insert(indexFree, { index = #disk + 1 - digit, size = digit, sid = EMPTY })
		else
			table.insert(indexFiles, { index = #disk + 1 - digit, size = digit, sid = sid })
			sid = sid + 1
		end

		isFree = not isFree
	end

	return disk, indexFiles, indexFree
end

local function defrag(disk)
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

local function defragIndexFiles(indexFiles, indexFree)
	-- Look from last file to first
	for i = #indexFiles, 1, -1 do
		local file = indexFiles[i]

		-- Look at every empty space
		for j = 1, #indexFree do
			local free = indexFree[j]

			-- We only care about free space before the file
			if free.index >= file.index then
				break
			end

			-- File should fit the empty space
			if file.size <= free.size then
				-- Move the file to empty space
				file.index = free.index

				-- Update the free space index
				free.size = free.size - file.size
				free.index = free.index + file.size

				-- We are done for this file
				break
			end
		end
	end
end

local function checksum(disk)
	local sum = 0
	for i, sid in pairs(disk) do
		if sid ~= EMPTY then
			sum = sum + (i - 1) * sid
		end
	end
	return sum
end

local function checksumIndex(indexFiles)
	local sum = 0

	for _, file in pairs(indexFiles) do
		for i = file.index, file.index + file.size - 1 do
			sum = sum + (i - 1) * file.sid
		end
	end

	return sum
end

local function run()
	local filemap = readInput()
	local disk, indexFiles, indexFree = unzipIndexed(filemap)

	defrag(disk)

	defragIndexFiles(indexFiles, indexFree)

	return checksum(disk), checksumIndex(indexFiles)
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
