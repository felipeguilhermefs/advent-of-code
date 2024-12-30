local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(matrix)
	return setmetatable({ _m = matrix }, Matrix)
end

function Matrix:contains(row, col)
	if row < 1 or row > #self._m then
		return false
	end

	if col < 1 or col > #self._m[row] then
		return false
	end

	return true
end

return Matrix
