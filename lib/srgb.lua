SRGB = {}

local srgb_gamma = 2.4
local srgb_gamma_inv = 1 / srgb_gamma

--- @param srgb number
function SRGB.to_linear(srgb)
    if srgb < 0.04045 then
        return srgb / 12.92
    else
        return ((srgb + 0.055) / 1.055) ^ srgb_gamma
    end
end

--- @param linear number
function SRGB.from_linear(linear)
    if linear < 0.0031308 then
        return 12.92 * linear
    else
        return 1.055 * linear ^ srgb_gamma_inv - 0.055
    end
end
