--
-- (C) 2013 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPHeader('text/html')
ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")

active_page = "flows"
dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

application = _GET["application"]
hosts = _GET["hosts"]
aggregation = _GET["aggregation"]
key = _GET["key"]

prefs = ntop.getPrefs()
ifstats = interface.getStats()

stats = interface.getNdpiStats()
num_param = 0
print [[
      <hr>
      <div id="table-flows"></div>
	 <script>
   var url_update = "/lua/get_flows_data.lua]]

   if(application ~= nil) then
   print("?application="..application)
   num_param = num_param + 1
end

if(hosts ~= nil) then
  if (num_param > 0) then
    print("&")
  else
    print("?")
  end
  print("hosts="..hosts)
  num_param = num_param + 1
end

if(aggregation ~= nil) then
  if (num_param > 0) then
    print("&")
  else
    print("?")
  end
  print("aggregation="..aggregation)
  num_param = num_param + 1
end

if(key ~= nil) then
  if (num_param > 0) then
    print("&")
  else
    print("?")
  end
  print("key="..key)
  num_param = num_param + 1
end

print ('";')

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/flows_stats_id.inc") 
-- Set the flow table option
if(prefs.is_categorization_enabled) then print ('flow_rows_option["categorization"] = true;\n') end
if(ifstats.iface_vlan) then print ('flow_rows_option["vlan"] = true;\n') end
   print [[

	 var table = $("#table-flows").datatable({
			url: url_update , ]]
print ('rowCallback: function ( row ) { return flow_table_setID(row); },')
print [[ 
         showFilter: true,
	       showPagination: true,
	       buttons: [ '<div class="btn-group"><button class="btn btn-link dropdown-toggle" data-toggle="dropdown">Applications<span class="caret"></span></button> <ul class="dropdown-menu" role="menu" id="flow_dropdown">]]

print('<li><a href="/lua/flows_stats.lua">All Proto</a></li>')
for key, value in pairsByKeys(stats["ndpi"], asc) do
   class_active = ''
   if(key == application) then
      class_active = ' class="active"'
   end
   print('<li '..class_active..'><a href="/lua/flows_stats.lua?application=' .. key..'">'..key..'</a></li>')
end


print("</ul> </div>' ],\n")


ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/flows_stats_top.inc")

if(ifstats.iface_vlan) then
print [[
           {
           title: "VLAN",
         field: "column_vlan",
         sortable: true,
                 css: { 
              textAlign: 'center'
           }
         },
]]
end


ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/flows_stats_middle.inc")



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

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/flows_stats_bottom.inc")
dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")
