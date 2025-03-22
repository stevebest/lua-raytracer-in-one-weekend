--- @class Interval
--- @field min number
--- @field max number
Interval = {}
Interval.__index = Interval
setmetatable(Interval, {
    __call = function(_, ...)
        return Interval.new(...)
    end
})

local function interval(min, max)
    return setmetatable({ min = min, max = max }, Interval)
end

function Interval.new(min, max)
    assert(type(min) == 'number', "min must be a number")
    assert(type(max) == 'number', "max must be a number")
    return interval(min, max)
end

function Interval:__tostring()
    return string.format("(%s .. %s)", self.min, self.max)
end

function Interval:clone()
    return interval(self.min, self.max)
end

function Interval:is_empty()
    return self.min >= self.max
end

--- Grows the length of the interval by delta
--- @param delta number
function Interval:expand(delta)
    local h = delta / 2
    return interval(self.min - h, self.min + h)
end

--- @param a Interval
--- @param b Interval
function Interval.union(a, b)
    local min, max = math.min(a.min, b.min), math.max(a.max, b.max)
    return interval(min, max)
end

Interval.__add = Interval.union

--- @param a Interval
--- @param b Interval
function Interval.intersection(a, b)
    local min, max = math.max(a.min, b.min), math.min(a.max, b.max)
    return interval(min, max)
end

Interval.__mul = Interval.intersection

function Interval:clamp(x)
    if x < self.min then
        return self.min
    elseif x > self.max then
        return self.max
    end
    return x
end

function Interval:size()
    return self.max - self.min
end

--- @param x number
function Interval:contains(x)
    return self.min <= x and x <= self.max
end

--- @param x number
function Interval:surrounds(x)
    return self.min < x and x < self.max
end

Interval.empty    = interval(math.huge, -math.huge)
Interval.universe = interval(-math.huge, math.huge)
Interval.positive = interval(0, math.huge)
