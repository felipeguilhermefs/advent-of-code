local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")
local Queue = require("ff.collections.queue")

local N = { -1, 0 }
local E = { 0, 1 }
local S = { 1, 0 }
local W = { 0, -1 }

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

local function stringfy(row, col)
	return string.format("%d:%d", row, col)
end

local function Node(id, row, col)
	local n = {
		id = id,
		row = row,
		col = col,
		edges = {},
	}

	n.addEdge = function(other)
		n.edges[other.id] = other
	end

	return n
end

local function determineRegions(map)
	local mapped = Set.new()
	local nodes = HashMap.new()
	local regions = {}

	for row, _ in pairs(map) do
		for col, plant in pairs(map[row]) do
			local id = stringfy(row, col)
			if mapped:contains(id) then
				goto continue
			end

			local toMap = Queue.new()
			local root = nodes:compute(id, function()
				return Node(id, row, col)
			end)
			toMap:enqueue(root)
			while not toMap:empty() do
				local levelSize = #toMap
				for _ = 1, levelSize do
					local cur = toMap:dequeue()
					if mapped:contains(cur.id) then
						goto continue
					end

					mapped:add(cur.id)
					for _, dir in pairs(DIRECTIONS) do
						local nRow, nCol = cur.row + dir[1], cur.col + dir[2]
						if inMap(map, nRow, nCol) and map[nRow][nCol] == plant then
							local nId = stringfy(nRow, nCol)
							local nNode = nodes:compute(nId, function()
								return Node(nId, nRow, nCol)
							end)
							cur.addEdge(nNode)
							if not mapped:contains(nNode.id) then
								toMap:enqueue(nNode)
							end
						end
					end
					::continue::
				end
			end

			table.insert(regions, root)

			::continue::
		end
	end

	return regions
end

local function calculatePrice(regions)
	local total = 0

	for _, root in pairs(regions) do
		-- print("region ->", root.id)
		local edges = 0
		local vertexes = Set.new()
		local toVisit = Queue.new()
		toVisit:enqueue(root)
		while not toVisit:empty() do
			local cur = toVisit:dequeue()
			if vertexes:contains(cur.id) then
				goto continue
			end
			for _, neighbor in pairs(cur.edges) do
				-- print(cur.id, neighbor.id)
				edges = edges + 1
				if not vertexes:contains(neighbor.id) then
					toVisit:enqueue(neighbor)
				end
			end
			vertexes:add(cur.id)
			::continue::
		end

		local area = #vertexes
		local perimeter = (#vertexes * 4) - edges
		-- print(root.id, area, perimeter, edges)
		total = total + (area * perimeter)
	end

	return total
end

local function run()
	local map = readInput()
	local regions = determineRegions(map)
	return calculatePrice(regions)
end

local part1 = run()
print("Part 1", part1)
