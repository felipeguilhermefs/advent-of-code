local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")

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

local function getTile(map, cell)
	return map[cell.row][cell.col]
end

local function putTile(map, cell, tile)
	map[cell.row][cell.col] = tile
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

	return map, movements, robot
end

local function sumGPS(map)
	local sum = 0
	for row, _ in pairs(map) do
		for col, tile in pairs(map[row]) do
			if tile == BOX or tile == LBOX then
				sum = sum + (100 * (row - 1) + (col - 1))
			end
		end
	end
	return sum
end

local function doMove(map, robot, move)
	local dir = DIR[move]
	local nextCell = moveCell(robot, dir)

	if getTile(map, nextCell) == WALL then
		return
	end

	if getTile(map, nextCell) == SPACE then
		putTile(map, robot, SPACE)
		putTile(map, nextCell, ROBOT)
		copyCell(nextCell, robot)
		return
	end

	if getTile(map, nextCell) == BOX then
		local afterCell = moveCell(nextCell, dir)
		while getTile(map, afterCell) == BOX do
			afterCell = moveCell(afterCell, dir)
		end

		if getTile(map, afterCell) == SPACE then
			putTile(map, afterCell, BOX)
			putTile(map, robot, SPACE)
			putTile(map, nextCell, ROBOT)
			copyCell(nextCell, robot)
		end
		return
	end

	if dir == E or dir == W then
		local afterCell = nextCell

		while getTile(map, afterCell) ~= SPACE and getTile(map, afterCell) ~= WALL do
			afterCell = moveCell(afterCell, dir)
		end

		if getTile(map, afterCell) == WALL then
			return
		end

		while afterCell.col ~= robot.col - dir.col do
			map[afterCell.row][afterCell.col] = map[afterCell.row][afterCell.col - dir.col]
			afterCell.col = afterCell.col - dir.col
		end
		putTile(map, robot, SPACE)
		copyCell(nextCell, robot)
	else
		local q = Queue.new()
		q:enqueue(robot)
		local toMove = HashMap.new()
		toMove:put(nextCell.id, { nextCell, map[nextCell.row][nextCell.col] })

		for _, cur in pairs(q) do
			local afterCell = moveCell(cur, dir)

			if getTile(map, afterCell) == WALL then
				toMove:clear()
				break
			end

			if getTile(map, afterCell) == SPACE then
				goto continue
			end

			toMove:put(afterCell.id, { afterCell, map[afterCell.row][afterCell.col] })

			if getTile(map, afterCell) == LBOX then
				q:enqueue(afterCell)
				local rightSide = moveCell(afterCell, E)
				q:enqueue(rightSide)
				toMove:put(rightSide.id, { rightSide, map[rightSide.row][rightSide.col] })
			elseif getTile(map, afterCell) == RBOX then
				q:enqueue(afterCell)
				local leftSide = moveCell(afterCell, W)
				q:enqueue(leftSide)
				toMove:put(leftSide.id, { leftSide, map[leftSide.row][leftSide.col] })
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
	for _, row in pairs(map) do
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
	return wide, robot
end

return function(filepath)
	local map, movements, robot = readInput(filepath)
	local wMap, wRobot = widenMap(map)

	for i, move in pairs(movements) do
		doMove(map, robot, move)
		doMove(wMap, wRobot, move)
	end

	return sumGPS(map), sumGPS(wMap)
end
