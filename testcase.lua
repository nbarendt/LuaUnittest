module( ..., package.seeall)

require "object"
require "os"
require "debug"

TestCase = object.Object{_init={"name",},  name=""}

function TestCase:setUp()
end

function TestCase:tearDown()
end

function TestCase:assertEqual(expected, actual, msg)
    assert( expected == actual, msg or
            string.format('"%s" ~= "%s"', tostring(expected),
                tostring(actual)))
end

function TestCase:assertNotNil(value, msg)
    assert(value ~= nil, msg or string.format("value %s of type %s is not nil",
        tostring(value), type(value)))
end

function TestCase:assertStartsWith(prefix, actual, msg)
    self:assertEqual(prefix, actual:sub(1, prefix:len()), msg or 
        string.format('"%s" does not start with "%s"', actual, prefix))
end

function TestCase:assertContains(pattern, actual, msg)
    assert(actual:find(pattern, 1, true), msg or
        string.format('"%s" not found in "%s"', pattern, actual))
end

function TestCase:run (result)
    result:started(self.name, os.clock())
    self:setUp()
    local method = self[self.name]
    local err_reporter = function (err)
        return err .. "\n" .. debug.traceback()
    end
    local status, err = xpcall(function () method(self) end,
        err_reporter)
    self:tearDown()
    result:completed( os.clock(), err)
end

function getTestMethodNames (testobj)
    local state = testobj 
    local curr_key = nil
    local iterator = function ()
        while true do
            curr_key, curr_value = next(state, curr_key)
            if not curr_value then return nil end
            if type(curr_value) == "function" and string.sub(curr_key, 1, 4) ==
                "test" then return curr_key
            end
        end
    end
    return iterator, nil, nil
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
    local start_time = 0
    local end_time = 0
    if self:getRunCount() > 0 then
        start_time = self.testruns[1].start_time
        end_time = self.testruns[#self.testruns].end_time
    end
    local elapsed_time = end_time - start_time
    local res = string.format("Ran %d tests in %s seconds", self:getRunCount(),
        elapsed_time)
    local failures = self:getFailureCount()
    if failures > 0 then
        res = res .. " " .. string.format("FAILED (failed=%d)", failures) 
    end
    return res
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
    local current_result = 1
    local iterator = function ()
        while true do
            result = state[current_result]
            current_result = current_result + 1
            if not result then return nil end
            if nil ~= result.err then return result end
        end
        return result
    end
    return iterator, nil, nil 
end

FailureReporter = object.Object{_init={"testResults"}}

function FailureReporter:report ()
    local sep = string.rep("-", 80)
    local res = {"Failures:", sep}
    for run in self.testResults:getFailures() do
        res[ #res + 1] = string.format("TEST:  %s\n%s\n%s\n",
                run.name, sep, run.err)
    end
    return table.concat(res, "\n")
end

TestSuite = TestCase{ _init = {'filenames',},
    __call = function (...)
        o = (...)._clone(...)
        o.tests = {}
        o.filenames = o.filenames or {}
        if type(o.filenames) == string then
            o.filenames = {o.filenames}
        end
        for k, v in pairs(o.filenames) do
            local tmp_modname, tmp_testcases = discoverTestCases(v)
            if tmp_modname then
                for k, tstcase in pairs(tmp_testcases) do
                    o:add(package.loaded[tmp_modname][tstcase])
                end
            end
        end
        return o
        end, 
    }

function TestSuite:add(testobj)
    for t in getTestMethodNames(testobj) do
        self.tests[#self.tests + 1] = testobj{t}
    end
end

function TestSuite:run(result)
    for i, test in ipairs(self.tests) do
        test:run(result)
    end
end

function generateRandomModuleName()
    local r = math.random() -- random value to keep package namespace clean
    return 'auto_test_discovery_' .. tostring(r)
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function discoverTestCases(filename)
    local test_module_function = loadfile(filename)
    if not test_module_function then
        return nil
    end
    local tmp_mod_name = generateRandomModuleName() 
    test_module_function(tmp_mod_name)
    local results = {}
    if not package.loaded[tmp_mod_name] then return nil end -- not a module
    for k, v in pairs(package.loaded[tmp_mod_name]) do
        if type(k) == "string" and k:lower():find('test')
            and type(v) == "table" then
            results[ #results + 1 ] = k
        end
    end
    return tmp_mod_name, results
end

function findTestFiles()
    local results = {}
    local find_command_output = io.popen('find . -iname "test*.lua" -print')
    for filename in find_command_output:lines() do
        results[ #results + 1] = trim(filename)   
    end
    return results
end

