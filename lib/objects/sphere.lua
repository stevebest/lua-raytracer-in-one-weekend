require 'lib/objects/aabb'

--- @class Sphere : Hittable
--- @field center Vec
--- @field radius number
--- @field mat Material
Sphere = {}
Sphere.mt = { __index = Sphere }

function Sphere.new(init)
    return setmetatable({
        center = init.center or Vec {},
        radius = math.max(0, init.radius or 1.0),
        mat = init.mat, -- or Lambert.new(),
    }, Sphere.mt)
end

setmetatable(Sphere, { __call = function(t, ...) return Sphere.new(...) end })

function Sphere:tostring()
    return string.format([[
Sphere {
    center = %s,
    radius = %e,
    mat = %s,
}
]], self.center, self.radius, self.mat)
end

Sphere.mt.__tostring = Sphere.tostring

function Sphere:hit(r, rt)
    local oc = self.center - r.o
    local a = Vec.len_squared(r.d)
    local h = Vec.dot(r.d, oc)
    local c = Vec.len_squared(oc) - self.radius * self.radius

    local D = h * h - a * c
    if D < 0 then return false end

    local sqrtD = math.sqrt(D)

    local root = (h - sqrtD) / a
    if not rt:contains(root) then
        root = (h + sqrtD) / a
        if not rt:contains(root) then return false end
    end

    local t = root
    local p = Ray.at(r, root)
    local normal = (1 / self.radius) * (p - self.center)

    return true, HitRec {
        r = r,
        t = t,
        p = p,
        normal = normal,
        mat = self.mat,
        obj = self,
    }
end

function Sphere:aabb()
    local rv = Vec.splat(self.radius)
    return AABB:from_corners(self.center - rv, self.center + rv)
end
