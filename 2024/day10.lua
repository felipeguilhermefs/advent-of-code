local Set = require("ff.collections.set")
local Matrix = require("matrix")

local DIRECTIONS = { Matrix.N, Matrix.E, Matrix.S, Matrix.W }

local function walkTrails(map, cell, height, peaks)
	height = height or 0
	peaks = peaks or Set.new()

	if cell == nil or cell.value ~= height then
		return peaks, 0
	end

	if height == 9 then
		peaks:add(cell)
		return peaks, 1
	end

	local trails = 0
	for _, dir in pairs(DIRECTIONS) do
		local _, count = walkTrails(map, map:next(cell, dir), height + 1, peaks)
		trails = trails + count
	end

	return peaks, trails
end

return function(filepath)
	local map = Matrix.fromFile(filepath, tonumber)
	local score = 0
	local trails = 0

	for _, cell in pairs(map) do
		if cell.value == 0 then
			local peaks, count = walkTrails(map, cell)
			score = score + #peaks
			trails = trails + count
		end
	end

	return score, trails
end
