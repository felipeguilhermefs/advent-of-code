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
local SPACE = "."
local WALL = "#"

local MOTIONS
MOTIONS = {
	[BOX] = function(map, row, col, dir)
		local nextRow, nextCol = row + dir.row, col + dir.col
		local nextTile = map[nextRow][nextCol]
		if MOTIONS[nextTile](map, nextRow, nextCol, dir) then
			return MOTIONS[SPACE](map, row, col, dir)
		end
		return false
	end,
	[SPACE] = function(map, row, col, dir)
		local prevRow, prevCol = row - dir.row, col - dir.col
		local prevTile = map[prevRow][prevCol]
		map[prevRow][prevCol] = SPACE
		map[row][col] = prevTile
		return true
	end,
	[WALL] = function()
		return false
	end,
}

local function readInput()
	local map = {}
	local movements = {}
	local robot
	for line in io.lines(arg[1]) do
		if line:match("#") then
			local row = {}
			for tile in line:gmatch(".") do
				table.insert(row, tile)
				if robot == nil and tile == ROBOT then
					robot = { row = #map + 1, col = #row }
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

local function gps(row, col)
	return 100 * (row - 1) + (col - 1)
end

local function sumGPS(map)
	local sum = 0
	for row, _ in pairs(map) do
		for col, tile in pairs(map[row]) do
			if tile == BOX then
				sum = sum + gps(row, col)
			end
		end
	end
	return sum
end

local function doMove(map, robot, move)
	local dir = DIR[move]
	local nextRow, nextCol = robot.row + dir.row, robot.col + dir.col
	local nextTile = map[nextRow][nextCol]

	if MOTIONS[nextTile](map, nextRow, nextCol, dir) then
		robot.row = nextRow
		robot.col = nextCol
	end
end

local WIDE = {
	[SPACE] = { SPACE, SPACE },
	[ROBOT] = { ROBOT, SPACE },
	[BOX] = { "[", "]" },
	[WALL] = { WALL, WALL },
}

local function widenMap(map)
	local wide = {}
	for _, row in pairs(map) do
		local wideRow = {}
		for _, tile in pairs(row) do
			local wideTile = WIDE[tile]
			table.insert(wideRow, wideTile[1])
			table.insert(wideRow, wideTile[2])
		end
		table.insert(wide, wideRow)
	end
	return wide
end

local function printMap(map)
	for _, row in pairs(map) do
		print(table.concat(row))
	end
end

local function run()
	local map, movements, robot = readInput()
	-- local wMap = widenMap(map)
	-- local wRobot = { row = robot.row, col = robot.col }

	for _, move in pairs(movements) do
		doMove(map, robot, move)
		-- doWideMove(wMap, wRobot, move)
	end

	-- printMap(wMap)

	return sumGPS(map), 0
end

local part1, part2 = run()
print("Part 1", part1, part1 == 1552463)
print("Part 2", part2)
