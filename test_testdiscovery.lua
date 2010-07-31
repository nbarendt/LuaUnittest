module(..., package.seeall)

require "unittest"
require "table"

TestTestDiscovery = unittest.TestCase{

    setUp = function(self)
        self.sample_filename = "sampleunittests.lua"
        self.expected_test_cases = {'TestCaseWithLogging',
         'TestSimplestCase', 'TestForcedErrorCase', 'TestMultipleTestsCase'}
        self.expected_test_count = 5
        table.sort(self.expected_test_cases)
        self.sample_filename = "sampletestcases.lua"
    end,

    testDiscoverWillReturnExpectedunittestNames = function (self) 
        local tmp_module, actual_test_cases = unittest.discoverTestCases(
            self.sample_filename)
        self:assertNotNil(tmp_module)
        table.sort(actual_test_cases)
        for k, v in pairs(self.expected_test_cases) do
            self:assertEqual(v, actual_test_cases[k])
        end
    end,

    testSuiteWillContainExpectedunittests = function (self)
        local suite = unittest.TestSuite{{self.sample_filename}}
        self:assertEqual( self.expected_test_count, #suite.tests)
        local result = unittest.TestResult{}
        suite:run(result)
        self:assertEqual(false, result:status())
        self:assertStartsWith("Ran 5 tests", result:summary())
        self:assertContains("FAILED (failed=1)", result:summary())
    end, 
}
