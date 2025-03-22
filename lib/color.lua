require 'lib/interval'
require 'lib/srgb'

--- @class Color
--- @field r number
--- @field g number
--- @field b number
Color = {
    r = 0.0,
    g = 0.0,
    b = 0.0,
}
Color.__index = Color

local function new(c)
    return setmetatable(c, Color)
end

setmetatable(Color, {
    --- @return Color
    __call = function(self, init)
        return new {
            r = init[1] or init.r or self.r,
            g = init[2] or init.g or self.g,
            b = init[3] or init.b or self.b,
        }
    end
})

function Color.from_srgb(r, g, b)
    return new {
        r = SRGB.to_linear(r / 255),
        g = SRGB.to_linear(g / 255),
        b = SRGB.to_linear(b / 255),
    }
end

function Color:to_srgb()
end

function Color:attenuate(att)
    return new {
        r = att.r * self.r,
        g = att.g * self.g,
        b = att.b * self.b,
    }
end

function Color.__add(c1, c2)
    return new {
        r = c1.r + c2.r,
        g = c1.g + c2.g,
        b = c1.b + c2.b,
    }
end

function Color.__mul(s, self)
    return new {
        r = s * self.r,
        g = s * self.g,
        b = s * self.b,
    }
end

local intensity = Interval(0, 0.999999)

local function clamp(c)
    return intensity:clamp(c)
end

function Color:__tostring()
    return string.format("%d %d %d",
        math.floor(256 * SRGB.from_linear(clamp(self.r))),
        math.floor(256 * SRGB.from_linear(clamp(self.g))),
        math.floor(256 * SRGB.from_linear(clamp(self.b)))
    )
end

Color.BLACK = new { r = 0.0, g = 0.0, b = 0.0 }
Color.WHITE = new { r = 1.0, g = 1.0, b = 1.0 }
Color.GRAY  = new { r = 0.5, g = 0.5, b = 0.5 }
Color.RED   = new { r = 1.0 }
Color.GREEN = new { g = 1.0 }
Color.BLUE  = new { b = 1.0 }
Color.SKY   = new { r = 0.5, g = 0.7, b = 1.0 }
