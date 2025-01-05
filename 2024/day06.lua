local Set = require("ff.collections.set")
local Matrix = require("matrix")

local TURN = {
	[Matrix.N] = Matrix.E,
	[Matrix.E] = Matrix.S,
	[Matrix.S] = Matrix.W,
	[Matrix.W] = Matrix.N,
}

local BLOCK = "#"
local VISITED = "X"

local function readInput(filepath)
	local map = Matrix.fromFile(filepath)
	local cell = assert(map:find("^"))
	local guard = { row = cell.row, col = cell.col, dir = Matrix.N }
	return map, guard
end

local function markPath(map, guard)
	local distance = 0
	local row, col, dir = guard.row, guard.col, guard.dir
	while map:contains(row, col) do
		local nextRow, nextCol = row + dir.row, col + dir.col

		if map:get(nextRow, nextCol) == BLOCK then
			dir = TURN[dir]
		end

		if map:get(row, col) ~= VISITED then
			map:put(row, col, VISITED)
			distance = distance + 1
		end

		row = row + dir.row
		col = col + dir.col
	end

	return distance
end

local function isLoop(map, guard)
	local path = Set.new()
	local row, col, dir = guard.row, guard.col, guard.dir
	while map:contains(row, col) do
		local key = string.format("%d:%d:%d:%d", row, col, dir.row, dir.col)
		if path:contains(key) then
			return true
		end

		local nextRow, nextCol = row + dir.row, col + dir.col

		if map:get(nextRow, nextCol) == BLOCK then
			dir = TURN[dir]
		else
			path:add(key)
			row = row + dir.row
			col = col + dir.col
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

		map:put(cell.row, cell.col, BLOCK)
		if isLoop(map, guard) then
			count = count + 1
		end
		map:put(cell.row, cell.col, VISITED)

		::continue::
	end
	return count
end

return function(filepath)
	local map, guard = readInput(filepath)
	local distance = markPath(map, guard)

	return distance, countLoops(map, guard)
end
