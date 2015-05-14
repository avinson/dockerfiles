local cjson = require "cjson"
 
-- opens a file in read
file = io.open("blob.json", "r")
 
-- sets the default input file as test.lua
io.input(file)
 
-- read the file
local s = io.read('*all')
 
-- closes the open file
io.close(file)
 
local json = cjson.decode(s)
 
function expand(json)
  for k, v in pairs(json) do
    if type(v) == "table" then
      for l, w in pairs(expand(v)) do
        json[k .. '.' .. l] = w
      end
      json[k] = nil
    end
  end
  return json
end
 
print(cjson.encode(expand(json)))
