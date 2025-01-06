local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")
local Matrix = require("matrix")

local DIR = {
	["^"] = Matrix.N,
	[">"] = Matrix.E,
	["v"] = Matrix.S,
	["<"] = Matrix.W,
}

local ROBOT = "@"
local BOX = "O"
local LBOX = "["
local RBOX = "]"
local SPACE = "."
local WALL = "#"

local function readInput(filepath)
	local map = {}
	local movements = {}
	for line in io.lines(filepath) do
		if line:match(WALL) then
			local row = {}
			for tile in line:gmatch(".") do
				table.insert(row, Matrix.Cell(#map + 1, #row + 1, tile))
			end
			table.insert(map, row)
		else
			for move in line:gmatch(".") do
				table.insert(movements, move)
			end
		end
	end

	return Matrix.new(map), movements
end

local function sumGPS(map)
	local sum = 0
	for _, cell in pairs(map) do
		if cell.value == BOX or cell.value == LBOX then
			sum = sum + (100 * (cell.row - 1) + (cell.col - 1))
		end
	end
	return sum
end

local function doMove(map, robot, move)
	local dir = DIR[move]
	local nextCell = map:next(robot, dir)

	if nextCell.value == WALL then
		return robot
	end

	if nextCell.value == SPACE then
		robot.value = SPACE
		nextCell.value = ROBOT
		return nextCell
	end

	if nextCell.value == BOX then
		local afterCell = map:next(nextCell, dir)
		while afterCell.value == BOX do
			afterCell = map:next(afterCell, dir)
		end

		if afterCell.value == SPACE then
			afterCell.value = BOX
			robot.value = SPACE
			nextCell.value = ROBOT
			return nextCell
		end
		return robot
	end

	if dir == Matrix.E or dir == Matrix.W then
		local afterCell = nextCell

		while afterCell.value ~= SPACE and afterCell.value ~= WALL do
			afterCell = map:next(afterCell, dir)
		end

		if afterCell.value == WALL then
			return robot
		end

		while afterCell.col ~= robot.col - dir.col do
			local prevCell = map:prev(afterCell, dir)
			afterCell.value = prevCell.value
			afterCell = prevCell
		end
		robot.value = SPACE
		return nextCell
	else
		local q = Queue.new()
		q:enqueue(robot)
		local toMove = HashMap.new()
		toMove:put(nextCell, { nextCell, nextCell.value })

		while not q:empty() do
			local cur = q:dequeue()
			local afterCell = map:next(cur, dir)

			if afterCell.value == WALL then
				toMove:clear()
				break
			end

			if afterCell.value == SPACE then
				goto continue
			end

			toMove:put(afterCell, { afterCell, afterCell.value })

			if afterCell.value == LBOX then
				q:enqueue(afterCell)
				local rightSide = map:next(afterCell, Matrix.E)
				q:enqueue(rightSide)
				toMove:put(rightSide, { rightSide, rightSide.value })
			elseif afterCell.value == RBOX then
				q:enqueue(afterCell)
				local leftSide = map:next(afterCell, Matrix.W)
				q:enqueue(leftSide)
				toMove:put(leftSide, { leftSide, leftSide.value })
			end

			::continue::
		end

		if not toMove:empty() then
			for _, tile in pairs(toMove) do
				tile[1].value = SPACE
			end
			for _, tile in pairs(toMove) do
				local moved = map:next(tile[1], dir)
				moved.value = tile[2]
			end

			robot.value = SPACE
			nextCell.value = ROBOT
			return nextCell
		end
	end
	return robot
end

local function widenMap(map)
	local wide = {}
	for _, row in map:rows() do
		local wideRow = {}
		for _, cell in pairs(row) do
			if cell.value == SPACE then
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, SPACE))
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, SPACE))
			elseif cell.value == ROBOT then
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, ROBOT))
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, SPACE))
			elseif cell.value == BOX then
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, LBOX))
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, RBOX))
			elseif cell.value == WALL then
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, WALL))
				table.insert(wideRow, Matrix.Cell(#wide + 1, #wideRow + 1, WALL))
			end
		end
		table.insert(wide, wideRow)
	end
	return Matrix.new(wide)
end

return function(filepath)
	local map, movements = readInput(filepath)
	local robot = assert(map:find(ROBOT))
	local wMap = widenMap(map)
	local wRobot = assert(wMap:find(ROBOT))

	for _, move in pairs(movements) do
		robot = doMove(map, robot, move)
		wRobot = doMove(wMap, wRobot, move)
	end

	return sumGPS(map), sumGPS(wMap)
end
