--- @class Ray
--- @field o Vec
--- @field d Vec
Ray = {}
Ray.__index = Ray

--- @param origin Vec
--- @param direction Vec
local function ray(origin, direction)
    return setmetatable({ o = origin, d = direction }, Ray)
end

setmetatable(Ray, {
    __call = function(_, o, d) return ray(o, d) end,
})

function Ray.at(r, t)
    return r.o + (t * r.d)
end

function Ray.__tostring(r)
    return string.format("Ray { o = %s, d = %s }", r.o, r.d)
end
