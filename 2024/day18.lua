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

local function putBlocks(map, blocks, count)
	for i = 1, count do
		local block = blocks[i]
		map[block.row][block.col] = BLOCK
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
	return -1
end

local function run(size)
	local map = createMap(size)
	local blocks = readInput()
	putBlocks(map, blocks, 1024)

	local start, finish = Cell(1, 1), Cell(size, size)

	return bfs(map, start, finish), 0
end

local part1, part2 = run(71)

print("Part 1", part1, part1 == 416)
print("Part 2", part2, part2 == "50,23")
