--- @class Hittable
local Hittable = {}

--- @param r Ray
--- @param rt Interval
--- @return boolean hit # whether a ray hits an object
--- @return HitRec hr # a hit record
function Hittable:hit(r, rt)
    ---@diagnostic disable-next-line: return-type-mismatch
    return false, nil
end

--- @return AABB
function Hittable:aabb()
    ---@diagnostic disable-next-line: return-type-mismatch
    return nil
end
