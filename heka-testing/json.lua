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
 
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function expand(json)
  for k, v in spairs(json) do
    if type(v) == "table" then
      for l, w in spairs(expand(v)) do
        json[k .. '.' .. l] = w
      end
      json[k] = nil
    end
  end
  return json
end
 
print(cjson.encode(expand(json)))
