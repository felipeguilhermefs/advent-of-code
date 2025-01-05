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

local function moveCell(cell, dir)
	return Matrix.Cell(cell.row + dir.row, cell.col + dir.col)
end

local function copyCell(from, to)
	to.row, to.col = from.row, from.col
end

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
	local nextCell = moveCell(robot, dir)

	if map:get(nextCell.row, nextCell.col) == WALL then
		return
	end

	if map:get(nextCell.row, nextCell.col) == SPACE then
		map:put(robot.row, robot.col, SPACE)
		map:put(nextCell.row, nextCell.col, ROBOT)
		copyCell(nextCell, robot)
		return
	end

	if map:get(nextCell.row, nextCell.col) == BOX then
		local afterCell = moveCell(nextCell, dir)
		while map:get(afterCell.row, afterCell.col) == BOX do
			afterCell = moveCell(afterCell, dir)
		end

		if map:get(afterCell.row, afterCell.col) == SPACE then
			map:put(afterCell.row, afterCell.col, BOX)
			map:put(robot.row, robot.col, SPACE)
			map:put(nextCell.row, nextCell.col, ROBOT)
			copyCell(nextCell, robot)
		end
		return
	end

	if dir == Matrix.E or dir == Matrix.W then
		local afterCell = nextCell

		while map:get(afterCell.row, afterCell.col) ~= SPACE and map:get(afterCell.row, afterCell.col) ~= WALL do
			afterCell = moveCell(afterCell, dir)
		end

		if map:get(afterCell.row, afterCell.col) == WALL then
			return
		end

		while afterCell.col ~= robot.col - dir.col do
			map:put(afterCell.row, afterCell.col, map:get(afterCell.row, afterCell.col - dir.col))
			afterCell.col = afterCell.col - dir.col
		end
		map:put(robot.row, robot.col, SPACE)
		copyCell(nextCell, robot)
	else
		local q = Queue.new()
		q:enqueue(robot)
		local toMove = HashMap.new()
		toMove:put(nextCell, { nextCell, map:get(nextCell.row, nextCell.col) })

		while not q:empty() do
			local cur = q:dequeue()
			local afterCell = moveCell(cur, dir)

			if map:get(afterCell.row, afterCell.col) == WALL then
				toMove:clear()
				break
			end

			if map:get(afterCell.row, afterCell.col) == SPACE then
				goto continue
			end

			toMove:put(afterCell, { afterCell, map:get(afterCell.row, afterCell.col) })

			if map:get(afterCell.row, afterCell.col) == LBOX then
				q:enqueue(afterCell)
				local rightSide = moveCell(afterCell, Matrix.E)
				q:enqueue(rightSide)
				toMove:put(rightSide, { rightSide, map:get(rightSide.row, rightSide.col) })
			elseif map:get(afterCell.row, afterCell.col) == RBOX then
				q:enqueue(afterCell)
				local leftSide = moveCell(afterCell, Matrix.W)
				q:enqueue(leftSide)
				toMove:put(leftSide, { leftSide, map:get(leftSide.row, leftSide.col) })
			end

			::continue::
		end

		if not toMove:empty() then
			for _, tile in pairs(toMove) do
				map:put(tile[1].row, tile[1].col, SPACE)
			end
			for _, tile in pairs(toMove) do
				local moved = moveCell(tile[1], dir)
				map:put(moved.row, moved.col, tile[2])
			end

			map:put(robot.row, robot.col, SPACE)
			map:put(nextCell.row, nextCell.col, ROBOT)
			copyCell(nextCell, robot)
		end
	end
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
		doMove(map, robot, move)
		doMove(wMap, wRobot, move)
	end

	return sumGPS(map), sumGPS(wMap)
end
