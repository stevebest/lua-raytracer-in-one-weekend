require 'lib/objects/aabb'

--- @class HitList : Hittable
--- @field objects Hittable[]
--- @field _aabb AABB
HitList = {}
HitList.__index = HitList

--- @param objects Hittable[]
local function hitlist(objects)
    local aabb = nil
    for _, o in pairs(objects) do
        if not aabb then
            aabb = o:aabb()
        else
            aabb = AABB.union(aabb, o:aabb())
        end
    end
    return setmetatable({ objects = objects, _aabb = aabb }, HitList)
end

setmetatable(HitList, {
    __call = function(_, ...) return hitlist(...) end
})

function HitList:new(objects)
    return hitlist(objects)
end

function HitList:hit(r, rt)
    local _hr = nil

    for _, object in pairs(self.objects) do
        local hit, hr = object:hit(r, rt)
        -- assert(type(hit) == "boolean")
        -- assert(type(hr) == "nil" or type(hr) == "table")
        if hit and hr then
            _hr = hr
            rt.max = hr.t
        end
    end

    return _hr ~= nil, _hr
end

function HitList:aabb()
    return self._aabb
end
