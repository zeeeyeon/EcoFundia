if redis.call('EXISTS', KEYS[1]) == 1 then
    return -1
end

local currentCount = 0
local countValue = redis.call('GET', KEYS[2])

if countValue then
    currentCount = tonumber(countValue) or 0
end

local maxQuantity = tonumber(ARGV[1]) or 0

if currentCount >= maxQuantity then
    return 0
end

redis.call('INCR', KEYS[2])

local ttl = tonumber(ARGV[2]) or 86400
redis.call('SET', KEYS[1], '1', 'EX', ttl)

return 1