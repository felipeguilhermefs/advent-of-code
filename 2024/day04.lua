local Matrix = require("matrix")

local N = { -1, 0 }
local NE = { -1, 1 }
local E = { 0, 1 }
local SE = { 1, 1 }
local S = { 1, 0 }
local SW = { 1, -1 }
local W = { 0, -1 }
local NW = { -1, -1 }

local function isXMAS(map, row, col, dir)
	-- try out the letters in sequence in a given direction
	local mas = { "M", "A", "S" }
	for _, letter in pairs(mas) do
		row = row + dir[1]
		col = col + dir[2]

		if map:get(row, col) ~= letter then
			return false
		end
	end
	return true
end

local function countXMAS(map)
	-- find X and then try MAS in every direction
	local directions = { N, NE, NW, W, E, S, SE, SW }
	local sum = 0

	for _, cell in pairs(map) do
		if cell.value ~= "X" then
			goto continue
		end

		for _, dir in pairs(directions) do
			if isXMAS(map, cell.row, cell.col, dir) then
				sum = sum + 1
			end
		end
		::continue::
	end

	return sum
end

local function isCrossMAS(map, cell, dir)
	-- look for M in a given position, and S in the cross opposite end
	local ms = { ["M"] = 1, ["S"] = -1 }
	for letter, axis in pairs(ms) do
		local lRow = cell.row + dir[1] * axis
		local lCol = cell.col + dir[2] * axis
		if map:get(lRow, lCol) ~= letter then
			return false
		end
	end

	return true
end

local function countCrossMAS(map)
	-- try out diagonal positions for the X
	local directions = { NE, NW, SE, SW }
	local sum = 0

	for _, cell in pairs(map) do
		if cell.value ~= "A" then
			goto continue
		end

		local countDir = 0
		for _, dir in pairs(directions) do
			if isCrossMAS(map, cell, dir) then
				countDir = countDir + 1
			end
		end

		-- should have 2 diagonals to have an X
		if countDir == 2 then
			sum = sum + 1
		end
		::continue::
	end

	return sum
end

return function(filepath)
	local map = Matrix.fromFile(filepath)
	return countXMAS(map), countCrossMAS(map)
end
