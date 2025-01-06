local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")
local Matrix = require("matrix")

local SPACE = "."
local BLOCK = "#"

local DIR = { Matrix.N, Matrix.E, Matrix.S, Matrix.W }

local function readInput(filepath)
	local f = assert(io.open(filepath, "rb"))
	local content = f:read("*a")
	f:close()

	local blocks = {}
	for x, y in content:gmatch("(%d+),(%d+)") do
		table.insert(blocks, Matrix.Cell(tonumber(y) + 1, tonumber(x) + 1))
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
	distances:put(tostring(start), 0)

	while not toVisit:empty() do
		local cur = toVisit:dequeue()
		for _, dir in pairs(DIR) do
			local nextCell = map:next(cur, dir)
			if nextCell == nil then
				goto continue
			end

			if nextCell.value == BLOCK then
				goto continue
			end

			if distances:contains(tostring(nextCell)) then
				goto continue
			end

			distances:put(tostring(nextCell), distances:get(tostring(cur)) + 1)

			if nextCell == finish then
				return distances:get(tostring(nextCell))
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

	local start, finish = Matrix.Cell(1, 1), Matrix.Cell(size, size)

	return bfs(map, start, finish), lastPossible(map, blocks, start, finish)
end
