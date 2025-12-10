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

local function isAnyPointInSquare(poligon, a, b)
	local minX, maxX = math.min(a.point.x, b.point.x), math.max(a.point.x, b.point.x)
	local minY, maxY = math.min(a.point.y, b.point.y), math.max(a.point.y, b.point.y)

	for _, vertex in pairs(poligon) do
		if
			(minX >= vertex.point.x or vertex.point.x >= maxX) and (minY >= vertex.point.y or vertex.point.y >= maxY)
		then
			goto continue
		end

		if minX < vertex.point.x and vertex.point.x < maxX then
			if minY < vertex.point.y and vertex.point.y < maxY then
				return true
			elseif vertex.next.y > vertex.point.y then
				if vertex.point.y < minY and vertex.next.y > maxY then
					return true
				end
			elseif vertex.next.y < minY and vertex.point.y > maxY then
				return true
			end
		elseif vertex.next.x > vertex.point.x then
			if vertex.point.x < minX and vertex.next.x > maxX then
				return true
			end
		elseif vertex.next.x < minX and vertex.point.x > maxX then
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

	if isAnyPointInSquare(poligon, a, b) then
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
