local N = { -1, 0 }
local E = { 0, 1 }
local S = { 1, 0 }
local W = { 0, -1 }

N.next = E
E.next = S
S.next = W
W.next = N

local DIR = {
	["^"] = N,
	[">"] = E,
	["v"] = S,
	["<"] = W,
}

local BLOCK = "#"
local VISITED = "X"

local function readInput()
	local map = {}
	local guard
	for line in io.lines(arg[1]) do
		local row = {}
		for pos in line:gmatch(".") do
			if guard == nil then
				local dir = DIR[pos]
				if dir then
					guard = { row = #map + 1, col = #row + 1, dir = dir }
				end
			end
			row[#row + 1] = pos
		end
		map[#map + 1] = row
	end
	return map, assert(guard)
end

local function inMap(map, row, col)
	if row < 1 or row > #map then
		return false
	end

	if col < 1 or col > #map[row] then
		return false
	end

	return true
end

local function markPath(map, guard)
	local distance = 0
	local row, col, dir = guard.row, guard.col, guard.dir
	while inMap(map, row, col) do
		local nextRow, nextCol = row + dir[1], col + dir[2]

		if inMap(map, nextRow, nextCol) and map[nextRow][nextCol] == BLOCK then
			dir = dir.next
		end

		if map[row][col] ~= VISITED then
			map[row][col] = VISITED
			distance = distance + 1
		end

		row = row + dir[1]
		col = col + dir[2]
	end

	return distance
end

local function isLoop(map, guard)
	local path = {}
	local row, col, dir = guard.row, guard.col, guard.dir
	while inMap(map, row, col) do
		local key = string.format("%d:%d:%d:%d", row, col, dir[1], dir[2])
		if path[key] then
			return true
		end

		local nextRow, nextCol = row + dir[1], col + dir[2]

		if inMap(map, nextRow, nextCol) and map[nextRow][nextCol] == BLOCK then
			dir = dir.next
		else
			path[key] = true
			row = row + dir[1]
			col = col + dir[2]
		end

	end

	return false
end

local function countLoops(map, guard)
	local count = 0
	for row, _ in pairs(map) do
		for col, pos in pairs(map[row]) do
			if pos ~= VISITED then
				goto continue
			end

			if row == guard.row and col == guard.col then
				goto continue
			end

			map[row][col] = BLOCK
			if isLoop(map, guard) then
				count = count + 1
			end
			map[row][col] = pos

			::continue::
		end
	end
	return count
end

local function run()
	local map, guard = readInput()
	local distance = markPath(map, guard)

	return distance, countLoops(map, guard)
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
