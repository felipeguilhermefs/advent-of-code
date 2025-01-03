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

function Matrix:get(row, col)
	if self:contains(row, col) then
		return self._m[row][col]
	end
end

function Matrix:rows()
	return pairs(self._m)
end

function Matrix:put(row, col, value)
	if value ~= nil and self:contains(row, col) then
		self._m[row][col] = value
	end
end

function Matrix:__pairs()
	local row, col = 1, 1
	local index = 0
	return function()
		if row > #self._m then
			return
		end

		if col > #self._m[row] then
			if row == #self._m then
				return nil
			end
			row = row + 1
			col = 1
		end

		index = index + 1
		local value = { row = row, col = col, value = self._m[row][col] }
		col = col + 1
		return index, value
	end,
		self,
		nil
end

return Matrix
