local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")
local sort = require("ff.sort.quicksort")

local function newConnections()
	return Set.new()
end

local function id(set)
	local arr = {}
	for item in pairs(set) do
		table.insert(arr, item)
	end
	table.sort(arr)
	return table.concat(arr, ",")
end

local function lan3(connections)
	local lans = HashMap.new()

	for computer, connected in pairs(connections) do
		for conn in pairs(connected) do
			local lan = connected:intersection(connections:get(conn))
			for comp in pairs(lan) do
				if not computer:match("^t") and not conn:match("^t") and not comp:match("^t") then
					goto continue
				end

				local smallLan = Set.new({ computer, conn, comp })

				local key = id(smallLan)
				lans:put(key, smallLan)

				::continue::
			end
		end
	end

	return #lans
end

local function combinations(connections, size)
	local arr = Array.new()
	for item in pairs(connections) do
		arr:insert(item)
	end
	sort(arr)

	local res = Array.new()
	for i = size, #arr do
		local base = Set.new()
		for k = i - size + 1, i - 1 do
			base:add(arr:get(k))
		end

		for j = i, #arr do
			local combi = Set.new(base)
			combi:add(arr:get(j))
			res:insert(combi)
		end
	end
	return pairs(res)
end

local function maxLan(connections)
	local maxCount = 0
	local max = Set.new()
	for computer, connected in pairs(connections) do
		local size = #connected
		while size > maxCount - 1 do
			for _, combi in combinations(connected, size) do
				local lan = Set.new(combi)
				lan:add(computer)
				for other in pairs(combi) do
					lan = lan:intersection(connections:get(other))
					lan:add(other)
				end
				if #lan > maxCount then
					maxCount = #lan
					max = lan
				end
			end
			size = size - 1
		end
	end
	return id(max)
end

return function(filepath)
	local connections = HashMap.new()
	for line in io.lines(filepath) do
		local computer1, computer2 = line:match("(%a+)-(%a+)")
		connections:compute(computer1, newConnections):add(computer2)
		connections:compute(computer2, newConnections):add(computer1)
	end

	return lan3(connections), maxLan(connections)
end
