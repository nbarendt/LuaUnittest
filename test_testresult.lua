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
    suite:add(WasRun)
    suite:run(result)
    self:assertEqual("2 run, 1 failed", result:summary())
end

local result = testcase.TestResult{}
suite = testcase.TestSuite{}
suite:add(TestCaseTest)
suite:run(result)
print(result:summary())
if not result:status() then
    for res in result:getFailures() do
        print(string.format("TEST: %s", res.name))
        print(string.format("%s\n--------", res.err))
    end
end
