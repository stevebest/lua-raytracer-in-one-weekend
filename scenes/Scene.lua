local mat = {
    sand  = Lambert.new { albedo = Color { 0.440, 0.386, 0.231 } },
    brick = Lambert.new { albedo = Color { 0.262, 0.095, 0.061 } },
    gray  = Lambert.new { albedo = Color { 0.180, 0.180, 0.180 } },
}

return {
    Sphere {
        center = Vec { 0, 0, -100 },
        radius = 90,
        mat = mat.brick,
    },
    Sphere {
        center = Vec { 0, -100, -1 },
        radius = 99.5,
        mat = mat.gray,
    },
}, Camera:new {
    lookfrom = Vec {},
    lookat = Vec { z = -1 },
    vfov = 20,
}
