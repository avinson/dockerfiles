require "cjson"
-- https://github.com/mozilla-services/lua_sandbox/blob/dev/modules/date_time.lua
local dt = require "date_time"

--[[

Example usage:
[DockerJsonDecoder]
type = "SandboxDecoder"
script_type = "lua"
filename = "lua_decoders/docker_json.lua"

[DockerJsonDecoder.config]
Type = "docker_json_logs"
--]]

-- django/python sample input {"levelname": "DEBUG", "asctime": "2015-04-01 21:12:03,945", "name": "common.middleware", "process": 56, "thread": 140302122989312, "message": "[RM] NO redirect host=registry-hub.dev.docker.com, path=/", "service": "registry-hub", "version": "1.73.0", "environment": "development"}


--]]

local msg_type     = read_config("type")
local payload_keep = read_config("payload_keep")

-- related to https://www.ietf.org/rfc/rfc3164.txt
-- mapping for common languages like python and logrus
local severity_map = {
    DEBUG = 7,
    INFO = 6,
    NOTICE = 5, -- Not used by python or golang
    WARNING = 4,
    ERROR = 3,
    CRITICAL = 2,
    FATAL = 2, -- logrus - https://github.com/Sirupsen/logrus#level-logging
    ALERT = 1,
    PANIC = 1, -- logrus - https://github.com/Sirupsen/logrus#level-logging
    EMERGENCY = 0 -- Not used by python or golang
}

local python_date_pattern = '^(%d+-%d+-%d+) (%d+:%d+:%d+%,%d+)'

local message = {
    Timestamp  = nil,
    Host       = nil,
    Type       = msg_type,
    Payload    = nil,
    Fields     = nil,
    Severity   = nil
}

function parse_rfc3339_datetime(date)
    -- Parse RFC339 Dates based on https://github.com/mozilla-services/lua_sandbox/blob/dev/modules/date_time.lua
    -- RFC3339: "2006-01-02T15:04:05Z07:00"
    -- RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
    if type(date) ~= "string" then
        return nil
    end

    local t = dt.rfc3339:match(date)
    if not t then
        return nil
    end

    -- nanosecond is the only supported format as per https://hekad.readthedocs.org/en/latest/sandbox/index.html#heka-specific-functions-that-are-exposed-to-the-lua-sandbox
    -- https://github.com/mozilla-services/lua_sandbox/blob/dev/modules/date_time.lua#L14
    return dt.time_to_ns(t)
end

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

function process_message()
    raw_message = read_message("Payload")
    local container_id = read_message("Fields[ContainerID]")
    local container_name = read_message("Fields[ContainerName]")
    local ok, json = pcall(cjson.decode, raw_message)

    -- workaround for heka bug: https://github.com/mozilla-services/heka/issues/1504
    -- possibly related to docker logs input
    -- a mysterious character is sometimes added to the beginning. try deleting the first char and decode again
    if not ok then
        local m = string.sub(raw_message, 2)
        ok, json = pcall(cjson.decode,m)
    end

    if not ok then -- message is not in json, so we log for debugging
        message.Type = "Ignore"
        message.Payload = raw_message
    else
        message.Type = "Docker"
        -- python
        if json.levelname and severity_map[json.levelname] then
            message.Severity = severity_map[json.levelname]
        end
        -- logrus
        if json.level and severity_map[json.level] then
            message.Severity = severity_map[json.level]
        end

        -- flatten any nested json prior to insertion
        json = flatten(json)

        message.Fields = json
        message.Fields["container_id"] = container_id
        message.Fields["container_name"] = container_name

        -- transform the timestamp into a generic format so we can ship it
        -- using Timestamp as it's useful for logstash.
        -- We will need to come up with a way to match different formats.
        if json.asctime then
            local d, t = string.match(json.asctime, python_date_pattern)
            if d then
                message.Timestamp = string.format("%sT%sZ", d, t)
            end
        end

        -- format used by registry https://github.com/docker/distribution/pull/293
        if json.time then
            message.Timestamp = parse_rfc3339_datetime(json.time)
        end

        -- Remove original fields to avoid duplication
        --json["timestamp"] = nil
        json["level"] = nil
        --json["host"] = nil

        -- Preserve the original payload
        if payload_keep then
            message.Payload = raw_message
        end

        if message.Fields["service"] == "registry" and message.Fields["http.response.duration"] then
          -- for registry, convert the nanosecond timings to milisecond by grabbing everything up to the '.'
          -- clear duration for testing, need to parse into numerical "http.response.duration" type:string value:"5.525045ms"
          local s = message.Fields["http.response.duration"]
          local a,b=s:match"([^.]*).(.*)"
          message.Fields["http.response.duration"] = a
        end

        if not pcall(inject_message, message) then return -1 end
    end

    return 0
end
