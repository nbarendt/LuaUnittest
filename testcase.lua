module( ..., package.seeall)

require "object"
require "os"

TestCase = object.Object{log="", _init={"name",},  name=""}

function TestCase:setUp()
end

function TestCase:tearDown()
end

function TestCase:assertEqual(expected, actual, msg)
    if expected ~= actual then
        if nil == msg then
            msg = string.format("%s ~= %s", tostring(expected),
                tostring(actual))
        end
        error(msg)
    end
end

function TestCase:run (result)
    result:started(self.name, os.clock())
    self:setUp()
    self.log = self.log .. "setUp"
    local method = self[self.name]
    local status, err = pcall(function () method(self) end)
    if status then
        self.log = self.log .. " " .. self.name
    end
    self:tearDown()
    self.log = self.log .. " " .. "tearDown"
    result:completed( os.clock(), err)
end

TestResult = object.Object{ __call = function(...)
    o = (...)._clone(...)
    o.testruns = {}
    return o
    end,
    }

function TestResult:started (test_name, start_time)
    self.testruns[ #self.testruns + 1 ] = {name=test_name, 
        start_time=start_time}
end

function TestResult:completed( end_time, err)
    local curr_index = #self.testruns
    self.testruns[ curr_index ].end_time = end_time
    self.testruns[ curr_index ].err = err
end

function TestResult:getRunCount ()
    return #self.testruns
end

function TestResult:getFailureCount ()
    local count = 0
    for _, testrun in pairs(self.testruns) do
        if nil ~= testrun.err then
            count = count + 1
        end
    end
    return count
end

function TestResult:summary ()
    return string.format("%d run, %d failed", self:getRunCount(),
        self:getFailureCount())
end

function TestResult:status ()
    return 0 == self:getFailureCount()
end

function TestResult:getResults ()
    local state = self.testruns
    local current_run = 1
    local iterator = function ()
        result = state[current_run]
        current_run = current_run + 1
        return result
    end
    return iterator, nil, nil 
end

function TestResult:getFailures ()
    local state = self.testruns
    local current_run = 1
    local iterator = function ()
        while true do
            result = state[current_run]
            current_run = current_run + 1
            if not result then return nil end
            if nil ~= result.error then return result end
        end
        return result
    end
    return iterator, nil, nil 
end

TestSuite = TestCase{ __call = function (...)
    o = (...)._clone(...)
    o.tests = {}
    return o
    end, }

function TestSuite:add(test)
    self.tests[#self.tests + 1] = test
end

function TestSuite:run(result)
    for i, test in ipairs(self.tests) do
        test:run(result)
    end
end


