--- @class Material 
Material = {}

--- @param r Ray
--- @param hr HitRec
--- @return Ray? scattered
--- @return Color? attenuation
function Material:scatter(r, hr)
    -- scattered ray
    local scattered = nil
    -- color
    local attenuation = Color.BLACK

    return scattered, attenuation
end
