--- Null material. A blackhole.

NullMat = {}

function NullMat:scatter()
    return nil, nil
end

function NullMat.__tostring()
    return "NullMat"
end

setmetatable(NullMat, {
    __call = function() return NullMat end,
    __index = NullMat,
    __tostring = NullMat.__tostring
})
