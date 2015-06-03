local cjson = require "cjson"

-- opens a file in read
local file = io.open("blob.json", "r")

-- sets the default input file as test.lua
io.input(file)

-- read the file
local s = io.read('*a')

-- closes the open file
io.close(file)

local json = cjson.decode(s)

function flatten(tbl)
  local result = {}

  for k, v in pairs(tbl) do
      if type(v) == "table" then
          for subk, subv in pairs(flatten(v)) do
              result[k .. '.' .. subk] = subv
          end
      else
          result[k] = v
      end
  end

  return result
end

print(cjson.encode(flatten(json)))
