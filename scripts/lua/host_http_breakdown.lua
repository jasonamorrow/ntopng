--
-- (C) 2014 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPHeader('text/html; charset=iso-8859-1')

interface.find(ifname)

host_info = url2hostinfo(_GET)
mode = _GET["mode"]

host = interface.getHostInfo(host_info["host"],host_info["vlan"])

left = 0

print "[\n"

--for k,v in pairs(host["dns"][what]) do
--   print(k.."="..v.."<br>\n")
--end

if(host ~= nil) then
   http = host.http
   if(mode == "queries") then
      if(http["query.total"] > 0) then
	 min = (http["query.total"] * 3)/100
	 comma = ""
	 
	 if(http["query.num_get"] > min) then 
	    print(comma..'\t { "label": "GET", "value": '.. http["query.num_get"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["query.num_get"]
	 end

	 if(http["query.num_post"] > min) then 
	    print(comma..'\t { "label": "POST", "value": '.. http["query.num_post"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["query.num_post"]
	 end

	 if(http["query.num_head"] > min) then 
	    print(comma..'\t { "label": "HEAD", "value": '.. http["query.num_head"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["query.num_head"]
	 end

	 if(http["query.num_put"] > min) then 
	    print(comma..'\t { "label": "PUT", "value": '.. http["query.num_put"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["query.num_put"]
	 end

	 if((http["query.num_other"]+left) > 0) then 
	    print(comma..'\t { "label": "Other", "value": '.. (http["query.num_other"]+left) .. '}\n')
	 end	 
      end
   else 
      -- responses

      if(http["response.total"] > 0) then
	 min = (http["response.total"] * 3)/100
	 comma = ""
	 
	 if(http["response.num_1xx"] > min) then 
	    print(comma..'\t { "label": "1xx", "value": '.. http["response.num_1xx"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["response.num_1xx"]
	 end

	 if(http["response.num_2xx"] > min) then 
	    print(comma..'\t { "label": "2xx", "value": '.. http["response.num_2xx"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["response.num_2xx"]
	 end

	 if(http["response.num_3xx"] > min) then 
	    print(comma..'\t { "label": "3xx", "value": '.. http["response.num_3xx"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["response.num_3xx"]
	 end

	 if(http["response.num_4xx"] > min) then 
	    print(comma..'\t { "label": "4xx", "value": '.. http["response.num_4xx"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["response.num_4xx"]
	 end

	 if(http["response.num_5xx"] > min) then 
	    print(comma..'\t { "label": "4xx", "value": '.. http["response.num_5xx"] .. '}\n')
	    comma = "," 
	 else 
	    left = left + http["response.num_5xx"]
	 end

	 if(left > 0) then 
	    print(comma..'\t { "label": "Other", "value": '.. left .. '}\n')
	 end	 
      end

   end
end

print "\n]"




