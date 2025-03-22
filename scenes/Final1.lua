local mat = {
    ground     = Lambert.new { albedo = Color { 0.5, 0.5, 0.5 } },
    dielectric = Dielectric:new { ior = 1.500 },
    lambertian = Lambert.new { albedo = Color { 0.4, 0.2, 0.1 } },
    metal      = Metal:new { albedo = Color { 0.7, 0.6, 0.6 }, fuzz = 0.0 },
}

local objects = {
    -- ground = 
    Sphere {
        center = Vec { 0.0, -1000.0, 0.0 },
        radius = 1000.0,
        mat = mat.ground,
    },
    -- dielectric = 
    Sphere {
        center = Vec { 0.0, 1.0, 0.0 },
        radius = 1.0,
        mat = mat.dielectric,
    },
    -- lambertian = 
    Sphere {
        center = Vec { -4.0, 1.0, 0.0 },
        radius = 1.0,
        mat = mat.lambertian,
    },
    -- metal =
    Sphere {
        center = Vec { 4.0, 1.0, 0.0 },
        radius = 1.0,
        mat = mat.metal,
    },
}

local function random_mat()
    local r = math.random()
    if r < 0.8 then
        return Lambert.new { albedo = Color {
            r = math.random() * math.random(),
            g = math.random() * math.random(),
            b = math.random() * math.random(),
        } }
    elseif r < 0.95 then
        return Metal:new {
            albedo = Color {
                r = math.random() / 2.0 + 0.5,
                g = math.random() / 2.0 + 0.5,
                b = math.random() / 2.0 + 0.5,
            },
            fuzz = math.random() / 2.0,
        }
    else
        return mat.dielectric
    end
end


local function random_spheres()
    for a = -11, 11 do
        for b = -11, 11 do
            local center = Vec {
                x = a + 0.9 * math.random(),
                y = 0.2,
                z = b + 0.9 * math.random(),
            }

            if Vec.len_squared(center, Vec { 4, 0.2, 0 }) > 0.81 then
                table.insert(objects, Sphere {
                    center = center,
                    radius = 0.2,
                    mat = random_mat(),
                })
            end
        end
    end
end

random_spheres()

local camera = Camera:new {
    -- image_width = 1920,
    -- image_height = 1080,
    lookfrom = Vec { 13.0, 2.0, 3.0 },
    lookat = Vec { 0.0, 0.0, 0.0 },
    vfov = 20,
    vup = Vec { y = 1.0 },
}

return objects, camera
