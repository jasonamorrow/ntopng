--
-- (C) 2013-14 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPHeader('text/html; charset=iso-8859-1')

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")

protocol = _GET["protocol"]
net      = _GET["net"]
asn      = _GET["asn"]
vlan     = _GET["vlan"]
network  = _GET["network"]
country  = _GET["country"]

mode = _GET["mode"]
if(mode == nil) then mode = "all" end

active_page = "hosts"
dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

prefs = ntop.getPrefs()
if(prefs.is_categorization_enabled) then print ()end

ifstats = interface.getStats()

print [[
      <hr>
      <div id="table-hosts"></div>
	 <script>
	 var url_update = "]]
print (ntop.getHttpPrefix())
print [[/lua/get_hosts_data.lua?mode=]]
print(mode)

if(protocol ~= nil) then
   print('&protocol='..protocol)
end

if(net ~= nil) then
   print('&net='..net)
end

if(asn ~= nil) then
   print('&asn='..asn)
end

if(vlan ~= nil) then
   print('&vlan='..vlan)
end

if(country ~= nil) then
   print('&country='..country)
end


if(network ~= nil) then
   print('&network='..network)
end

print ('";')

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/hosts_stats_id.inc")

if ((ifstats.iface_vlan)) then show_vlan = true else show_vlan = false end

-- Set the host table option
if(prefs.is_categorization_enabled) then print ('host_rows_option["categorization"] = true;\n') end
if(prefs.is_httpbl_enabled) then print ('host_rows_option["httpbl"] = true;\n') end
if(show_vlan) then print ('host_rows_option["vlan"] = true;\n') end
if(is_historical) then print ('clearInterval(host_table_interval);\n') end

print [[
	 host_rows_option["ip"] = true;
	 $("#table-hosts").datatable({
	 		title: "Hosts List",
			url: url_update ,
	 ]]

if(protocol == nil) then protocol = "" end

if(_GET["asn"] ~= nil) then asn = " for AS ".._GET["asn"] else asn = "" end
if(_GET["country"] ~= nil) then country = " for Country ".._GET["country"] else country = "" end

if(mode == "all") then
   print('title: "All '..protocol..' Hosts'..country..'",\n')
elseif(mode == "local") then
   print('title: "Local '..protocol..' Hosts'..country..'",\n')
elseif(mode == "remote") then
   print('title: "Remote '..protocol..' Hosts'..country..'",\n')
else
   print('title: "Local Networks'..country..'",\n')
end
print ('rowCallback: function ( row ) { return host_table_setID(row); },')

-- Set the preference table
preference = tablePreferences("rows_number",_GET["perPage"])
if (preference ~= "") then print ('perPage: '..preference.. ",\n") end

-- Automatic default sorted. NB: the column must exist.
print ('sort: [ ["' .. getDefaultTableSort("hosts") ..'","' .. getDefaultTableSortOrder("hosts").. '"] ],')


print [[
	       showPagination: true,
	       buttons: [ '<div class="btn-group"><button class="btn btn-link dropdown-toggle" data-toggle="dropdown">Filter Hosts<span class="caret"></span></button> <ul class="dropdown-menu" role="menu" style="min-width: 90px;"><li><a href="]]
print (ntop.getHttpPrefix())
print [[/lua/hosts_stats.lua">All Hosts</a></li><li><a href="]]
print (ntop.getHttpPrefix())
print [[/lua/hosts_stats.lua?mode=local">Local Only</a></li><li><a href="]]
print (ntop.getHttpPrefix())
print [[/lua/hosts_stats.lua?mode=remote">Remote Only</a></li><li>&nbsp;</li><li><a href="]]
print (ntop.getHttpPrefix())
print [[/lua/hosts_stats.lua?mode=network">Local Networks</a></li></ul>]]
print [[</div>' ],
	        columns: [
	        	{
	        		title: "Key",
         			field: "key",
         			hidden: true,
         			css: {
              textAlign: 'center'
           }
         		},
         		{
			     title: "IP Address",
				 field: "column_ip",
				 sortable: true,
	 	             css: {
			        textAlign: 'left'
			     }
				 },
			  ]]

if(show_vlan) then
if(ifstats.iface_sprobe) then
   print('{ title: "Source Id",\n')
else
   if(ifstats.iface_vlan) then
     print('{ title: "VLAN",\n')
   end
end


print [[
				 field: "column_vlan",
				 sortable: true,
	 	             css: {
			        textAlign: 'center'
			     }

				 },
]]
end

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/hosts_stats_top.inc")



if(prefs.is_categorization_enabled) then
print [[
			     {
			     title: "Category",
				 field: "column_category",
				 sortable: true,
	 	             css: {
			        textAlign: 'center'
			       }
			       },
		       ]]
end

if(prefs.is_httpbl_enabled) then
print [[
			     {
			     title: "HTTP:BL",
				 field: "column_httpbl",
				 sortable: true,
	 	             css: {
			        textAlign: 'center'
			       }
			       },
		       ]]
end


ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/hosts_stats_bottom.inc")
dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")
