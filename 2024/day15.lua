local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")
local Matrix = require("matrix")

local N = { row = -1, col = 0 }
local E = { row = 0, col = 1 }
local S = { row = 1, col = 0 }
local W = { row = 0, col = -1 }

local DIR = {
	["^"] = N,
	[">"] = E,
	["v"] = S,
	["<"] = W,
}

local ROBOT = "@"
local BOX = "O"
local LBOX = "["
local RBOX = "]"
local SPACE = "."
local WALL = "#"

local function id(row, col)
	return string.format("%d:%d", row, col)
end

local function Cell(row, col)
	return { id = id(row, col), row = row, col = col }
end

local function moveCell(cell, dir)
	return Cell(cell.row + dir.row, cell.col + dir.col)
end

local function copyCell(from, to)
	to.id, to.row, to.col = from.id, from.row, from.col
end

local function putTile(map, cell, tile)
	map._m[cell.row][cell.col] = tile
end

local function readInput(filepath)
	local map = {}
	local movements = {}
	local robot
	for line in io.lines(filepath) do
		if line:match(WALL) then
			local row = {}
			for tile in line:gmatch(".") do
				table.insert(row, tile)
				if robot == nil and tile == ROBOT then
					robot = Cell(#map + 1, #row)
				end
			end
			table.insert(map, row)
		else
			for move in line:gmatch(".") do
				table.insert(movements, move)
			end
		end
	end

	return Matrix.new(map), movements, robot
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
		putTile(map, robot, SPACE)
		putTile(map, nextCell, ROBOT)
		copyCell(nextCell, robot)
		return
	end

	if map:get(nextCell.row, nextCell.col) == BOX then
		local afterCell = moveCell(nextCell, dir)
		while map:get(afterCell.row, afterCell.col) == BOX do
			afterCell = moveCell(afterCell, dir)
		end

		if map:get(afterCell.row, afterCell.col) == SPACE then
			putTile(map, afterCell, BOX)
			putTile(map, robot, SPACE)
			putTile(map, nextCell, ROBOT)
			copyCell(nextCell, robot)
		end
		return
	end

	if dir == E or dir == W then
		local afterCell = nextCell

		while map:get(afterCell.row, afterCell.col) ~= SPACE and map:get(afterCell.row, afterCell.col) ~= WALL do
			afterCell = moveCell(afterCell, dir)
		end

		if map:get(afterCell.row, afterCell.col) == WALL then
			return
		end

		while afterCell.col ~= robot.col - dir.col do
			map._m[afterCell.row][afterCell.col] = map:get(afterCell.row, afterCell.col - dir.col)
			afterCell.col = afterCell.col - dir.col
		end
		putTile(map, robot, SPACE)
		copyCell(nextCell, robot)
	else
		local q = Queue.new()
		q:enqueue(robot)
		local toMove = HashMap.new()
		toMove:put(nextCell.id, { nextCell, map:get(nextCell.row, nextCell.col) })

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

			toMove:put(afterCell.id, { afterCell, map:get(afterCell.row, afterCell.col) })

			if map:get(afterCell.row, afterCell.col) == LBOX then
				q:enqueue(afterCell)
				local rightSide = moveCell(afterCell, E)
				q:enqueue(rightSide)
				toMove:put(rightSide.id, { rightSide, map:get(rightSide.row, rightSide.col) })
			elseif map:get(afterCell.row, afterCell.col) == RBOX then
				q:enqueue(afterCell)
				local leftSide = moveCell(afterCell, W)
				q:enqueue(leftSide)
				toMove:put(leftSide.id, { leftSide, map:get(leftSide.row, leftSide.col) })
			end

			::continue::
		end

		if not toMove:empty() then
			for _, tile in pairs(toMove) do
				putTile(map, tile[1], SPACE)
			end
			for _, tile in pairs(toMove) do
				putTile(map, moveCell(tile[1], dir), tile[2])
			end

			putTile(map, robot, SPACE)
			putTile(map, nextCell, ROBOT)
			copyCell(nextCell, robot)
		end
	end
end

local function widenMap(map)
	local wide = {}
	local robot
	for _, row in pairs(map._m) do
		local wideRow = {}
		for _, tile in pairs(row) do
			if tile == SPACE then
				table.insert(wideRow, SPACE)
				table.insert(wideRow, SPACE)
			elseif tile == ROBOT then
				table.insert(wideRow, ROBOT)
				if robot == nil then
					robot = Cell(#wide + 1, #wideRow)
				end
				table.insert(wideRow, SPACE)
			elseif tile == BOX then
				table.insert(wideRow, LBOX)
				table.insert(wideRow, RBOX)
			elseif tile == WALL then
				table.insert(wideRow, WALL)
				table.insert(wideRow, WALL)
			end
		end
		table.insert(wide, wideRow)
	end
	return Matrix.new(wide), robot
end

return function(filepath)
	local map, movements, robot = readInput(filepath)
	local wMap, wRobot = widenMap(map)

	for _, move in pairs(movements) do
		doMove(map, robot, move)
		doMove(wMap, wRobot, move)
	end

	return sumGPS(map), sumGPS(wMap)
end
