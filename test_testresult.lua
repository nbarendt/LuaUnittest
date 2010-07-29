require "testcase"
require "sampletestcases"

TestResultTest = testcase.TestCase{}
TestResultTest.test_data = {
    {name='testabc', start_time=0.5, end_time=1, err=nil},
    {name='test123', start_time=2, end_time=3.75, err='failure' },
}

function TestResultTest:add_test_data (result)
    for i, v in ipairs(self.test_data) do
        result:started(v.name, v.start_time)
        result:completed(v.end_time, v.err)
    end
end

function TestResultTest:getExpectedCount ()
    return #self.test_data
end

function TestResultTest:getExpectedFailureCount ()
    local count = 0
    for k, v in pairs(self.test_data) do
        if v.err then count = count + 1 end
    end
    return count
end

function TestResultTest:testEmptyResultReportsSuccess ()
    local result = testcase.TestResult{}
    self:assertEqual(true, result:status() )
end

function TestResultTest:testEmptyResultSuccessSummary ()
    local result = testcase.TestResult{}
    local expected = "Ran 0 tests in 0 seconds"
    self:assertEqual(expected, result:summary())
end

function TestResultTest:testResultsSummaryFailureAndExectionTimeExpected ()
    local result = testcase.TestResult {}
    self:add_test_data(result)
    local expected = "Ran 2 tests in 3.25 seconds FAILED (failed=1)" 
    self:assertEqual(expected, result:summary())
end

function TestResultTest:testResultReportsExpectedRunCount ()
    local result = testcase.TestResult{}
    self:add_test_data(result)
    self:assertEqual(self:getExpectedCount(), result:getRunCount())
end

function TestResultTest:testResultReportsExpectedFailureCount ()
    local result = testcase.TestResult{}
    self:add_test_data(result)
    self:assertEqual(self:getExpectedFailureCount(), result:getFailureCount())
end

function TestResultTest:testResultIterator ()
    local result = testcase.TestResult{}
    self:add_test_data(result)
    local count = 0
    for res in result:getResults() do
        count = count + 1
        for k, v in pairs(self.test_data[count]) do
            self:assertEqual(v, res[k])
        end    
    end
    self:assertEqual(self:getExpectedCount(), count)
end

function TestResultTest:testFailureIterator ()
    local result = testcase.TestResult{}
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
end

function TestResultTest:testFailureReporter ()
    local result = testcase.TestResult{}
    self:add_test_data(result)
    local reporter = testcase.FailureReporter{result}
    local expected = [[
Failures:
--------------------------------------------------------------------------------
TEST:  test123
--------------------------------------------------------------------------------
failure
]]
    self:assertEqual(expected, reporter:report())
end


local result = testcase.TestResult{}
suite = testcase.TestSuite{}
suite:add(TestResultTest)
suite:run(result)
print(result:summary())
if not result:status() then
    print(testcase.FailureReporter{result}:report())
else
    print("OK")
end
