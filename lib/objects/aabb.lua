require 'lib/interval'

--- Axis-aligned bounding box
--- @class AABB : Hittable
--- @field x Interval
--- @field y Interval
--- @field z Interval
AABB = {}
AABB.__index = AABB

local function aabb(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, AABB)
end

setmetatable(AABB, {
    __call = function(_, x, y, z)
        return aabb(x, y, z)
    end
})

function AABB:__tostring()
    return string.format("%s x %s x %s", self.x, self.y, self.z)
end

--- Creates an AABB from two opposing corners of the box
function AABB:from_corners(a, b)
    local x = a.x <= b.x and Interval(a.x, b.x) or Interval(b.x, a.x)
    local y = a.y <= b.y and Interval(a.y, b.y) or Interval(b.y, a.y)
    local z = a.z <= b.z and Interval(a.z, b.z) or Interval(b.z, a.z)
    return aabb(x, y, z)
end

--- @param r Ray
--- @param _rt Interval
--- @return boolean
function AABB:hit(r, _rt)
    -- print("AABB.hit(%s, %s, %s)", self, r, _rt)
    local rt = _rt:clone()

    local ro = r.o
    local rd = r.d

    --[[
    for (axis in { x, y, z })
        const interval& ax = axis_interval(axis);
        const double adinv = 1.0 / ray_dir[axis];

        auto t0 = (ax.min - ray_orig[axis]) * adinv;
        auto t1 = (ax.max - ray_orig[axis]) * adinv;

        if (t0 < t1) {
            if (t0 > ray_t.min) ray_t.min = t0;
            if (t1 < ray_t.max) ray_t.max = t1;
        } else {
            if (t1 > ray_t.min) ray_t.min = t1;
            if (t0 < ray_t.max) ray_t.max = t0;
        }

        if (ray_t.max <= ray_t.min)
            return false;
    --]]
    do
        local ax = self.x
        local adinv = 1.0 / rd.x

        local t0 = (ax.min - ro.x) * adinv
        local t1 = (ax.max - ro.x) * adinv

        t0, t1 = math.min(t0, t1), math.max(t0, t1)

        if t0 > rt.min then rt.min = t0 end
        if t1 < rt.max then rt.max = t1 end

        if rt:is_empty() then return false end
    end

    do
        local ax = self.y
        local adinv = 1.0 / rd.y

        local t0 = (ax.min - ro.y) * adinv
        local t1 = (ax.max - ro.y) * adinv

        t0, t1 = math.min(t0, t1), math.max(t0, t1)

        if t0 > rt.min then rt.min = t0 end
        if t1 < rt.max then rt.max = t1 end

        if rt:is_empty() then return false end
    end

    do
        local ax = self.z
        local adinv = 1.0 / rd.z

        local t0 = (ax.min - ro.z) * adinv
        local t1 = (ax.max - ro.z) * adinv

        t0, t1 = math.min(t0, t1), math.max(t0, t1)

        if t0 > rt.min then rt.min = t0 end
        if t1 < rt.max then rt.max = t1 end

        if rt:is_empty() then return false end
    end

    return true
end

--- @param a AABB
--- @param b AABB
function AABB.union(a, b)
    local x = a.x + b.x -- Interval.union
    local y = a.y + b.y
    local z = a.z + b.z
    return aabb(x, y, z)
end

AABB.__add = AABB.union

function AABB:is_empty()
    return self.x:is_empty() or self.y:is_empty() or self.z:is_empty()
end

--- @param axis "x" | "y" | "z"
local function compare(axis)
    --- @param a AABB
    --- @param b AABB
    return function (a, b)
        return a[axis].min < b[axis].min
    end
end

AABB.compare_x = compare("x")
AABB.compare_y = compare("y")
AABB.compare_z = compare("z")
