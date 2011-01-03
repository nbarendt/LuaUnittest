module( "unittest", package.seeall)

require "unittest.object"
require "os"
require "debug"
require "strict"


function isTestMethod (name, value)
    return 1 == name:find('test') and type(value) == "function" 
end


function getTestMethodNames (testobj)
    local results = {}
    for k, v in pairs(testobj) do
        if isTestMethod(k, v) then
            results[ #results + 1] = k
        end
    end
    return results 
end

function generateRandomModuleName()
    local r = math.random() -- random value to keep package namespace clean
    return 'auto_test_discovery_' .. tostring(r)
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function isTestCase (name, value)
    return type(name) == "string" and 1 == name:lower():find('test') 
            and type(value) == "table"
end

function loadTestModule(filename)
    local test_module_function = loadfile(filename)
    if not test_module_function then
        return nil
    end
    local tmp_mod_name = generateRandomModuleName() 
    test_module_function(tmp_mod_name)
    return tmp_mod_name
end 

function discoverTestCases(filename)
    local results = {}
    local tmp_mod_name = loadTestModule(filename)
    if not package.loaded[tmp_mod_name] then
        return nil -- not a module
    end
    for k, v in pairs(package.loaded[tmp_mod_name]) do
        if isTestCase(k, v) then
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

function tablesAreEqual(a, b)
  for k, v in pairs(a) do
    if v ~= b[k] then return false end
  end
  for k, v in pairs(b) do
   if v ~= a[k] then return false end
  end
  return true
end

TestCase = object.Object{
    _init={"test",},

    setUp = function (self)
    end,

    tearDown = function (self)
    end,

    assertEqual = function (self, expected, actual, msg)
        if type(expected) == 'table' then
          -- probably a more efficient way to do this
          --   also doesn't handle tables as values (nested)
          assert( true == tablesAreEqual(expected, actual), msg or
            string.format('Tables are Not Equal: Expected "%s" Actual "%s"',
              tostring(expected), tostring(actual)))
        else
          assert( expected == actual, msg or
                string.format('"%s" ~= "%s"', tostring(expected),
                    tostring(actual)))
        end
    end,

    assertNotNil = function (self, value, msg)
        assert(value ~= nil,
            msg or string.format("value %s of type %s is not nil",
                tostring(value), type(value)))
    end,

    assertStartsWith = function (self, prefix, actual, msg)
        self:assertEqual(prefix, actual:sub(1, prefix:len()), msg or 
            string.format('"%s" does not start with "%s"', actual, prefix))
    end,

    assertContains = function (self, pattern, actual, msg)
        assert(actual:find(pattern, 1, true), msg or
            string.format('"%s" not found in "%s"', pattern, actual))
    end,

    getTestName = function (self)
        if self.name then
            return self.name .. ":" .. self.test
        else
            return self.test
        end
    end,

    run = function (self, result)
        result:started(self:getTestName(), os.clock())
        self:setUp()
        local method = self[self.test]
        local err_reporter = function (err)
            return err .. "\n" .. debug.traceback()
        end
        local status, err = xpcall(function () method(self) end,
            err_reporter)
        self:tearDown()
        result:completed( os.clock(), err)
    end,
}

TestResult = object.Object{
    __call = function(...)
        o = (...)._clone(...)
        o.testruns = {}
        return o
    end,
       
    started = function (self, test_name, start_time)
        self.testruns[#self.testruns+1] = {
            name=test_name, 
            start_time=start_time}
    end,

    completed = function (self, end_time, err)
        self.testruns[#self.testruns].end_time = end_time
        self.testruns[#self.testruns].err = err
    end,

   getRunCount = function (self)
        return #self.testruns
    end,

    getFailureCount = function (self)
        local count = 0
        for _, testrun in ipairs(self.testruns) do
            if testrun.err then
                count = count + 1
            end
        end
        return count
    end,

    getElapsedTime = function (self)
        local start_time = 0
        local end_time = 0
        if self:getRunCount() > 0 then
            start_time = self.testruns[1].start_time
            end_time = self.testruns[#self.testruns].end_time
        end
        return end_time - start_time
    end,

    summary = function (self)
        local res = string.format("Ran %d tests in %s seconds",
            self:getRunCount(), self:getElapsedTime())
        local failures = self:getFailureCount()
        if failures > 0 then
            res = res .. " " .. string.format("FAILED (failed=%d)", failures) 
        end
        return res
    end,

    status = function (self)
        return 0 == self:getFailureCount()
    end,

    getResults = function (self)
        local iterator = function ()
            for _, v in ipairs(self.testruns) do
                coroutine.yield(v)
            end
        end
        return coroutine.wrap(iterator), nil, nil
    end,

    getFailures = function (self)
        local iterator = function ()
            for _, v in ipairs(self.testruns) do
                if v.err then coroutine.yield(v) end
            end
        end
        return coroutine.wrap(iterator), nil, nil
    end,
}

function formatFailure(testName, sep, err)
    return string.format("FAILED %s\n%s\n%s\n", testName, sep, err)
end
 
FailureReporter = object.Object{
    _init={"testResults"},

    report = function (self)
        local sep = string.rep("-", 80)
        local res = {"Failures:", sep}
        for run in self.testResults:getFailures() do
            res[ #res + 1] = formatFailure(run.name, sep, run.err) 
        end
        return table.concat(res, "\n")
    end,
}

TestSuite = TestCase{
    _init = {'filenames',},

    __call = function (...)
        o = (...)._clone(...)
        o.tests = {}
        o.filenames = o.filenames or {}

        for _, v in ipairs(o.filenames) do
            local tmp_modname, tmp_testcases = discoverTestCases(v)
            if tmp_modname then
                for _, test_case_name in ipairs(tmp_testcases) do
                    local test_case = package.loaded[tmp_modname][test_case_name] 
                    test_case.name = test_case_name
                    o:add(test_case)
                end
            end
        end
        return o
    end, 

    add = function (self, testobj)
        for _, t in ipairs(getTestMethodNames(testobj)) do
            self.tests[#self.tests + 1] = testobj{t}
        end
    end,

    run = function (self, result)
        for _, test in ipairs(self.tests) do
            test:run(result)
        end
    end,
}

