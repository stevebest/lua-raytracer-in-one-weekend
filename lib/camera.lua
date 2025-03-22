local ProgressReport = require "lib/progress"

local Tev = require "tev"

local tev = Tev()

local function sample_square()
    return math.random() - 0.5, math.random() - 0.5
end

--- @class Camera
Camera = {
    --- width of the image, in pixels
    image_width  = 400,
    --- height of the image, in pixels
    image_height = 225,
    --- number of samples per pixel
    spp          = 1,
    --- max number of ray bounces
    max_depth    = 16,
    --- vertical field of view, in degrees
    vfov         = 90,
    --- point camera is looking from
    lookfrom     = Vec {},
    --- point camera is looking at
    lookat       = Vec { z = -1 },
    --- camera-relative "up" direction
    vup          = Vec { y = 1 },
}
Camera.__index = Camera

--- @class CameraInit
--- @field image_width  integer?
--- @field image_height integer?
--- @field vfov         number?

--- @param init (CameraInit | Camera)?
function Camera:new(init)
    init = init or self
    local cam = {}
    for k, v in pairs(init) do cam[k] = v end
    return setmetatable(cam, Camera)
end

function Camera:render(world)
    self.world = world

    local image_width = self.image_width
    local image_height = self.image_height
    local aspect_ratio = image_width / image_height

    self.center = self.lookfrom

    -- determine viewport dimensions
    local focal_length = Vec.len(self.lookat - self.lookfrom)
    local theta = self.vfov * math.pi / 180.0
    local h = math.tan(theta / 2.0)
    local viewport_height = 2.0 * h * focal_length
    local viewport_width = viewport_height * aspect_ratio

    --
    self.w = Vec.unit(self.lookfrom - self.lookat)
    self.u = Vec.unit(Vec.cross(self.vup, self.w))
    self.v = Vec.cross(self.w, self.u)

    local viewport_u = viewport_width * self.u
    local viewport_v = -viewport_height * self.v

    self.pixel_delta_u = viewport_u / image_width
    self.pixel_delta_v = viewport_v / image_height

    local viewport_upper_left = self.center -
        (focal_length * self.w) -
        viewport_u / 2 -
        viewport_v / 2
    self.pixel00_loc = viewport_upper_left + 0.5 * (self.pixel_delta_u + self.pixel_delta_v)

    -- 
    local progress = ProgressReport:new(self.image_width * self.image_height * self.spp, "Rendering")

    -- Create an image
    local image_data = {}
    local image_name = 'render'
    tev:createimage(image_name, self.image_width, self.image_height, { "R", "G", "B" })

    -- Render image in waves
    local wave_start, wave_end, next_wave_size = 0, 1, 1

    while wave_start < self.spp do
        -- Render image
        for sample_num = wave_start, (wave_end - 1) do
            progress:printreport()
            for y = 0, image_height - 1 do
                for x = 0, image_width - 1 do
                    local r = self:get_ray(x, y)
                    local color = self:ray_color(r, self.max_depth)
                    
                    local i = 1 + (y * image_width + x) * 3
                    image_data[i + 0] = (image_data[i + 0] or 0.0) + color.r
                    image_data[i + 1] = (image_data[i + 1] or 0.0) + color.g
                    image_data[i + 2] = (image_data[i + 2] or 0.0) + color.b
                end
                progress:update(image_width)
            end
        end

        -- Update start and end wave
        wave_start = wave_end
        wave_end = math.min(self.spp, wave_end + next_wave_size)
        next_wave_size = math.min(next_wave_size * 2, 64)

        -- Optionally dump the current image
        local function develop(raw)
            local developed = {}
            for i = 1, #raw do
                developed[i] = raw[i] / wave_start
            end
            return developed
        end
        tev:updateimage(image_name, 0, 0, self.image_width, self.image_height, develop(image_data))
    end

    -- Finish!
    progress:done()
end

function Camera:get_ray(x, y)
    local offx, offy = sample_square()
    local pixel_sample = self.pixel00_loc +
        ((x + offx) * self.pixel_delta_u) +
        ((y + offy) * self.pixel_delta_v)
    local ray_direction = pixel_sample - self.center
    return Ray(self.center, ray_direction)
end

function Camera:ray_color(r, max_depth)
    if max_depth <= 0 then return Color.BLACK end

    local hit, hr = self.world:hit(r, Interval(0.0001, math.huge))
    if hit then
        local scatter, att = hr.mat:scatter(r, hr)
        if scatter then
            local col = self:ray_color(scatter, max_depth - 1)
            if att then
                return Color.attenuate(col, att)
            end
            return col
        end
        return Color.BLACK
    end

    local unit = Vec.unit(r.d)
    local a = 0.5 * (unit.y + 1.0)
    return math.lerp(a, Color.WHITE, Color.SKY)
end

function Camera:__tostring()
    return string.format([[
Camera {
    lookfrom = %s,
    lookat = %s,
}
    ]], self.lookfrom, self.lookat)
end
