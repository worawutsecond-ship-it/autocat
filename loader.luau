-- AUTOCAT public entry point. Access is checked by the license service.
local CONFIG_URL="https://raw.githubusercontent.com/worawutsecond-ship-it/autocat/main/config.json"
local function fail(message)
    warn("AUTOCAT: "..message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="AUTOCAT",Text=message,Duration=10})
    end)
end
local ok,config=pcall(function()
    return game:GetService("HttpService"):JSONDecode(game:HttpGet(CONFIG_URL.."?t="..tostring(os.time())))
end)
if not ok or type(config)~="table" then fail("Cannot load service settings. Please retry.") return end
local base=config.licenseServer
if type(base)~="string" or not base:match("^https://[^/%s?#@]+$") then
    fail("The license server is not configured. Contact the administrator.") return
end
local lowerBase=base:lower()
local host=lowerBase:match("^https://([^:]+)")
if host=="localhost" or (host and host:match("^127%.")) or lowerBase:match("^https://%[::1%]") then
    fail("The license server needs a public address. Contact the administrator.") return
end
local downloaded,source=pcall(function() return game:HttpGet(base.."/v1/loader") end)
if not downloaded or type(source)~="string" or #source<100 then
    fail("The license server is unavailable. Please retry later.") return
end
local compileOk,run=pcall(loadstring,source)
if not compileOk or type(run)~="function" then fail("The loader could not start. Contact the administrator.") return end
local started=pcall(run)
if not started then fail("The loader stopped unexpectedly. Contact the administrator.") end
