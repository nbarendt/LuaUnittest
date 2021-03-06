module( ..., package.seeall)

require "unittest"

TestCaseWithLogging = unittest.TestCase{log=""}
function TestCaseWithLogging:setUp ()
    self.log = "setUp"
end
function TestCaseWithLogging:tearDown ()
    self.log = self.log .. " " .. "tearDown"
end

TestSimplestCase = TestCaseWithLogging{}
function TestSimplestCase:testWillAlwaysPass ()
    self.log = self.log .. " " .. "testWillAlwaysPass"
end

TestForcedErrorCase = TestCaseWithLogging{}
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

