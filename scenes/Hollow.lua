local mat = {
    ground = Lambert.new { albedo = Color { r = 0.8, g = 0.8, b = 0.0 } },
    center = Lambert.new { albedo = Color { r = 0.1, g = 0.2, b = 0.5 } },

    left = Dielectric:new { ior = 1.5 },
    left_bubble = Dielectric:new { ior = 1 / 1.5 },
    right = Metal.Copper:new { fuzz = 0.8 },
}

return {
    -- ground
    Sphere {
        center = Vec { 0, -100.5, -1 },
        radius = 100,
        mat = mat.ground,
    },
    -- center
    Sphere {
        center = Vec { 0, 0, -1.2 },
        radius = 0.5,
        mat = mat.center,
    },
    -- left
    Sphere {
        center = Vec { -1, 0, -1 },
        radius = 0.5,
        mat = mat.left,
    },
    -- bubble
    Sphere {
        center = Vec { -1, 0, -1 },
        radius = 0.4,
        mat = mat.left_bubble,
    },
    -- right
    Sphere {
        center = Vec { 1, 0, -1 },
        radius = 0.5,
        mat = mat.right,
    },
}
