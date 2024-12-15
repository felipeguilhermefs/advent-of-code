local ROBOT = "@"
local BOX = "O"
local SPACE = "."
local WALL = "#"

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

local function nextPos(row, col, dir)
	return row + dir.row, col + dir.col
end

local function doMove(map, robot, move)
	local dir = DIR[move]
	local nextRow, nextCol = nextPos(robot.row, robot.col, dir)
	local nextTile = map[nextRow][nextCol]

	if nextTile == SPACE then
		map[robot.row][robot.col] = SPACE
		robot.row = nextRow
		robot.col = nextCol
		map[robot.row][robot.col] = ROBOT
	elseif nextTile == BOX then
		local afterRow, afterCol = nextRow, nextCol
		local canMove = false
		while map[afterRow][afterCol] ~= WALL do
			afterRow, afterCol = nextPos(afterRow, afterCol, dir)
			if map[afterRow][afterCol] == SPACE then
				-- print("canmove", afterRow, afterCol)
				canMove = true
				break
			end
		end

		if canMove then
			local row, col = robot.row, robot.col

			map[robot.row][robot.col] = SPACE
			robot.row = nextRow
			robot.col = nextCol

			local next = ROBOT
			while row ~= afterRow or col ~= afterCol do
				row, col = nextPos(row, col, dir)
				local tmp = map[row][col]
				map[row][col] = next
				-- print(tmp, next)
				next = tmp
			end
		end
	end
end

local function printMap(map)
	for _, row in pairs(map) do
		print(table.concat(row))
	end
end

local function run()
	local map, movements, robot = readInput()

	for _, move in pairs(movements) do
		-- print("\n-----------------\n")
		-- printMap(map)
		-- print(move)
		doMove(map, robot, move)
		-- printMap(map)
	end

	printMap(map)

	return sumGPS(map), 0
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
