local Matrix = require("ff.aoc.matrix")

local PAPER = "@"
local DIRECTIONS = {
	Matrix.N,
	Matrix.NE,
	Matrix.E,
	Matrix.SE,
	Matrix.S,
	Matrix.SW,
	Matrix.W,
	Matrix.NW,
}

return function(filepath)
	local matrix = Matrix.fromFile(filepath)
	local part1 = 0
	for _, cell in pairs(matrix) do
		if cell.value ~= PAPER then
			goto continue
		end
		local count = 0
		for _, dir in pairs(DIRECTIONS) do
			local neighbor = matrix:next(cell, dir)
			if neighbor and neighbor.value == PAPER then
				count = count + 1
			end
		end

		if count < 4 then
			part1 = part1 + 1
		end
		::continue::
	end
	return part1, 0
end
