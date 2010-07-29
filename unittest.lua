#! /usr/bin/env lua
require "testcase"

local result = testcase.TestResult {}
local test_files = testcase.findTestFiles()
local suite = testcase.TestSuite{ testcase.findTestFiles() }
suite:run(result)
print(result:summary())
if not result:status() then
    print(testcase.FailureReporter{result}:report())
else
    print("OK")
end


