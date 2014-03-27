--
-- (C) 2013 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPHeader('text/html')

mode = _GET["mode"]
type = _GET["type"]
host = _GET["host"]

interface.find(ifname)
local debug = false

if(host == nil) then
  print("<div class=\"alert alert-error\"><img src=/img/warning.png> This flow cannot be found (expired ?)</div>")
else

  flows_stats = interface.getFlowsInfo()

  how_is_process = 0

  if((type == nil) or (type == "memory")) then
    how = "actual_memory"
    how_is_process = 1
  elseif (type == "bytes") then
    how = "bytes"
  end

  if((mode == nil) or (mode == "user")) then
    what = "user_name"
    url = "/lua/get_user_info.lua?user="
  elseif (mode == "process") then
    what = "name"
    url = "/lua/get_process_info.lua?name="
  end

  tot = 0
  what_array = {}
  num = 0
  for key, value in pairs(flows_stats) do
    client_process = 0
    server_process = 0
    flow = flows_stats[key]
    if (debug) then io.write("Client:"..flow["cli.ip"]..",Server:"..flow["srv.ip"].."\n"); end
    if((flow["cli.ip"] == host) and (flow.client_process ~= nil))then
      client_process = 1
    end

    if((flow["srv.ip"] == host) and (flow.server_process ~= nil))then
      server_process = 1
    end

    
    if(client_process == 1) then
      current_what = flow["client_process"][what].." (client processes)"
      if (how_is_process == 1) then
        value = flow["client_process"][how] 
      else
        value = flow["cli2srv.bytes"]
      end
      
      if (what_array[current_what] == nil) then 
        what_array[current_what]  = {}
        what_array[current_what]["value"]  = 0
        what_array[current_what]["url"]  = url..flow["client_process"][what].."&host="..flow["cli.ip"]
      end
      what_array[current_what]["value"] = what_array[current_what]["value"] + value

      if (debug) then io.write("Find client_process:"..current_what..", Value:"..value..", Process:"..flow["client_process"]["name"].."\n"); end

    end
    
    if(server_process == 1) then
      current_what = flow["server_process"][what].." (server processes)"
      if (how_is_process == 1) then
       value = flow["server_process"][how] 
      else
         value = flow["srv2cli.bytes"]
      end
      
      if (what_array[current_what] == nil) then 
        what_array[current_what]  = {}
        what_array[current_what]["value"]  = 0
        what_array[current_what]["url"]  = url..flow["server_process"][what].."&host="..flow["srv.ip"]
      end
      what_array[current_what]["value"] = what_array[current_what]["value"] + value
      tot = tot + value
      if (debug) then io.write("Find server_process:"..current_what..", Value:"..value..", Process:"..flow["server_process"]["name"].."\n"); end

    end
    
  end

  print "[\n"
  num = 0
  s = 0
  for key, value in pairs(what_array) do

    if(num > 0) then
      print ",\n"
    end
    value = what_array[key]["value"]
    label = key
    url = what_array[current_what]["url"]
    print("\t { \"label\": \"" .. label .."\", \"value\": ".. value ..", \"url\": \"" .. url.."\" }") 
    num = num + 1
    s = s + value

  end

  if(tot > s) then
    print(",\t { \"label\": \"Other\", \"value\": ".. (tot-s) .." }") 
  end

  print "\n]"

end