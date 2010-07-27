require "testcase"

WasRun = testcase.TestCase{name="testMethod",}

function WasRun:testMethod ()
end

function WasRun:testForcedError ()
    error("forced error")
end

TestCaseTest = testcase.TestCase{}

function TestCaseTest:setUp ()
    self.test = WasRun{}
end

function TestCaseTest:tearDown()
    self.test = nil
end

function TestCaseTest:testWasRun ()
    local result = testcase.TestResult{}
    self:assertEqual( "", self.test.log)
    self.test:run(result)
    print(result:failureDetails())
    local expected_log = "setUp testMethod tearDown"
    self:assertEqual( expected_log, self.test.log)
end

function TestCaseTest:testTearDownEvenOnTestError ()
    local result = testcase.TestResult{}
    self:assertEqual("", self.test.log)
    self.test.name = "testForcedError"
    self.test:run(result)
    local expected_log = "setUp tearDown"
    self:assertEqual( expected_log, self.test.log)
end

function TestCaseTest:testSuite ()
    local suite = testcase.TestSuite{}
    local result = testcase.TestResult{}
    suite:add(WasRun{name="testMethod"})
    suite:add(WasRun{name="testForcedError"})
    suite:run(result)
    self:assertEqual("2 run, 1 failed", result:summary())
end

local result = testcase.TestResult{}
suite = testcase.TestSuite{}
suite:add(TestCaseTest{"testWasRun"})
suite:add(TestCaseTest{"testTearDownEvenOnTestError"})
suite:add(TestCaseTest{"testSuite"})
suite:run(result)
assert(false)
print(result:summary())
if not result:status() then
end
