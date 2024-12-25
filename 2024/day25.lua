local MATERIAL = "#"

local KEY = "K"
local LOCK = "L"

local function newSchematic()
	return {
		kind = nil,
		values = { 0, 0, 0, 0, 0 },
	}
end

local function readInput()
	local schematics = { [LOCK] = {}, [KEY] = {} }
	local schematic = newSchematic()
	for line in io.lines(arg[1]) do
		if line == "" then
			table.insert(schematics[schematic.kind], schematic)
			schematic = newSchematic()
		else
			local hasMaterial = false
			local index = 1
			for tile in line:gmatch(".") do
				if tile == MATERIAL then
					hasMaterial = true
					schematic.values[index] = schematic.values[index] + 1
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

	return schematics
end

local function fit(key, lock)
	for i = 1, #key.values do
		if key.values[i] + lock.values[i] > 7 then
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

local function run()
	local schematics = readInput()
	return countPairs(schematics[KEY], schematics[LOCK])
end

local part1, part2 = run()
print("Part 1", part1)
print("Part 2", part2)
