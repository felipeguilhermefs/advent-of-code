local Set = require("ff.collections.set")
local Queue = require("ff.collections.queue")

local N = { -1, 0 }
local NE = { -1, 1 }
local E = { 0, 1 }
local SE = { 1, 1 }
local S = { 1, 0 }
local SW = { 1, -1 }
local W = { 0, -1 }
local NW = { -1, -1 }

NE.outer = { N, E }
NW.outer = { N, W }
SE.outer = { S, E }
SW.outer = { S, W }

local DIRECTIONS = { N, E, S, W }
local OUTER_DIRECTIONS = {NE, NW, SE, SW}

local function readInput(filepath)
	local map = {}
	for line in io.lines(filepath) do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)
		end
		table.insert(map, row)
	end
	return map
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

local function id(row, col)
	return string.format("%d:%d", row, col)
end

local function Node(row, col, dir)
	return { row = row, col = col, id = id(row, col), dir = dir }
end

local function isOuterCorner(map, row, col, dir, neighborsDir)
	local plant = map[row][col]
	local oRow, oCol = row + dir[1], col + dir[2]

	if inMap(map, oRow, oCol) and map[oRow][oCol] ~= plant then
		return neighborsDir:contains(dir.outer[1], dir.outer[2])
	end
	return false

end

local function countCorners(map, row, col, neighborsDir)
	if #neighborsDir == 0 then
		return 4
	end

	if #neighborsDir == 1 then
		return 2
	end

	local corners = 0

	if #neighborsDir == 2 then
		if not neighborsDir:contains(N, S) and not neighborsDir:contains(E, W) then
			-- perpendicular
			corners = 1
		end
	end

	for _, dir in pairs(OUTER_DIRECTIONS) do
		if isOuterCorner(map, row, col, dir, neighborsDir) then
			corners = corners + 1
		end
	end

	return corners
end

local function determineRegions(map, row, col)
	local plant = map[row][col]
	local area = Set.new()
	local perimeter = 0
	local corners = 0

	local toMap = Queue.new()
	toMap:enqueue(Node(row, col))

	while not toMap:empty() do
		local cur = toMap:dequeue()
		if not area:add(cur.id) then
			goto continue
		end

		local neighborsDir = Set.new()
		for _, dir in pairs(DIRECTIONS) do
			local nRow, nCol = cur.row + dir[1], cur.col + dir[2]
			if inMap(map, nRow, nCol) and map[nRow][nCol] == plant then
				local neighbor = Node(nRow, nCol, dir)
				if not area:contains(neighbor.id) then
					toMap:enqueue(neighbor)
				end
				neighborsDir:add(dir)
			end
		end

		perimeter = perimeter + (4 - #neighborsDir)
		corners = corners + countCorners(map, cur.row, cur.col, neighborsDir)

		::continue::
	end

	return area, perimeter, corners
end

return function(filepath)
	local map = readInput(filepath)

	local total = 0
	local withDiscount = 0
	local mapped = Set.new()
	for row, _ in pairs(map) do
		for col, _ in pairs(map[row]) do
			if mapped:contains(id(row, col)) then
				goto continue
			end
			local area, perimeter, corners = determineRegions(map, row, col)

			total = total + (perimeter * #area)
			withDiscount = withDiscount + (corners * #area)

			-- Add everything from area into mapped, so we skip them
			mapped = mapped .. area

			::continue::
		end
	end
	return total, withDiscount
end
