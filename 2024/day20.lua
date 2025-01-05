local HashMap = require("ff.collections.hashmap")
local Matrix = require("matrix")

local BLOCK = "#"
local START = "S"
local END = "E"

local DIR = { Matrix.W, Matrix.E, Matrix.N, Matrix.S }

local function id(...)
	return table.concat({ ... }, ":")
end

local POSITIONS_POOL = HashMap.new()

local function new(row, col)
	return POSITIONS_POOL:compute(id(row, col), function()
		return Matrix.Cell(row, col)
	end)
end

local function readInput(filepath)
	local map = Matrix.fromFile(filepath)
	local start = assert(map:find(START))
	local finish = assert(map:find(END))
	return map, new(start.row, start.col), new(finish.row, finish.col)
end

local function normalLap(map, start, finish)
	local timeAtPosition = HashMap.new()
	local positionAtTime = HashMap.new()

	local curPosition = start
	local curTime = 0
	timeAtPosition:put(start, curTime)
	positionAtTime:put(curTime, start)
	while curPosition ~= finish do
		for _, dir in pairs(DIR) do
			local nextPosition = new(curPosition.row + dir.row, curPosition.col + dir.col)
			if map:get(nextPosition.row, nextPosition.col) ~= BLOCK and timeAtPosition:get(nextPosition) == nil then
				local nextTime = curTime + 1
				timeAtPosition:put(nextPosition, nextTime)
				positionAtTime:put(nextTime, nextPosition)
				curPosition = nextPosition
				curTime = nextTime
				break
			end
		end
	end

	return timeAtPosition, positionAtTime
end

local function countCheat(timeAtPosition, positionAtTime, finish, cheat)
	local count = 0
	for curPosition, curTime in pairs(timeAtPosition) do
		local toPosition = finish
		local toTime = timeAtPosition:get(finish)

		while toTime - curTime >= 100 do
			local distance = math.abs(curPosition.col - toPosition.col) + math.abs(curPosition.row - toPosition.row)
			local skip = 1
			if distance <= cheat then
				local timeSaved = toTime - curTime - distance
				if timeSaved >= 100 then
					count = count + 1
				end
			else
				skip = distance - cheat
			end

			toTime = toTime - skip
			toPosition = positionAtTime:get(toTime)
		end
	end

	return count
end

return function(filepath)
	local map, start, finish = readInput(filepath)
	local timeAtPosition, positionAtTime = normalLap(map, start, finish)
	return countCheat(timeAtPosition, positionAtTime, finish, 2), countCheat(timeAtPosition, positionAtTime, finish, 20)
end
