local HashMap = require("ff.collections.hashmap")

local BLOCK = "#"
local START = "S"
local END = "E"

local N = { row = -1, col = 0 }
local E = { row = 0, col = 1 }
local S = { row = 1, col = 0 }
local W = { row = 0, col = -1 }

local DIR = { W, E, N, S }

local function id(...)
	return table.concat({ ... }, ":")
end

local POSITIONS_POOL = HashMap.new()

local Position = {}
Position.__index = Position

function Position.new(row, col)
	return POSITIONS_POOL:compute(id(row, col), function(key)
		return setmetatable({ id = key, row = row, col = col }, Position)
	end)
end

function Position.__eq(this, other)
	return (this.row == other.row) and (this.col == other.col)
end
function Position.__tostring(this)
	return this.id
end

local function readInput()
	local map, start, finish = {}, nil, nil

	for line in io.lines(arg[1]) do
		local row = {}
		for tile in line:gmatch(".") do
			table.insert(row, tile)

			if start == nil and tile == START then
				start = Position.new(#map + 1, #row)
			end

			if finish == nil and tile == END then
				finish = Position.new(#map + 1, #row)
			end
		end
		table.insert(map, row)
	end

	return map, assert(start, "no start"), assert(finish, "no finish")
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
			local nextPosition = Position.new(curPosition.row + dir.row, curPosition.col + dir.col)
			if map[nextPosition.row][nextPosition.col] ~= BLOCK and timeAtPosition:get(nextPosition) == nil then
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

local function run()
	local map, start, finish = readInput()
	local timeAtPosition, positionAtTime = normalLap(map, start, finish)
	return countCheat(timeAtPosition, positionAtTime, finish, 2), countCheat(timeAtPosition, positionAtTime, finish, 20)
end

local part1, part2 = run()

print("Part 1", part1)
print("Part 2", part2)
