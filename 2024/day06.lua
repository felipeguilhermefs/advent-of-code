local Set = require("ff.collections.set")
local Matrix = require("matrix")

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

local function readInput(filepath)
	local map = {}
	local guard
	for line in io.lines(filepath) do
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
	return Matrix.new(map), assert(guard)
end

local function markPath(map, guard)
	local distance = 0
	local row, col, dir = guard.row, guard.col, guard.dir
	while map:contains(row, col) do
		local nextRow, nextCol = row + dir[1], col + dir[2]

		if map:contains(nextRow, nextCol) and map._m[nextRow][nextCol] == BLOCK then
			dir = dir.next
		end

		if map._m[row][col] ~= VISITED then
			map._m[row][col] = VISITED
			distance = distance + 1
		end

		row = row + dir[1]
		col = col + dir[2]
	end

	return distance
end

local function isLoop(map, guard)
	local path = Set.new()
	local row, col, dir = guard.row, guard.col, guard.dir
	while map:contains(row, col) do
		local key = string.format("%d:%d:%d:%d", row, col, dir[1], dir[2])
		if path:contains(key) then
			return true
		end

		local nextRow, nextCol = row + dir[1], col + dir[2]

		if map:contains(nextRow, nextCol) and map._m[nextRow][nextCol] == BLOCK then
			dir = dir.next
		else
			path:add(key)
			row = row + dir[1]
			col = col + dir[2]
		end

	end

	return false
end

local function countLoops(map, guard)
	local count = 0
	for _, cell in pairs(map) do
		if cell.value ~= VISITED then
			goto continue
		end

		if cell.row == guard.row and cell.col == guard.col then
			goto continue
		end

		map._m[cell.row][cell.col] = BLOCK
		if isLoop(map, guard) then
			count = count + 1
		end
		map._m[cell.row][cell.col] = cell.value

		::continue::
	end
	return count
end

return function (filepath)
	local map, guard = readInput(filepath)
	local distance = markPath(map, guard)

	return distance, countLoops(map, guard)
end
