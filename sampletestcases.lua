module( ..., package.seeall)

require "unittest"

unittestWithLogging = unittest.TestCase{log=""}
function unittestWithLogging:setUp ()
    self.log = "setUp"
end
function unittestWithLogging:tearDown ()
    self.log = self.log .. " " .. "tearDown"
end

TestSimplestCase = unittestWithLogging{}
function TestSimplestCase:testWillAlwaysPass ()
    self.log = self.log .. " " .. "testWillAlwaysPass"
end

TestForcedErrorCase = unittestWithLogging{}
function TestForcedErrorCase:testWillError ()
    error("forced error")
end

TestMultipleTestsCase = unittest.TestCase{}
function TestMultipleTestsCase:testWillAlwaysPass1 ()
end

function TestMultipleTestsCase:testWillAlwaysPass2 ()
end

function TestMultipleTestsCase:testWillAlwaysPass3 ()
end

