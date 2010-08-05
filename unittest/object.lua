module("unittest.object", package.seeall)

local function clone(t)
    local u = setmetatable( {}, getmetatable(t))
    for k, v in pairs(t) do
        u[k] = v
    end
    return u
end

local function merge(t, u)
    local r = clone(t)
    for k, v in pairs(u) do
        r[k] = v
    end
    return r
end

local function rearrange(p, t)
    local r = clone(t)
    for k, v in pairs(p) do
        if t[k] ~= nil then -- only rearrange if the values provided are non-nil
            r[v] = t[k]
            r[k] = nil
        end
    end
    return r
end

Object = {
    _init = {},
    _clone = function (self, values)
        local object = merge(self, rearrange(self._init, values))
        setmetatable(object, object)
        return object
        end,
    __call = function (...)
        return (...)._clone(...)
        end,
    
}
setmetatable(Object, Object)


