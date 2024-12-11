local function Node(value, next, previous)
	local n = { value = value, next = next, previous = previous }
	return n
end

local function DoubleLinkedList()
	local ll = { front = Node(), back = Node(), len = 0 }

	ll.front.next = ll.back
	ll.back.previous = ll.front

	ll.pushBefore = function(node, value)
		local new = Node(value, node, node.previous)
		node.previous.next = new
		node.previous = new
		ll.len = ll.len + 1
	end

	ll.str = function()
		local arr = {}
		local cur = ll.front.next
		while cur ~= ll.back do
			table.insert(arr, cur.value)
			cur = cur.next
		end

		return table.concat(arr, " , ")
	end

	return ll
end

local function readInput()
	local f = assert(io.open(arg[1], "rb"))
	local content = f:read("*a")
	f:close()

	local stones = DoubleLinkedList()
	for char in content:gmatch("%d+") do
		stones.pushBefore(stones.back, tonumber(char))
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

local function run()
	local stones = readInput()

	for _ = 1, 25 do
		shift(stones)
	end

	return stones.len
end

local part1 = run()
print("Part 1", part1)
