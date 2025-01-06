local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")
local Queue = require("ff.collections.queue")
local Set = require("ff.collections.set")
local Matrix = require("matrix")

local START = "S"
local END = "E"
local WALL = "#"

local NEXT = {
	[Matrix.N] = { Matrix.W, Matrix.E },
	[Matrix.E] = { Matrix.N, Matrix.S },
	[Matrix.S] = { Matrix.E, Matrix.W },
	[Matrix.W] = { Matrix.S, Matrix.N },
}

local DIR = { Matrix.N, Matrix.E, Matrix.S, Matrix.W }

local function id(...)
	return table.concat({ ... }, ":")
end

local function readInput(filepath)
	local map = Matrix.fromFile(filepath)
	return map, assert(map:find(START)), assert(map:find(END))
end

local function Node(cell, dir, score, prev)
	return {
		id = id(cell.row, cell.col, dir.row, dir.col),
		cell = cell,
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

return function(filepath)
	local map, start, finish = readInput(filepath)

	local initialState = Node(start, Matrix.E, 0)
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
				local prevNodes = prev:get(cur.id)
				table.insert(prevNodes, cur.prev)
			end
			goto continue
		end

		visited:put(cur.id, cur.score)
		if cur.prev then
			prev:put(cur.id, { cur.prev })
		end

		if cur.cell == finish then
			winningScore = cur.score
			break
		end

		local nextCell = map:next(cur.cell, cur.dir)
		if nextCell.value ~= WALL then
			pq:push(Node(nextCell, cur.dir, cur.score + 1, cur))
		end

		for _, nextDir in pairs(NEXT[cur.dir]) do
			pq:push(Node(cur.cell, nextDir, cur.score + 1000, cur))
		end

		::continue::
	end

	local nodes = Queue.new()
	for _, dir in pairs(DIR) do
		local key = id(finish.row, finish.col, dir.row, dir.col)
		nodes = nodes .. prev:get(key)
	end

	local tiles = Set.new()
	for _, node in pairs(nodes) do
		tiles:add(node.cell)

		nodes = nodes .. prev:get(node.id)
	end

	return winningScore, #tiles + 1
end
