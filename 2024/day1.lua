local f = io.open("input1.txt", "rb") or os.exit(1)
local INPUT = f:read("*a")
f:close()

local function parseInput()
	return INPUT:gmatch("(%d+)   (%d+)")
end

local function part1()
	local Heap = require("ff.collections.heap")

	local left, right = Heap.new(), Heap.new()
	for l, r in parseInput() do
		left:push(tonumber(l))
		right:push(tonumber(r))
	end

	local sum = 0
	while not left:empty() do
		sum = sum + math.abs(left:pop() - right:pop())
	end
	return sum
end

local function part2()
	local Array = require("ff.collections.array")
	local HashMap = require("ff.collections.hashmap")

	local left, right = Array.new(), HashMap.new()
	for l, r in parseInput() do
		left:insert(tonumber(l))
		right:put(tonumber(r), right:get(tonumber(r), 0) + 1)
	end

	local sum = 0
	for _, l in pairs(left) do
		sum = sum + (l * right:get(l, 0))
	end
	return sum
end

print("Part 1", part1())
print("Part 2", part2())
