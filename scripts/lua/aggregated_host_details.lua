--
-- (C) 2013 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
require "graph_utils"

page = _GET["page"]

ifname = _GET["interface"]
if(ifname == nil) then
   ifname = "any"
end

host_ip = _GET["host"]

active_page = "overview"

sendHTTPHeader('text/html')
ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")
dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

if(host_ip == nil) then
   print("<div class=\"alert alert-error\"><img src=/img/warning.png> Host parameter is missing (internal error ?)</div>")
   return
end

interface.find(ifname)
host = interface.getAggregatedHostInfo(host_ip)

if(host == nil) then
   print("<div class=\"alert alert-error\"><img src=/img/warning.png> Unable to find "..host_ip.." (data expired ?)</div>")
   return
else
print [[
<div class="bs-docs-example">
            <div class="navbar">
              <div class="navbar-inner">
<ul class="nav">
]]

url="/lua/host_details.lua?host="..host_ip

print("<li><a href=\"#\">Host: "..host_ip.." </a></li>\n")

if((page == "overview") or (page == nil)) then
  print("<li class=\"active\"><a href=\"#\">Overview</a></li>\n")
else
  print("<li><a href=\""..url.."&page=overview\">Overview</a></li>")
end

num = 0
--if(host.contacts ~= nil) then
--   for k,v in pairs(host["contacts"]["client"]) do num = num + 1 end
--   for k,v in pairs(host["contacts"]["server"]) do num = num + 1 end
--end

if(num > 0) then 
   if(page == "contacts") then
      print("<li class=\"active\"><a href=\"#\">Host Contacts</a></li>\n")
   else
      print("<li><a href=\""..url.."&page=contacts\">Host Contacts</a></li>")
   end
end


print [[
</ul>
</div>
</div>
</div>
   ]]

if((page == "overview") or (page == nil)) then
   print("<table class=\"table table-bordered\">\n")
   print("<tr><th>Name</th><td>" .. host["name"].. "</td></tr>\n")
   print("<tr><th>First Seen</th><td>" .. os.date("%x %X", host["seen.first"]) ..  " [" .. secondsToTime(os.time()-host["seen.first"]) .. " ago]" .. "</td></tr>\n")
   print("<tr><th>Last Seen</th><td><div id=last_seen>" .. os.date("%x %X", host["seen.last"]) .. " [" .. secondsToTime(os.time()-host["seen.last"]) .. " ago]" .. "</div></td></tr>\n")

   print("<tr><th>Contacts Received</th><td><div id=contacts>" .. formatValue(host["pkts.rcvd"]) .. "</id></td></tr>\n")
   print("</table>\n")

elseif(page == "contacts") then


if(num > 0) then
print("<table class=\"table table-bordered table-striped\">\n")
print("<tr><th>Client Contacts (Initiator)</th><th>Server Contacts (Receiver)</th></tr>\n")

print("<tr>")
print("<td><table class=\"table table-bordered table-striped\">\n")
print("<tr><th>Server Address</th><th>Contacts</th></tr>\n")

-- Client
sortTable = {}
for k,v in pairs(host["contacts"]["client"]) do sortTable[v]=k end

for _v,k in pairsByKeys(sortTable, rev) do 
   name = interface.getHostInfo(k)
   v = host["contacts"]["client"][k]
   if(name ~= nil) then
      url = "<A HREF=\"/lua/host_details.lua?interface="..ifname.."&host="..k.."\">"..name["name"].."</A>"
   else
      url = k
   end
   print("<tr><th>"..url.."</th><td class=\"text-right\">" .. formatValue(v) .. "</td></tr>\n")
end
print("</table></td>\n")

print("<td><table class=\"table table-bordered table-striped\">\n")
print("<tr><th>Client Address</th><th>Contacts</th></tr>\n")

-- Server
sortTable = {}
for k,v in pairs(host["contacts"]["server"]) do sortTable[v]=k end

for _v,k in pairsByKeys(sortTable, rev) do 
   name = interface.getHostInfo(k)   
   v = host["contacts"]["server"][k]
   if(name ~= nil) then
      url = "<A HREF=\"/lua/host_details.lua?interface="..ifname.."&host="..k.."\">"..name["name"].."</A>"
   else
      url = k
   end
   print("<tr><th>"..url.."</th><td class=\"text-right\">" .. formatValue(v) .. "</td></tr>\n")
end
print("</table></td></tr>\n")


print("</table>\n")
else
   print("No contacts for this host")
end


else
   print(page)
end
end

print [[
<script>
setInterval(function() {
		  $.ajax({
			    type: 'GET',
			    url: '/lua/get_aggregated_host_info.lua',
			    data: { if: "]] print(ifname) print [[", name: "]] print(host_ip) print [[" },
			    success: function(content) {
				var rsp = jQuery.parseJSON(content);

				$('#last_seen').html(bytesToVolume(rsp.bytes));
				$('#contacts').html(addCommas(rsp.packets)+" Pkts");
			     }
		           });
			 }, 3000);

		      ]]
dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")