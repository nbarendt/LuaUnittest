module( ..., package.seeall)

local object = require "unittest.object"

test_baseclass = object.Object{ __call = function (...)
    o = (...)._clone(...)
    o.a = 0
    o.b = {}
    return o
    end,
    }

function test_baseclass:count ()
    self.a = self.a + 1
end

function test_baseclass:add(foo)
    self.b[#self.b + 1] = foo
end

one = test_baseclass{}
two = test_baseclass{}

assert(one.a == 0)
assert(two.a == 0)

one:count()
assert(one.a == 1)
assert(two.a == 0)

two:add("hello")
assert(0 == #one.b)
assert(1 == #two.b)
