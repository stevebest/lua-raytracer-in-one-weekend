--- @class Metal: Material
--- @field albedo Color
--- @field fuzz number
Metal = {
    albedo = Color.GRAY,
    fuzz = 0.0,
}
Metal.__index = Metal

local function new(m)
    return setmetatable(m, Metal)
end

function Metal:new(init)
    init = init or self
    return setmetatable({
        albedo = init.albedo or self.albedo,
        fuzz = init.fuzz or self.fuzz,
    }, Metal)
end

function Metal:scatter(r, hr)
    local reflected = Vec.reflect(r.d, hr.normal)
    reflected = Vec.unit(reflected) + (self.fuzz * Vec.random_unit())
    local scattered = Ray(hr.p, reflected)

    local attenuation = self.albedo
    return scattered, attenuation
end

--[[
    https://physicallybased.info/

    Aluminium = 0.912, 0.914, 0.920
    Iron = (193,190,187)
    Brass = d6b97b (214, 185, 123)
    Copper = fad0c0 (247,221,188)
    Gold = ffe29b (255, 226, 155)
    Aluminium = f5f6f6 (245, 246, 246)
    Chrome = c4c5c5 (196, 197, 197)
    Silver = fcfaf5 (252, 250, 245)
    Cobalt = d3d2cf (211, 210, 207)
    Titanium = c1bab1 (195, 186, 177)
    Platinum = d5d0c8 (213, 208, 200)
    Nickel = d3cbbe (211, 203, 190)
    Zinc = d5eaed (213, 234, 237)
    Mercury = e5e4e4 (229, 228, 228)
    Palladium = ded9d3 (222, 217, 211)
--]]
Metal.Aluminium = new {
    albedo   = Color { 0.912, 0.914, 0.920 },
    specular = Color { 0.970, 0.979, 0.988 },
}
Metal.Brass = new {
    albedo   = Color { 0.887, 0.789, 0.434 },
    specular = Color { 0.988, 0.976, 0.843 },
}
Metal.Copper = new {
    albedo   = Color { 0.926, 0.721, 0.504 },
    specular = Color { 0.996, 0.957, 0.823 },
}
Metal.Gold = new {
    albedo   = Color { 0.944, 0.776, 0.373 },
    specular = Color { 0.998, 0.981, 0.751 },
}
Metal.Iron = new {
    albedo   = Color { 0.531, 0.512, 0.496 },
    specular = Color { 0.571, 0.540, 0.586 },
}
Metal.Silver = new {
    albedo   = Color { 0.962, 0.949, 0.922 },
    specular = Color { 0.999, 0.998, 0.998 },
}
--[[
    Metal.Gold = new {
        albedo   = Color {},
        specular = Color {},
    }
--]]
