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

local function bronKerbosch(graph, cliques, current, candidates, excluded)
	if candidates:empty() and excluded:empty() then
		if #current > 2 then
			cliques:add(current)
		end
		return
	end

	local pivot, max = nil, nil
	for vertex in pairs(candidates:union(excluded)) do
		local size = #graph:get(vertex)
		if max == nil or max < size then
			max = size
			pivot = vertex
		end
	end

	local possibles = candidates:diff(graph:get(pivot))
	for vertex in pairs(possibles) do
		local newClique = Set.new(current)
		newClique:add(vertex)

		local newCandidates = candidates:intersection(graph:get(vertex))
		local newExcluded = excluded:intersection(graph:get(vertex))

		bronKerbosch(graph, cliques, newClique, newCandidates, newExcluded)

		candidates:remove(vertex)
		excluded:add(vertex)
	end
end

local function maxLan(connections)
	local lans = Set.new()
	local candidates = Set.new()
	for conn in pairs(connections) do
		candidates:add(conn)
	end

	bronKerbosch(connections, lans, Set.new(), candidates, Set.new())

	local max = nil
	for lan in pairs(lans) do
		if max == nil or #max < #lan then
			max = lan
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
