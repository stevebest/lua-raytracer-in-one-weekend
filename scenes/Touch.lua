local camera = Camera:new {
    lookfrom = Vec { -2.0, 2.0, 1.0 },
    lookat = Vec { 0.0, 0.0, -1.0 },
    vup = Vec { y = 1.0 },
    vfov = 45,
}

local mat = {
    blu = Lambert.new { albedo = Color { 0.0, 0.0, 1.0 } },
    red = Lambert.new { albedo = Color { 1.0, 0.0, 0.0 } },
}

local R = math.cos(math.pi / 4)

local objects = {
    Sphere {
        center = Vec { -R, 0, -1 },
        radius = R,
        mat = mat.blu,
    },
    Sphere {
        center = Vec { R, 0, -1 },
        radius = R,
        mat = mat.red,
    },
}

return objects, camera
