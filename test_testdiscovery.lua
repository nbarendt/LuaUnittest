module(..., package.seeall)

require "testcase"
require "table"

TestTestDiscovery = testcase.TestCase{

    setUp = function(self)
        self.sample_filename = "sampletestcases.lua"
        self.expected_test_cases = {'TestCaseWithLogging',
         'TestSimplestCase', 'TestForcedErrorCase', 'TestMultipleTestsCase'}
        self.expected_test_count = 5
        table.sort(self.expected_test_cases)
        self.sample_filename = "sampletestcases.lua"
    end,

    testDiscoverWillReturnExpectedTestCaseNames = function (self) 
        local tmp_module, actual_test_cases = testcase.discoverTestCases(
            self.sample_filename)
        self:assertNotNil(tmp_module)
        table.sort(actual_test_cases)
        for k, v in pairs(self.expected_test_cases) do
            self:assertEqual(v, actual_test_cases[k])
        end
    end,

    testSuiteWillContainExpectedTestCases = function (self)
        local suite = testcase.TestSuite{{self.sample_filename}}
        self:assertEqual( self.expected_test_count, #suite.tests)
        local result = testcase.TestResult{}
        suite:run(result)
        self:assertEqual(false, result:status())
        self:assertStartsWith("Ran 5 tests", result:summary())
        self:assertContains("FAILED (failed=1)", result:summary())
    end, 
}
