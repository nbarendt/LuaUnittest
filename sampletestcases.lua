module( ..., package.seeall)

require "testcase"

LoggingTestCase = testcase.TestCase{log=""}
function LoggingTestCase:setUp ()
    self.log = "setUp"
end
function LoggingTestCase:tearDown ()
    self.log = self.log .. " " .. "tearDown"
end

SimplestTestCase = LoggingTestCase{}
function SimplestTestCase:testWillAlwaysPass ()
    self.log = self.log .. " " .. "testWillAlwaysPass"
end

ForcedErrorTestCase = LoggingTestCase{}
function ForcedErrorTestCase:testWillError ()
    error("forced error")
end

MultipleTestsTestCase = testcase.TestCase{}
function MultipleTestsTestCase:testWillAlwaysPass1 ()
end

function MultipleTestsTestCase:testWillAlwaysPass2 ()
end

function MultipleTestsTestCase:testWillAlwaysPass3 ()
end

