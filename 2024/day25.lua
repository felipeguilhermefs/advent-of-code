local Array = require("ff.collections.array")

local MATERIAL = "#"

local KEY = "K"
local LOCK = "L"

local function newSchematic()
	return {
		kind = nil,
		values = Array.new({ 0, 0, 0, 0, 0 }),
	}
end

local function readInput(filepath)
	local keys, locks = Array.new(), Array.new()
	local schematic = newSchematic()
	for line in io.lines(filepath) do
		if line == "" then
			if schematic.kind == KEY then
				keys:insert(schematic)
			else
				locks:insert(schematic)
			end
			schematic = newSchematic()
		else
			local hasMaterial = false
			local index = 1
			for tile in line:gmatch(".") do
				if tile == MATERIAL then
					hasMaterial = true
					schematic.values:put(index, schematic.values:get(index) + 1)
				end
				index = index + 1
			end

			if schematic.kind == nil then
				if hasMaterial then
					schematic.kind = LOCK
				else
					schematic.kind = KEY
				end
			end
		end
	end

	return keys, locks
end

local function fit(key, lock)
	for i = 1, #key.values do
		if key.values:get(i) + lock.values:get(i) > 7 then
			return false
		end
	end
	return true
end

local function countPairs(keys, locks)
	local count = 0
	for _, key in pairs(keys) do
		for _, lock in pairs(locks) do
			if fit(key, lock) then
				count = count + 1
			end
		end
	end
	return count
end

return function(filepath)
	local keys, locks = readInput(filepath)
	return countPairs(keys, locks), "Feliz Natal!"
end
