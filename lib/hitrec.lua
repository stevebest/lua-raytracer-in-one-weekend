--- @class HitRec
--- @field t number
--- @field p Vec
--- @field normal Vec
--- @field mat Material
HitRec = {
    t = math.huge,
    p = Vec {},
    normal = Vec {},
    --- front-facing
    front = true,
    -- mat = nil,
}
HitRec.__index = HitRec

function HitRec.new(init)
    local normal = init.normal
    local front = true
    if Vec.dot(init.r.d, normal) > 0.0 then
        -- ray is inside the object
        normal = -normal
        front = false
    end

    return setmetatable({
        t = init.t,
        p = init.p, -- or Ray.at(init.r, init.t),
        normal = normal,
        front = front,
        mat = init.mat,
    }, HitRec)
end

setmetatable(HitRec, {
    __call = function(t, ...)
        return t.new(...)
    end
})

function HitRec:__tostring()
    return string.format([[
HitRec {
    t = %s,
    p = %s,
    normal = %s,
    mat = %s,
}]], self.t, self.p, self.normal, self.mat)
end
