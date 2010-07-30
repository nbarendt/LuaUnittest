module(..., package.seeall)

require "unittest"
require "sampletestcases"

TestResultTest = unittest.TestCase{

    test_data = {
        {name='testabc', start_time=0.5, end_time=1, err=nil},
        {name='test123', start_time=2, end_time=3.75, err='failure' },
    }, 

    add_test_data = function (self, result)
        for i, v in ipairs(self.test_data) do
            result:started(v.name, v.start_time)
            result:completed(v.end_time, v.err)
        end
    end,

    getExpectedCount = function (self)
        return #self.test_data
    end,

    getExpectedFailureCount = function (self)
        local count = 0
        for k, v in pairs(self.test_data) do
            if v.err then count = count + 1 end
        end
        return count
    end,

    testEmptyResultReportsSuccess = function (self) 
        local result = unittest.TestResult{}
        self:assertEqual(true, result:status() )
    end, 

    testEmptyResultSuccessSummary = function (self)
        local result = unittest.TestResult{}
        local expected = "Ran 0 tests in 0 seconds"
        self:assertEqual(expected, result:summary())
    end, 

    testResultsSummaryFailureAndExectionTimeExpected = function (self)
        local result = unittest.TestResult {}
        self:add_test_data(result)
        local expected = "Ran 2 tests in 3.25 seconds FAILED (failed=1)" 
        self:assertEqual(expected, result:summary())
    end,

    testResultReportsExpectedRunCount = function (self)
        local result = unittest.TestResult{}
        self:add_test_data(result)
        self:assertEqual(self:getExpectedCount(), result:getRunCount())
    end,

    testResultReportsExpectedFailureCount = function (self)
        local result = unittest.TestResult{}
        self:add_test_data(result)
        self:assertEqual(self:getExpectedFailureCount(),
            result:getFailureCount())
    end,

    testResultIterator = function (self)
        local result = unittest.TestResult{}
        self:add_test_data(result)
        local count = 0
        for res in result:getResults() do
            count = count + 1
            for k, v in pairs(self.test_data[count]) do
                self:assertEqual(v, res[k])
            end    
        end
        self:assertEqual(self:getExpectedCount(), count)
    end,

    testFailureIterator = function (self)
        local result = unittest.TestResult{}
        self:add_test_data(result)
        local count = 1
        local failure_count = 0
        for res in result:getFailures() do
            failure_count = failure_count + 1
            while not self.test_data[count].err do count = count + 1 end
            for k, v in pairs(self.test_data[count]) do
                self:assertEqual(v, res[k])
            end    
        end
        self:assertEqual(self:getExpectedFailureCount(), failure_count)
    end,

    testFailureReporter = function (self)
        local result = unittest.TestResult{}
        self:add_test_data(result)
        local reporter = unittest.FailureReporter{result}
        local expected = [[
Failures:
--------------------------------------------------------------------------------
TEST:  test123
--------------------------------------------------------------------------------
failure
]]
        self:assertEqual(expected, reporter:report())
    end,

}

