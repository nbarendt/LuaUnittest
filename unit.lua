#! /usr/bin/env lua
require "unittest"

local result = unittest.TestResult {}
local test_files = unittest.findTestFiles()
local suite = unittest.TestSuite{ unittest.findTestFiles() }
suite:run(result)
print(result:summary())
if not result:status() then
    print(unittest.FailureReporter{result}:report())
else
    print("OK")
end


