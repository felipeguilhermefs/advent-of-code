local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")

local SPACE = "."
local BLOCK = "#"

local N = { row = -1, col = 0 }
local E = { row = 0, col = 1 }
local S = { row = 1, col = 0 }
local W = { row = 0, col = -1 }

N.next = { W, E }
E.next = { N, S }
S.next = { E, W }
W.next = { S, N }

local DIR = { N, E, S, W }

local function id(...)
	return table.concat({ ... }, ":")
end

local function Cell(row, col)
	return { id = id(row, col), row = row, col = col }
end

local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()

	local blocks = {}
	for x, y in content:gmatch("(%d+),(%d+)") do
		table.insert(blocks, Cell(tonumber(y) + 1, tonumber(x) + 1))
	end
	return blocks
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

local function createMap(size)
	local map = {}
	for _ = 1, size do
		local row = {}
		for _ = 1, size do
			table.insert(row, SPACE)
		end
		table.insert(map, row)
	end
	return map
end

local function putTiles(map, blocks, low, high, tile)
	for i = low, high do
		local block = blocks[i]
		map[block.row][block.col] = tile
	end
end

local function bfs(map, start, finish)
	local toVisit = Queue.new()
	toVisit:enqueue(start)
	local distances = HashMap.new()
	distances:put(start.id, 0)

	while not toVisit:empty() do
		local cur = toVisit:dequeue()

		for _, dir in pairs(DIR) do
			local nextCell = Cell(cur.row + dir.row, cur.col + dir.col)
			if not inMap(map, nextCell.row, nextCell.col) then
				goto continue
			end

			if map[nextCell.row][nextCell.col] == BLOCK then
				goto continue
			end

			if distances:contains(nextCell.id) then
				goto continue
			end

			distances:put(nextCell.id, distances:get(cur.id) + 1)

			if nextCell.id == finish.id then
				return distances:get(nextCell.id)
			end

			toVisit:enqueue(nextCell)

			::continue::
		end
	end
end

local function lastPossible(map, blocks, start, finish)
	local low, high = 1025, #blocks
	local block

	while low < high do
		local mid = math.floor((high - low) / 2 + 1) + low
		putTiles(map, blocks, low, mid, BLOCK)

		local isPossible = bfs(map, start, finish)

		putTiles(map, blocks, low, mid, SPACE)

		if isPossible then
			low = mid + 1
			block = blocks[mid]
		else
			high = mid - 1
		end
	end
	return string.format("%d,%d", block.col - 1, block.row - 1)
end

local function run(size)
	local map = createMap(size)
	local blocks = readInput()
	putTiles(map, blocks, 1, 1024, BLOCK)

	local start, finish = Cell(1, 1), Cell(size, size)

	return bfs(map, start, finish), lastPossible(map, blocks, start, finish)
end

local part1, part2 = run(71)

print("Part 1", part1)
print("Part 2", part2)
