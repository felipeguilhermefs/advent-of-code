local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")

local ENTER = "A"
local ZERO = "0"
local ONE = "1"
local TWO = "2"
local THREE = "3"
local FOUR = "4"
local FIVE = "5"
local SIX = "6"
local SEVEN = "7"
local EIGHT = "8"
local NINE = "9"

local UP = "^"
local DOWN = "v"
local LEFT = "<"
local RIGHT = ">"

local function readInput(filepath)
	local codes = {}
	for code in io.lines(filepath) do
		table.insert(codes, {
			code = code,
			score = tonumber(code:match("%d+")),
		})
	end
	return codes
end

local function id(...)
	return table.concat({ ... }, ":")
end

--[[
+---+---+---+
  7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
|   | 0 | A | 
+---+---+---+
--]]
local NUMPAD = {
	[ZERO] = { { TWO, UP }, { ENTER, RIGHT } },
	[ONE] = { { TWO, RIGHT }, { FOUR, UP } },
	[TWO] = { { ZERO, DOWN }, { ONE, LEFT }, { THREE, RIGHT }, { FIVE, UP } },
	[THREE] = { { TWO, LEFT }, { SIX, UP }, { ENTER, DOWN } },
	[FOUR] = { { ONE, DOWN }, { FIVE, RIGHT }, { SEVEN, UP } },
	[FIVE] = { { TWO, DOWN }, { FOUR, LEFT }, { SIX, RIGHT }, { EIGHT, UP } },
	[SIX] = { { THREE, DOWN }, { FIVE, LEFT }, { NINE, UP } },
	[SEVEN] = { { FOUR, DOWN }, { EIGHT, RIGHT } },
	[EIGHT] = { { FIVE, DOWN }, { SEVEN, LEFT }, { NINE, RIGHT } },
	[NINE] = { { SIX, DOWN }, { EIGHT, LEFT } },
	[ENTER] = { { ZERO, LEFT }, { THREE, UP } },
}

--[[
+---+---+---+
|   | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
--]]
local DIRPAD = {
	[UP] = { { ENTER, RIGHT }, { DOWN, DOWN } },
	[LEFT] = { { DOWN, RIGHT } },
	[DOWN] = { { LEFT, LEFT }, { UP, UP }, { RIGHT, RIGHT } },
	[RIGHT] = { { DOWN, LEFT }, { ENTER, UP } },
	[ENTER] = { { UP, LEFT }, { RIGHT, DOWN } },
}

local function minLen(moves)
	local minimum
	for _, move in pairs(moves) do
		if minimum == nil or #move < minimum then
			minimum = #move
		end
	end
	return minimum
end

local function min(nums)
	local minimum
	for _, num in pairs(nums) do
		if minimum == nil or num < minimum then
			minimum = num
		end
	end
	return minimum
end

local function copyWith(array, item)
	local copy = { table.unpack(array) }
	table.insert(copy, item)
	return copy
end

local function bfs(from, to, pad)
	local toVisit = Queue.new()
	toVisit:enqueue({ from, {} })

	local shortest
	local allMoves = {}

	for _, cur in pairs(toVisit) do
		local digit = cur[1]
		local moves = cur[2]
		if digit == to then
			if shortest == nil then
				shortest = #moves
			end
			if #moves == shortest then
				table.insert(allMoves, table.concat(copyWith(moves, ENTER)))
			end
			goto continue
		end

		if shortest and #moves >= shortest then
			goto continue
		end

		for _, neighborButton in pairs(pad[digit]) do
			local button = neighborButton[1]
			local dir = neighborButton[2]
			toVisit:enqueue({ button, copyWith(moves, dir) })
		end

		::continue::
	end

	return allMoves
end

local function countMoves(code, nRobots, cache, pad)
	pad = pad or NUMPAD
	return cache:compute(id(code, nRobots), function()
		code = "A" .. code
		local count = 0
		for i = 1, #code - 1 do
			local from = code:sub(i, i)
			local to = code:sub(i + 1, i + 1)
			local moves = bfs(from, to, pad)
			if nRobots == 0 then
				count = count + minLen(moves)
			else
				local sizeMoves = {}
				for _, move in pairs(moves) do
					local size = countMoves(move, nRobots - 1, cache, DIRPAD)
					table.insert(sizeMoves, size)
				end
				count = count + min(sizeMoves)
			end
		end
		return count
	end)
end

local function run(codes, nRobots)
	local sum = 0
	local cache = HashMap.new()
	for _, code in pairs(codes) do
		local count = countMoves(code.code, nRobots, cache)
		sum = sum + code.score * count
	end
	return sum
end

return function(filepath)
	local codes = readInput(filepath)
	return run(codes, 2), run(codes, 25)
end
