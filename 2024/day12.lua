local HashMap = require("ff.collections.hashmap")
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

local DIRECTIONS = { N, E, S, W }

local function readInput()
	local map = {}
	for line in io.lines(arg[1]) do
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

local function countCorners(map, row, col, neighbors)
	if #neighbors == 0 then
		return 4
	end

	if #neighbors == 1 then
		return 2
	end

	local corners = 0

	local nDirections = Set.new()
	for _, neighbor in pairs(neighbors) do
		nDirections:add(neighbor[4])
	end

	if #neighbors == 2 then
		if not (nDirections:contains(N) and nDirections:contains(S)) and not (nDirections:contains(E) and nDirections:contains(W)) then
			corners = 1
		end
	end

	local plant = map[row][col]

	local oRow, oCol =  row + NE[1], col + NE[2]
	if inMap(map, oRow, oCol) and map[oRow][oCol] ~= plant then
		if nDirections:contains(N) and nDirections:contains(E) then
			corners = corners + 1
		end
	end

	oRow, oCol =  row + NW[1], col + NW[2]
	if inMap(map, oRow, oCol) and map[oRow][oCol] ~= plant then
		if nDirections:contains(N) and nDirections:contains(W) then
			corners = corners + 1
		end
	end

	oRow, oCol =  row + SE[1], col + SE[2]
	if inMap(map, oRow, oCol) and map[oRow][oCol] ~= plant then
		if nDirections:contains(S) and nDirections:contains(E) then
			corners = corners + 1
		end
	end

	oRow, oCol =  row + SW[1], col + SW[2]
	if inMap(map, oRow, oCol) and map[oRow][oCol] ~= plant then
		if nDirections:contains(S) and nDirections:contains(W) then
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
	toMap:enqueue({ row, col, id(row, col) })

	while not toMap:empty() do
		local cur = toMap:dequeue()
		if not area:add(cur[3]) then
			goto continue
		end

		local neighbors = {}
		for _, dir in pairs(DIRECTIONS) do
			local nRow, nCol = cur[1] + dir[1], cur[2] + dir[2]
			if inMap(map, nRow, nCol) and map[nRow][nCol] == plant then
				local neighbor = { nRow, nCol, id(nRow, nCol), dir }
				if not area:contains(neighbor[3]) then
					toMap:enqueue(neighbor)
				end
				table.insert(neighbors, neighbor)
			end
		end

		perimeter = perimeter + (4 - #neighbors)
		corners = corners + countCorners(map, cur[1], cur[2], neighbors)

		::continue::
	end

	return area, perimeter, corners
end

local function run()
	local map = readInput()

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

			for pos, _ in pairs(area._entries) do
				mapped:add(pos)
			end

			::continue::
		end
	end
	return total, withDiscount
end

local part1, part2 = run()
print("Part 1", part1, part1 == 1573474)
print("Part 2", part2, part2 == 966476)
