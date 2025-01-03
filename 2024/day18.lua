local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")
local Matrix = require("matrix")

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

local function readInput(filepath)
	local f = assert(io.open(filepath, "rb"))
	local content = f:read("*a")
	f:close()

	local blocks = {}
	for x, y in content:gmatch("(%d+),(%d+)") do
		table.insert(blocks, Cell(tonumber(y) + 1, tonumber(x) + 1))
	end
	return blocks
end

local function putTiles(map, blocks, low, high, tile)
	for i = low, high do
		local block = blocks[i]
		map:put(block.row, block.col, tile)
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
			if not map:contains(nextCell.row, nextCell.col) then
				goto continue
			end

			if map:get(nextCell.row, nextCell.col) == BLOCK then
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

return function(filepath)
	local size = 71
	local map = Matrix.fill(size, SPACE)
	local blocks = readInput(filepath)
	putTiles(map, blocks, 1, 1024, BLOCK)

	local start, finish = Cell(1, 1), Cell(size, size)

	return bfs(map, start, finish), lastPossible(map, blocks, start, finish)
end
