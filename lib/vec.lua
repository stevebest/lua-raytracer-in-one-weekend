--- 3D Vector
--- @class Vec
--- @field x number
--- @field y number
--- @field z number
Vec = { mt = {} }

--- @param v { x: number, y: number, z: number }
--- @return Vec
local function new(v)
    return setmetatable(v, Vec.mt)
end

setmetatable(Vec, {
    __call = function(t, ...) return t.new(...) end,
})

function Vec.new(v)
    v = v or { 0, 0, 0 }
    return new {
        x = v.x or v[1] or 0,
        y = v.y or v[2] or 0,
        z = v.z or v[3] or 0,
    }
end

function Vec.splat(v)
    return new { x = v, y = v, z = v }
end

function Vec.neg(v)
    return new { x = -v.x, y = -v.y, z = -v.z }
end

function Vec.add(v1, v2)
    return new {
        x = v1.x + v2.x,
        y = v1.y + v2.y,
        z = v1.z + v2.z,
    }
end

function Vec.sub(v1, v2)
    return new {
        x = v1.x - v2.x,
        y = v1.y - v2.y,
        z = v1.z - v2.z,
    }
end

--- Scalar product
--- @return number
function Vec.dot(v1, v2)
    return
        v1.x * v2.x +
        v1.y * v2.y +
        v1.z * v2.z
end

--- Vector cross product
function Vec.cross(u, v)
    return new {
        x = u.y * v.z - u.z * v.y,
        y = u.z * v.x - u.x * v.z,
        z = u.x * v.y - u.y * v.x,
    }
end

function Vec.len_squared(v)
    return Vec.dot(v, v)
end

function Vec.len(v)
    return math.sqrt(Vec.dot(v, v))
end

function Vec.unit(v)
    return Vec.scale(1 / Vec.len(v), v)
end

function Vec.mul(s, v)
    if type(s) == 'number' then
        return Vec.scale(s, v)
    elseif type(v) == 'number' then
        return Vec.scale(v, s)
    else
        error("scaling a vector by a non-number", 2)
    end
end

function Vec.scale(s, v)
    return new {
        x = s * v.x,
        y = s * v.y,
        z = s * v.z,
    }
end

function Vec.scaleInv(v, s)
    assert(type(s) == 'number', "divide a vector by a non-number")
    return Vec.scale(1 / s, v)
end

function Vec.random()
    return new {
        x = math.random() - 0.5,
        y = math.random() - 0.5,
        z = math.random() - 0.5,
    }
end

--- @return Vec
function Vec.random_unit()
    while true do
        local v = Vec.random()
        local lensq = Vec.len_squared(v)
        if lensq <= 1 then
            return math.sqrt(1 / lensq) * v
        end
    end
end

--- @return Vec
function Vec.random_on_hemi(normal)
    local v = Vec.random_unit()
    if Vec.dot(v, normal) >= 0 then
        return v
    else
        return Vec.neg(v)
    end
end

function Vec.random_on_disk()
    while true do
        local v = Vec {
            x = math.random() * 2.0 - 1.0,
            y = math.random() * 2.0 - 1.0,
        }
        if Vec.len_squared(v) <= 1 then return v end
    end
end

--- Reflects a vector relative to a given normal
--- @param v Vec a vector to be reflected
--- @param n Vec a normal to a reflection surface
--- @return Vec
function Vec.reflect(v, n)
    return v - 2 * Vec.dot(v, n) * n
end

--- Refracts a vector
function Vec.refract(uv, n, etai_over_etat)
    local cos_theta = math.min(Vec.dot(-uv, n), 1.0)
    local r_out_perp = etai_over_etat * (uv + cos_theta * n)
    local r_out_parallel = -math.sqrt(math.abs(1.0 - Vec.len_squared(r_out_perp))) * n
    return r_out_perp + r_out_parallel
end

function Vec.tostring(v)
    return string.format("Vec{ %s, %s, %s }", v.x, v.y, v.z)
end

Vec.mt.__unm = Vec.neg
Vec.mt.__add = Vec.add
Vec.mt.__sub = Vec.sub
Vec.mt.__mul = Vec.mul
Vec.mt.__div = Vec.scaleInv
Vec.mt.__tostring = Vec.tostring
