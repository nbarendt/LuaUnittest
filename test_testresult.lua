require "testcase"
require "sampletestcases"

TestResultTest = testcase.TestCase{}
TestResultTest.test_data = {
    {name='testabc', start_time=0, end_time=1, err=nil},
    {name='test123', start_time=2, end_time=3, err='failure' },
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
    self:assertEqual("0 run, 0 failed", result:summary())
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


local result = testcase.TestResult{}
suite = testcase.TestSuite{}
suite:add(TestResultTest)
suite:run(result)
print(result:summary())
if not result:status() then
    for res in result:getFailures() do
        print(string.format("TEST: %s", res.name))
        print(string.format("%s\n--------", res.err))
    end
end
