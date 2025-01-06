local Set = require("ff.collections.set")
local Queue = require("ff.collections.queue")
local Matrix = require("matrix")

local OUTER = {
	[Matrix.NE] = { Matrix.N, Matrix.E },
	[Matrix.NW] = { Matrix.N, Matrix.W },
	[Matrix.SE] = { Matrix.S, Matrix.E },
	[Matrix.SW] = { Matrix.S, Matrix.W },
}

local DIRECTIONS = { Matrix.N, Matrix.E, Matrix.S, Matrix.W }
local OUTER_DIRECTIONS = { Matrix.NE, Matrix.NW, Matrix.SE, Matrix.SW }

local function isOuterCorner(map, cell, dir, neighborsDir)
	local plant = cell.value
	local oCell = map:next(cell, dir)

	if oCell and oCell.value ~= plant then
		return neighborsDir:contains(OUTER[dir][1], OUTER[dir][2])
	end
	return false

end

local function countCorners(map, cell, neighborsDir)
	if #neighborsDir == 0 then
		return 4
	end

	if #neighborsDir == 1 then
		return 2
	end

	local corners = 0

	if #neighborsDir == 2 then
		if not neighborsDir:contains(Matrix.N, Matrix.S) and not neighborsDir:contains(Matrix.E, Matrix.W) then
			-- perpendicular
			corners = 1
		end
	end

	for _, dir in pairs(OUTER_DIRECTIONS) do
		if isOuterCorner(map, cell, dir, neighborsDir) then
			corners = corners + 1
		end
	end

	return corners
end

local function determineRegions(map, cell)
	local plant = cell.value
	local area = Set.new()
	local perimeter = 0
	local corners = 0

	local toMap = Queue.new()
	toMap:enqueue(cell)

	while not toMap:empty() do
		local cur = toMap:dequeue()
		if not area:add(cur) then
			goto continue
		end

		local neighborsDir = Set.new()
		for _, dir in pairs(DIRECTIONS) do
			local nextCell = map:next(cur, dir)
			if nextCell and nextCell.value == plant then
				if not area:contains(nextCell) then
					toMap:enqueue(nextCell)
				end
				neighborsDir:add(dir)
			end
		end

		perimeter = perimeter + (4 - #neighborsDir)
		corners = corners + countCorners(map, cur, neighborsDir)

		::continue::
	end

	return area, perimeter, corners
end

return function(filepath)
	local map = Matrix.fromFile(filepath)

	local total = 0
	local withDiscount = 0
	local mapped = Set.new()
	for _, cell in pairs(map) do
		if mapped:contains(cell) then
			goto continue
		end
		local area, perimeter, corners = determineRegions(map, cell)

		total = total + (perimeter * #area)
		withDiscount = withDiscount + (corners * #area)

		-- Add everything from area into mapped, so we skip them
		mapped = mapped .. area

		::continue::
	end
	return total, withDiscount
end
