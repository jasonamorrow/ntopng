--
-- (C) 2013 - ntop.org
--

dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
require "lua_utils"

sendHTTPHeader('text/html; charset=iso-8859-1')

ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")

active_page = "admin"

dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")
dofile(dirs.installdir .. "/scripts/lua/inc/personal_password_dialog.lua")

dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")
