local socket = require "socket"

local TevPort = 14158

--- @param fmt string
local function packtable(fmt)
    return function(t)
        local s = {}
        for i, v in ipairs(t) do
            s[i] = string.pack(fmt, v)
        end
        return table.concat(s)
    end
end

local packu64s = packtable("<I8")
local packf32s = packtable("<f")

-- This stays in sync with `IpcPacket::EType` from Ipc.h
--- @enum PacketType
local PacketType = {
    OpenImage      = 7, -- v2
    ReloadImage    = 1,
    CloseImage     = 2,
    CreateImage    = 4,
    UpdateImage    = 6, -- v3
    VectorGraphics = 8,
}

--- @class Packet
--- @field type PacketType
local Packet = {}

function Packet:new(type)
    local o = { type = type }
    setmetatable(o, self)
    self.__index = self
    self.__tostring = Packet.__tostring
    return o
end

function Packet:payload()
end

function Packet:__tostring()
    local payload = self:payload()
    local len = 4 + 1 + #payload -- 4 bytes for len, 1 byte for type
    return table.concat {
        string.pack("<I", len),
        string.pack("<b", self.type),
        payload,
    }
end

--- @class NamePacket: Packet
local NamePacket = Packet:new()
NamePacket.name = ""

function NamePacket:payload()
    return string.pack("z", self.name)
end

--- @class Grabfocus
local Grabfocus = {}
Grabfocus.grabfocus = true

function Grabfocus:payload()
    return string.pack("<b", self.grabfocus and 1 or 0)
end

--- @class CloseImage: NamePacket
local CloseImage = NamePacket:new(PacketType.CloseImage)

--- @class ReloadImage: NamePacket, Grabfocus
local ReloadImage = NamePacket:new(PacketType.ReloadImage)
ReloadImage.grabfocus = false

function ReloadImage:payload()
    return table.concat {
        Grabfocus.payload(self),
        NamePacket.payload(self),
    }
end

--- @class OpenImage: NamePacket, Grabfocus
local OpenImage = NamePacket:new(PacketType.OpenImage)
OpenImage.grabfocus = false
OpenImage.channel = ""

function OpenImage:payload()
    return table.concat {
        Grabfocus.payload(self),
        NamePacket.payload(self),
        string.pack("z", self.channel),
    }
end

--- @class Dimensions
local Dimensions = { width = 0, height = 0 }
function Dimensions:payload()
    return string.pack("<I<I", self.width, self.height)
end

--- @class Channels
--- @field channels string[]
local Channels = { channels = {} }

function Channels:payload()
    local packed = {}
    for i, c in pairs(self.channels) do
        packed[i] = string.pack("z", c)
    end
    table.insert(packed, 1, string.pack("<I", #self.channels))
    return table.concat(packed)
end

--- @class PixelData
--- @field data number[]
local PixelData = {}
PixelData.data = {}

function PixelData:payload()
    return packf32s(self.data)
end

--- @class CreateImage: NamePacket, Grabfocus, Dimensions, Channels
local CreateImage = NamePacket:new(PacketType.CreateImage)
CreateImage.grabfocus = true
CreateImage.channels = { "R", "G", "B" }
CreateImage.width = 100
CreateImage.height = 100

function CreateImage:payload()
    return table.concat {
        Grabfocus.payload(self),
        NamePacket.payload(self),
        Dimensions.payload(self),
        Channels.payload(self),
    }
end

--- @class UpdateImage: NamePacket, Grabfocus, Channels, Dimensions, PixelData
local UpdateImage = NamePacket:new(PacketType.UpdateImage)
UpdateImage.grabfocus = true
UpdateImage.channels = { "R", "G", "B" }
UpdateImage.x = 0
UpdateImage.y = 0
UpdateImage.width = 0
UpdateImage.height = 0
UpdateImage.channeloffsets = { 0, 1, 2 }
UpdateImage.channelstrides = { 3, 3, 3 }
UpdateImage.data = {}

function UpdateImage:payload()
    return table.concat {
        Grabfocus.payload(self),
        NamePacket.payload(self),
        Channels.payload(self),
        string.pack("<I<I", self.x, self.y),
        Dimensions.payload(self),
        packu64s(self.channeloffsets),
        packu64s(self.channelstrides),
        PixelData.payload(self),
    }
end

--- @param port number?
--- @return TevClient
local function tev(port)
    port = port or TevPort

    --- @class TevClient
    local client = {}

    function client:connect()
        self.socket = socket.tcp()
        local res, err = self.socket:connect('127.0.0.1', port)
        if err then
            client.socket = nil
        end
        return res, err
    end

    client:connect()

    --- @param packet Packet
    function client:send(packet)
        if not client.socket then
            local res, err = client:connect()
            if err then return res, err end
        end
        local res, err = self.socket:send(packet:__tostring())
        if err then
            client.socket = nil
        end
        return res, err
    end

    --- @param imagePath string
    function client:openimage(imagePath, channel)
        --- @type OpenImage
        local packet = OpenImage:new()
        packet.name = imagePath
        packet.channel = channel or packet.channel

        return self:send(packet)
    end

    function client:closeimage(name)
        --- @type CloseImage
        local packet = CloseImage:new()
        packet.name = name

        return self:send(packet)
    end

    function client:createimage(name, width, height, channels)
        --- @type CreateImage
        local packet = CreateImage:new()
        packet.name = name
        packet.channels = channels or CreateImage.channels
        packet.width = width or CreateImage.width
        packet.height = height or CreateImage.height

        return self:send(packet)
    end

    function client:updateimage(name, x, y, w, h, data)
        --- @type UpdateImage
        local packet = UpdateImage:new()
        packet.name = name
        packet.x = x
        packet.y = y
        packet.width = w
        packet.height = h
        packet.data = data

        return self:send(packet)
    end

    return client
end

return tev
