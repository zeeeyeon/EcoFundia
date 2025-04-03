if redis.call('EXISTS', KEYS[1]) == 1 then
    return -1  -- 이미 발급된 쿠폰
end

-- 현재 발급된 쿠폰 수량 확인
local currentCount = 0
local countValue = redis.call('GET', KEYS[2])

-- 카운트 값이 존재하면 숫자로 변환
if countValue then
    currentCount = tonumber(countValue) or 0
end

-- 최대 발급 가능 수량 확인
local maxQuantity = tonumber(ARGV[1]) or 0

-- 발급 한도 체크
if currentCount >= maxQuantity then
    return 0  -- 쿠폰 소진됨
end

-- 카운트 증가
redis.call('INCR', KEYS[2])

-- 사용자 발급 정보 저장 (당일 만료)
local ttl = tonumber(ARGV[2]) or 86400  -- 기본값 24시간
redis.call('SET', KEYS[1], '1', 'EX', ttl)

return 1  -- 쿠폰 발급 성공