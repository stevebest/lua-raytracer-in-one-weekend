Lambert = {}
Lambert.__index = Lambert

function Lambert.new(init)
    init = init or { albedo = Color.GRAY }
    return setmetatable({
        albedo = init.albedo or Color.GRAY,
    }, Lambert)
end

function Lambert:scatter(r, hr)
    local dir = hr.normal + Vec.random_unit()
    local scattered = Ray(hr.p, dir)

    local attenuation = self.albedo

    return scattered, attenuation
end
