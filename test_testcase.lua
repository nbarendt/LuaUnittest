
require "object"
require "testcase"
require "sampletestcases"

TestCaseTest = testcase.TestCase{}

function TestCaseTest:testSimpleExecutionOrder ()
    local result = testcase.TestResult{}
    test = sampletestcases.TestSimplestCase{name="testWillAlwaysPass"}
    self:assertEqual( "", test.log)
    test:run(result)
    local expected_log = "setUp testWillAlwaysPass tearDown"
    self:assertEqual( expected_log, test.log)
end

function TestCaseTest:testTearDownEvenOnTestError ()
    local result = testcase.TestResult{}
    test = sampletestcases.TestForcedErrorCase{}
    self:assertEqual("", test.log)
    test.name = "testWillError"
    test:run(result)
    local expected_log = "setUp tearDown"
    self:assertEqual( expected_log, test.log)
end

function TestCaseTest:testSuite ()
    local suite = testcase.TestSuite{}
    local result = testcase.TestResult{}
    suite:add(sampletestcases.TestSimplestCase{})
    suite:add(sampletestcases.TestForcedErrorCase{})
    suite:run(result)
    self:assertStartsWith("Ran 2 tests", result:summary())
    self:assertContains("FAILED (failed=1)", result:summary())
end


function TestCaseTest:testSuiteAutoDiscoversTestMethods ()
    local suite = testcase.TestSuite{}
    local result = testcase.TestResult{}
    suite:add(sampletestcases.TestMultipleTestsCase)
    suite:run(result)
    self:assertEqual(true, result:status())
    self:assertEqual(3, result:getRunCount())
    self:assertEqual(0, result:getFailureCount())
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
