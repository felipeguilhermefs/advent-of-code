local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local sort = require("ff.sort.quicksort")

local function Node(value)
	return { value = value, children = HashMap.new() }
end

local function addNodes(nodes, prev, next)
	local prevNode = nodes:compute(prev, Node)
	local nextNode = nodes:compute(next, Node)

	prevNode.children:put(next, nextNode)
end

local function findMiddle(nodes, line)
	local pages = Array.new()

	local safe = true
	local curNodes = nodes
	for value in line:gmatch("(%d+)") do
		local node = curNodes:get(value)
		if node == nil then
			safe = false
		else
			curNodes = node.children
		end
		pages:insert(nodes:get(value))
	end

	if not safe then
		sort(pages, function(a, b)
			if a.children:contains(b.value) then
				return 1
			end

			if b.children:contains(a.value) then
				return -1
			end

			return 0
		end)
	end

	return pages:get(math.floor(#pages / 2) + 1).value, safe
end

return function(filepath)
	local safeSum, unsafeSum = 0, 0
	local nodes = HashMap.new()
	for line in io.lines(filepath) do
		local prev, next = line:match("(%d+)|(%d+)")
		if prev then
			addNodes(nodes, prev, next)
		elseif line ~= "" then
			local middle, safe = findMiddle(nodes, line)
			if safe then
				safeSum = safeSum + middle
			else
				unsafeSum = unsafeSum + middle
			end
		end
	end

	return safeSum, unsafeSum
end
