--- @class Dielectric
--- @field ior number
Dielectric = {
    ior = 1.0
}
Dielectric.__index = Dielectric

local function new(m)
    return setmetatable(m, Dielectric)
end

function Dielectric:new(init)
    init = init or self
    return setmetatable({
        ior = init.ior or self.ior,
    }, Dielectric)
end

--[[
    auto r0 = (1 - refraction_index) / (1 + refraction_index);
    r0 = r0*r0;
    return r0 + (1-r0)*std::pow((1 - cosine),5);
--]]
--- Schlick's approximation for reflectance.
local function reflectance(cos, ri)
    local r0 = (1 - ri) / (1 + ri)
    r0 = r0 * r0
    return r0 + (1 - r0) * ((1 - cos) ^ 5)
end

function Dielectric:scatter(r, hr)
    -- ray
    local ri = hr.front and 1 / self.ior or self.ior

    local dir = Vec.unit(r.d)
    local cos_theta = math.min(Vec.dot(-dir, hr.normal), 1.0)
    local sin_theta = math.sqrt(1.0 - cos_theta * cos_theta)

    local cannot_refract = ri * sin_theta > 1.0
    if cannot_refract or (reflectance(cos_theta, ri) > math.random()) then
        dir = Vec.reflect(dir, hr.normal)
    else
        dir = Vec.refract(dir, hr.normal, ri)
    end

    local scattered = Ray(hr.p, dir)

    return scattered, nil -- no attenuation
end


Dielectric.Water   = Dielectric:new { ior = 1.333 }
Dielectric.Glass   = Dielectric:new { ior = 1.520 }
Dielectric.Diamond = Dielectric:new { ior = 2.417 }

-- Dielectric.Honey   = Dielectric:new { ior = 1.504, transmission = Color { 0.831, 0.397, 0.038 } }
