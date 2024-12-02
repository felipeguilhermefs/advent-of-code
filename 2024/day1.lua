local function parseInput()
	local f = assert(io.open(arg[1], "rb"), "Open File")
	local content = f:read("*a")
	f:close()
	return content:gmatch("(%d+)   (%d+)")
end

local function part1()
	local Heap = require("ff.collections.heap")

	local left, right = Heap.new(), Heap.new()
	for l, r in parseInput() do
		left:push(l)
		right:push(r)
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
		left:insert(l)
		right:put(r, right:get(r, 0) + 1)
	end

	local sum = 0
	for _, l in pairs(left) do
		sum = sum + (l * right:get(l, 0))
	end
	return sum
end

print("Part 1", part1())
print("Part 2", part2())
