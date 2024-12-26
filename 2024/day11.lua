local HashMap = require("ff.collections.hashmap")

local function addCount(counter, key, value)
	counter:put(key, counter:get(key, 0) + value)
end

local function readInput(filepath)
	local f = assert(io.open(filepath, "rb"))
	local content = f:read("*a")
	f:close()

	local counter = HashMap.new()
	for num in content:gmatch("%d+") do
		addCount(counter, num, 1)
	end
	return counter
end

local function split(num)
	local first = tonumber(num:sub(1, #num / 2))
	local second = tonumber(num:sub(#num / 2 + 1, #num))
	return tostring(first), tostring(second)
end

local function run(stones, times)
	for _ = 1, times do
		local counter = HashMap.new()
		for stone, count in pairs(stones) do
			if stone == "0" then
				addCount(counter, "1", count)
			elseif #stone % 2 == 0 then
				local first, second = split(stone)
				addCount(counter, first, count)
				addCount(counter, second, count)
			else
				addCount(counter, tostring(tonumber(stone) * 2024), count)
			end
		end

		stones = counter
	end

	local total = 0
	for _, count in pairs(stones) do
		total = total + count
	end
	return total
end

return function(filepath)
	local stones = readInput(filepath)
	return run(stones, 25), run(stones, 75)
end
