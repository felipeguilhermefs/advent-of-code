local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()

	local stones = {}
	for num in content:gmatch("%d+") do
		stones[num] = (stones[num] or 0) + 1
	end
	return stones
end

local function shift(stones)
	local cur = stones.front

	while cur.next ~= stones.back do
		cur = cur.next
		if cur.value == 0 then
			cur.value = 1
			goto continue
		end

		local engraved = tostring(cur.value)
		if #engraved % 2 == 0 then
			local first = tonumber(engraved:sub(1, math.floor(#engraved / 2)))
			stones.pushBefore(cur, first)

			local second = tonumber(engraved:sub(math.floor(#engraved / 2) + 1, #engraved))
			cur.value = second
		else
			cur.value = cur.value * 2024
		end

		::continue::
	end
end

local function run(times)
	local stones = readInput()

	for _ = 1, times do
		local cache = {}
		for stone, count in pairs(stones) do
			if stone == "0" then
				cache["1"] = (cache["1"] or 0) + count
			elseif #stone % 2 == 0 then
				local first = tostring(tonumber(stone:sub(1, #stone // 2)))
				cache[first] = (cache[first] or 0) + count
				local second = tostring(tonumber(stone:sub(#stone // 2 + 1, #stone)))
				cache[second] = (cache[second] or 0) + count
			else
				local num = tostring(tonumber(stone) * 2024)
				cache[num] = (cache[num] or 0) + count
			end
		end

		stones = cache
	end

	local total = 0
	for _, count in pairs(stones) do
		total = total + count
	end
	return total
end

print("Part 1", run(25))
print("Part 2", run(75))
