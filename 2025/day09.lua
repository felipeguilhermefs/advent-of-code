local function area(a, b)
	return (math.abs(a.x - b.x) + 1) * (math.abs(a.y - b.y) + 1)
end

local function maxRectangle(coordinates)
	local max = 0
	for i = 1, #coordinates do
		for j = i + 1, #coordinates do
			max = math.max(max, area(coordinates[i], coordinates[j]))
		end
	end
	return max
end

local function buildPoligon(coordinates)
	local prev = nil
	local poligon = {}
	for i = 1, #coordinates do
		local vertex = { point = coordinates[i] }

		if prev then
			vertex.prev = prev.point
			prev.next = vertex.point
		end

		table.insert(poligon, vertex)
		prev = vertex
	end

	poligon[#poligon].next = poligon[1].point
	poligon[1].prev = poligon[#poligon].point

	return poligon
end

local function pointInVertex(vertex, point)
	if vertex.prev.x == vertex.point.x then
		if vertex.prev.y > vertex.point.y then
			if vertex.next.x < vertex.point.x then
				-- Left Down
				return point.x >= vertex.point.x or point.y <= vertex.point.y
			else
				-- Left Up
				return point.x >= vertex.point.x and point.y >= vertex.point.y
			end
		elseif vertex.next.x < vertex.point.x then
			-- Right Down
			return point.x <= vertex.point.x and point.y <= vertex.point.y
		else
			-- Right Up
			return point.x <= vertex.point.x or point.y >= vertex.point.y
		end
	elseif vertex.prev.x < vertex.point.x then
		if vertex.next.y > vertex.point.y then
			-- Up Right
			return point.x <= vertex.point.x and point.y >= vertex.point.y
		else
			-- Up Left
			return point.x >= vertex.point.x or point.y >= vertex.point.y
		end
	elseif vertex.next.y > vertex.point.y then
		-- Down Right
		return point.x <= vertex.point.x or point.y <= vertex.point.y
	else
		-- Down Left
		return point.x >= vertex.point.x and point.y <= vertex.point.y
	end
end

local function anyVertexInRectangle(poligon, a, b)
	local minX, maxX = math.min(a.point.x, b.point.x), math.max(a.point.x, b.point.x)
	local minY, maxY = math.min(a.point.y, b.point.y), math.max(a.point.y, b.point.y)

	for _, vertex in pairs(poligon) do
		local isBelow = minX >= vertex.point.x
		local isAbove = vertex.point.x >= maxX
		local isOverLeft = minY >= vertex.point.y
		local isOverRight = vertex.point.y >= maxY

		if (isBelow or isAbove) and (isOverLeft or isOverRight) then
			goto continue
		end

		local goingUp = vertex.next.y > vertex.point.y
		local goingRight = vertex.next.x > vertex.point.x
		local crossedAbove = vertex.next.y > maxY
		local crossedBelow = vertex.next.y < minY
		local crossedRight = vertex.next.x > maxX
		local crossedLeft = vertex.next.x < minX

		if not isBelow and not isAbove then
			if not isOverLeft and not isOverRight then
				return true
			elseif goingUp then
				if isOverLeft and crossedAbove then
					return true
				end
			elseif crossedBelow and isOverRight then
				return true
			end
		elseif goingRight then
			if isBelow and crossedRight then
				return true
			end
		elseif crossedLeft and isAbove then
			return true
		end
		::continue::
	end

	return false
end

local function rectangleInPoligon(poligon, a, b)
	if not pointInVertex(a, b.point) then
		return false
	end

	if not pointInVertex(b, a.point) then
		return false
	end

	if anyVertexInRectangle(poligon, a, b) then
		return false
	end

	return true
end

local function maxRectangleInPoligon(coordinates)
	local poligon = buildPoligon(coordinates)

	local max = 0
	for i = 1, #poligon do
		for j = i + 1, #poligon do
			local a, b = poligon[i], poligon[j]
			local size = area(a.point, b.point)
			if size > max and rectangleInPoligon(poligon, a, b) then
				max = size
			end
		end
	end
	return max
end

return function(filepath)
	local coordinates = {}
	for line in io.lines(filepath) do
		local x, y = line:match("(%d+),(%d+)")
		table.insert(coordinates, { x = tonumber(x), y = tonumber(y) })
	end

	return maxRectangle(coordinates), maxRectangleInPoligon(coordinates)
end
