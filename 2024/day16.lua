local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")
local Queue = require("ff.collections.queue")
local Set = require("ff.collections.set")

local START = "S"
local END = "E"
local WALL = "#"

local N = { row = -1, col = 0 }
local E = { row = 0, col = 1 }
local S = { row = 1, col = 0 }
local W = { row = 0, col = -1 }

N.next = { W, E }
E.next = { N, S }
S.next = { E, W }
W.next = { S, N }

local DIR = { N, E, S, W }

local function Cell(row, col)
	return { row = row, col = col }
end

local function id(...)
	return table.concat({ ... }, ":")
end

local function readInput()
	local map, start, finish = {}, nil, nil

	for line in io.lines(arg[1]) do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)

			if start == nil and tile == START then
				start = Cell(#map + 1, #row)
			end

			if finish == nil and tile == END then
				finish = Cell(#map + 1, #row)
			end
		end
		table.insert(map, row)
	end

	return map, assert(start, "no start"), assert(finish, "no finish")
end

local function Node(row, col, dir, score, prev)
	return {
		id = id(row, col, dir.row, dir.col),
		row = row,
		col = col,
		dir = dir,
		score = score,
		prev = prev,
	}
end

local function minScore(a, b)
	if a.score > b.score then
		return 1
	end

	if a.score < b.score then
		return -1
	end

	return 0
end

local function run()
	local map, start, finish = readInput()

	local initialState = Node(start.row, start.col, E, 0)
	local pq = Heap.new(minScore)
	pq:push(initialState)

	local visited = HashMap.new()
	local prev = HashMap.new()
	prev:put(initialState.id, {})

	local winningScore = nil

	while not pq:empty() do
		local cur = pq:pop()
		if winningScore and cur.score > winningScore then
			break
		end

		if visited:contains(cur.id) then
			if cur.score == visited:get(cur.id) then
				local prevNodes = prev:get(cur.id, {})
				table.insert(prevNodes, cur.prev)
			end
			goto continue
		end

		visited:put(cur.id, cur.score)
		if cur.prev then
			prev:put(cur.id, { cur.prev })
		end

		if cur.row == finish.row and cur.col == finish.col then
			winningScore = cur.score
			break
		end

		local nextRow, nextCol = cur.row + cur.dir.row, cur.col + cur.dir.col
		if map[nextRow][nextCol] ~= WALL then
			pq:push(Node(nextRow, nextCol, cur.dir, cur.score + 1, cur))
		end

		for _, nextDir in pairs(cur.dir.next) do
			pq:push(Node(cur.row, cur.col, nextDir, cur.score + 1000, cur))
		end

		::continue::
	end

	local tiles = Set.new()
	local nodes = Queue.new()
	for _, dir in pairs(DIR) do
		local key = id(finish.row, finish.col, dir.row, dir.col)
		local prevNodes = prev:get(key, {})
		for _, prevNode in pairs(prevNodes) do
			nodes:enqueue(prevNode)
		end
	end

	while not nodes:empty() do
		local node = nodes:dequeue()
		tiles:add(id(node.row, node.col))

		local prevNodes = prev:get(node.id, {})
		for _, prevNode in pairs(prevNodes) do
			nodes:enqueue(prevNode)
		end
	end

	return winningScore, #tiles + 1
end

local part1, part2 = run()

print("Part 1", part1)
print("Part 2", part2)
