module(..., package.seeall)

require "object"
require "unittest"
require "sampletestcases"

unittestTest = unittest.TestCase{

    testSimpleExecutionOrder = function (self) 
        local result = unittest.TestResult{}
        test = sampletestcases.TestSimplestCase{name="testWillAlwaysPass"}
        self:assertEqual( "", test.log)
        test:run(result)
        local expected_log = "setUp testWillAlwaysPass tearDown"
        self:assertEqual( expected_log, test.log)
    end,

    testTearDownEvenOnTestError = function (self) 
        local result = unittest.TestResult{}
        test = sampletestcases.TestForcedErrorCase{}
        self:assertEqual("", test.log)
        test.name = "testWillError"
        test:run(result)
        local expected_log = "setUp tearDown"
        self:assertEqual( expected_log, test.log)
    end,

    testSuite = function (self)
        local suite = unittest.TestSuite{}
        local result = unittest.TestResult{}
        suite:add(sampletestcases.TestSimplestCase{})
        suite:add(sampletestcases.TestForcedErrorCase{})
        suite:run(result)
        self:assertStartsWith("Ran 2 tests", result:summary())
        self:assertContains("FAILED (failed=1)", result:summary())
    end,

    testSuiteAutoDiscoversTestMethods = function (self)
        local suite = unittest.TestSuite{}
        local result = unittest.TestResult{}
        suite:add(sampletestcases.TestMultipleTestsCase)
        suite:run(result)
        self:assertEqual(true, result:status())
        self:assertEqual(3, result:getRunCount())
        self:assertEqual(0, result:getFailureCount())
    end,
}
