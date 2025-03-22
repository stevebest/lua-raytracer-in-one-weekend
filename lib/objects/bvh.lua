require 'lib/interval'
require 'lib/objects/aabb'
require 'lib/objects/list'

local function map(t, f)
    assert(type(t) == "table")
    assert(type(f) == "function")

    local result = {}
    for i, o in ipairs(t) do
        result[i] = f(o)
    end
    return result
end

local function reduce(t, f)
    assert(type(t) == "table")
    assert(#t > 0)
    assert(type(f) == "function")
    local r = t[1]

    for i = 2, #t do
        r = f(r, t[i])
    end
    return r
end

--- @class BVH : Hittable
--- @field _left Hittable
--- @field _right Hittable
--- @field _aabb AABB
BVH = {}
BVH.__index = BVH

--- @param left Hittable
--- @param right Hittable
local function bvh(left, right)
    local node = {
        _left  = left,
        _right = right,
        _aabb  = AABB.union(left:aabb(), right:aabb()),
    }
    return setmetatable(node, BVH)
end

setmetatable(BVH, {
    __call = function(_, list)
        return BVH.new(list)
    end
})

--- @param objects Hittable[]
function BVH.new(objects)
    assert(type(objects) == "table")
    assert(#objects > 0)

    if #objects == 1 then
        -- the only object in the list becomes both left and right child
        local obj = objects[1]
        return bvh(obj, obj)
    elseif #objects == 2 then
        -- arbitrarily split the two objects into left and right
        local left, right = objects[1], objects[2]
        return bvh(left, right)
    end

    -- sort the list of objects along a randomly chosen axis
    local comparators = { AABB.compare_x, AABB.compare_y, AABB.compare_z }
    local comparator = comparators[math.random(#comparators)]
    table.sort(objects, function (a, b)
        return comparator(a:aabb(), b:aabb())
    end)
    
    -- split the list of objects in two halves
    local lefts, rights = {}, {}
    local mid = #objects // 2
    table.move(objects, 1, mid, 1, lefts)
    table.move(objects, mid + 1, #objects, 1, rights)
    assert(#lefts + #rights == #objects)

    -- recursively build the bvh
    local left = BVH.new(lefts)
    local right = BVH.new(rights)
    return bvh(left, right)
end

function BVH:hit(r, rt)
    if not self:aabb():hit(r, rt) then return false end

    local hit_left, hr_left = self._left:hit(r, rt)
    if hit_left then
        local _, hr_right = self._right:hit(r, rt * Interval(0.0, hr_left.t))
        return true, hr_right or hr_left
    else
        local hit_right, hr_right = self._right:hit(r, rt)
        return hit_right, hr_right
    end
end

function BVH:aabb()
    return self._aabb
end

