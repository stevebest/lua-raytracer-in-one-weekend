#!/usr/bin/env lua

require 'lib'

local function usage()
    return [[
usage: ./rt SCENE [OPTIONS]

Arguments:
    SCENE       A scene description file

Options:
    --spp=64    Number of samples per pixel
]]
end

--- @class Params
--- @field scene string
--- @field spp integer
local Params = {
    scene = 'scenes/Scene.lua',
    spp = 4,
}

--- @return Params?
function Params:parse(arg)
    if #arg == 0 then
        return nil
    end

    return {
        scene = arg[1] or self.scene,
        spp = tonumber(arg[2]) or self.spp,
    }
end

--- @param arg string[]
local function main(arg)
    local params = Params:parse(arg)
    if not params then
        return print(usage())
    end

    local scene, camera = dofile(params.scene)
    scene = BVH.new(scene)
    -- scene = HitList:new(scene)

    camera = camera or Camera:new {}
    -- camera.image_width  = 400
    -- camera.image_height = 225
    camera.spp          = params.spp
    camera.max_depth    = 16

    camera:render(scene)
end

main(arg)
