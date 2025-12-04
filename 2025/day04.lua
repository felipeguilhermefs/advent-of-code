local Matrix = require("ff.aoc.matrix")

local PAPER = "@"
local BLANK = "."
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

-- Count the number of "pickable" cells and return the "unpickable" ones
local function pick(matrix, toCheck, taint)
	-- toCheck are the cells that should be checked, otherwise we check the entire matrix
	toCheck = toCheck or matrix
	-- taint marks the picked cells
	taint = taint or 0

	local total, unpicked = 0, {}
	for _, cell in pairs(toCheck) do
		if cell.value == BLANK then
			goto continue
		end

		local count = 0
		-- check in all directions
		for _, dir in pairs(DIRECTIONS) do
			local neighbor = matrix:next(cell, dir)
			-- count the papers and also the papers that were "picked" this time
			if neighbor and (neighbor.value == PAPER or neighbor.value == taint) then
				count = count + 1
			end
		end

		if count < 4 then
			total = total + 1
			cell.value = taint
		else
			table.insert(unpicked, cell)
		end

		::continue::
	end

	return total, unpicked
end

return function(filepath)
	local matrix = Matrix.fromFile(filepath)
	local part1, unpicked = pick(matrix)

	local newPicks, part2, taint = part1, part1, 1

	while newPicks > 0 do
		-- each iteration needs a new taint so things are not counted again
		taint = taint + 1

		newPicks, unpicked = pick(matrix, unpicked, taint)

		part2 = part2 + newPicks
	end

	return part1, part2
end
