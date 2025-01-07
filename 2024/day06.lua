local Set = require("ff.collections.set")
local Matrix = require("ff.aoc.matrix")

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
	return map, assert(map:find("^"))
end

local function markPath(map, guard)
	local distance = 0
	local cell, dir = guard, Matrix.N
	while cell do
		local nextCell = map:next(cell, dir)

		if nextCell and nextCell.value == BLOCK then
			dir = TURN[dir]
		end

		if cell.value ~= VISITED then
			cell.value = VISITED
			distance = distance + 1
		end

		cell = map:next(cell, dir)
	end

	return distance
end

local function isLoop(map, guard)
	local path = Set.new()
	local cell, dir = guard, Matrix.N
	while cell do
		local key = string.format("%s:%d:%d", cell, dir.row, dir.col)
		if path:contains(key) then
			return true
		end

		local nextCell = map:next(cell, dir)
		if nextCell and nextCell.value == BLOCK then
			dir = TURN[dir]
		else
			path:add(key)
			cell = nextCell
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

		if cell == guard then
			goto continue
		end

		cell.value = BLOCK
		if isLoop(map, guard) then
			count = count + 1
		end
		cell.value = VISITED

		::continue::
	end
	return count
end

return function(filepath)
	local map, guard = readInput(filepath)
	local distance = markPath(map, guard)

	return distance, countLoops(map, guard)
end
