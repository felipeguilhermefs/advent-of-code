local HashMap = require("ff.collections.hashmap")

local function nextSecret(seed, iterations)
	local secret = seed
	local prices = {}
	for _ = 1, iterations do
		secret = ((secret * 64) ~ secret) % 16777216
		secret = (math.floor(secret / 32) ~ secret) % 16777216
		secret = ((secret * 2048) ~ secret) % 16777216

		table.insert(prices, secret % 10)
	end
	return secret, prices
end

local function generateSequences(prices)
	local changes = {}
	for i = 2, #prices do
		table.insert(changes, prices[i] - prices[i - 1])
	end

	local sequences = HashMap.new()
	for i = 4, #changes do
		local key = string.format("%d:%d:%d:%d", changes[i - 3], changes[i - 2], changes[i - 1], changes[i])
		if not sequences:contains(key) then
			sequences:put(key, prices[i + 1])
		end
	end
	return sequences
end

local function max(sequences)
	local maximum = 0
	for _, count in pairs(sequences) do
		if count > maximum then
			maximum = count
		end
	end
	return maximum
end

local function merge(to, from)
	for k, v in pairs(from) do
		local value = to:get(k, 0)
		to:put(k, v + value)
	end
end

return function(filepath)
	local sumPrices = 0
	local sequences = HashMap.new()
	for line in io.lines(filepath) do
		local seed = tonumber(line)
		local secret, prices = nextSecret(seed, 2000)

		sumPrices = sumPrices + secret

		merge(sequences, generateSequences(prices))
	end

	return sumPrices, max(sequences)
end
