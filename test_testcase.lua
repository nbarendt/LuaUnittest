module(..., package.seeall)

require "object"
require "unittest"
require "sampletestcases"

TestUnitTest = unittest.TestCase{

    testSimpleExecutionOrder = function (self) 
        local result = unittest.TestResult{}
        local test = sampletestcases.TestSimplestCase{test="testWillAlwaysPass"}
        self:assertEqual( "", test.log)
        test:run(result)
        local expected_log = "setUp testWillAlwaysPass tearDown"
        self:assertEqual( expected_log, test.log)
    end,

    testTearDownEvenOnTestError = function (self) 
        local result = unittest.TestResult{}
        local test = sampletestcases.TestForcedErrorCase{}
        self:assertEqual("", test.log)
        test.test = "testWillError"
        test:run(result)
        local expected_log = "setUp tearDown"
        self:assertEqual( expected_log, test.log)
    end,

    testTestCaseNameIsJustTestMethodByDefault = function (self)
        local test = unittest.TestCase{'abc'}
        self:assertEqual( 'abc', test:getTestName())        
    end,

    testTestCaseNameIsClassNamePlusTestMethod = function (self)
        local test = unittest.TestCase{'abc', name='123'}
        self:assertEqual( '123:abc', test:getTestName())        
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
