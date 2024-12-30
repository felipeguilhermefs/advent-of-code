local Matrix = {}
Matrix.__index = Matrix

function Matrix.contains(matrix, row, col)
	if row < 1 or row > #matrix then
		return false
	end

	if col < 1 or col > #matrix[row] then
		return false
	end

	return true
end

return Matrix
