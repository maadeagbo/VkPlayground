#!/usr/bin/env lua

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"
local scripts = require "Scripts.RunGen"

local str_args = ""
if #arg > 1 then
	for k, v in pairs(arg) do
		if k > 1 then
			str_args = str_args.." "..v
		end
	end
end

function PrintInfo(search_term, extra_info)
	local DumpExtra = function(data)
		print(string.format("  source    : %s", data.source))
		if #data.vars > 0 then
			print(string.format("  arguments :"))
		end
		for m, n in ipairs(data.vars) do
			print(string.format("    %s <%s> : %s", n.id, n.vtype,
				n.info and n.info or "<no info>"))
		end
	end

	for i, j in pairs(scripts) do
		for k, l in pairs(j) do
			if search_term ~= "" then
				if k:match(search_term) then
					print(string.format("-%s : %s", k.."("..i..")", l.help))
					if extra_info then
						DumpExtra(l)
					end
				end
			else
				print(string.format("-%-20s : %.50s", k.."("..i..")", l.help))
			end	
		end
	end
end

if #arg >= 1 then
	if arg[1] == "-l" then
		PrintInfo( #arg > 1 and arg[2] or "", false)
	elseif arg[1] == "-h" and #arg == 2 then
		PrintInfo( arg[2], true)
	else
		for i, j in pairs(scripts) do
			if j and j[arg[1]] then
				if i == "lua" then
					os.execute(string.format("%s %s %s", ROOT_DIR.."/bin/lua",
						scripts.lua[arg[1]].source, str_args))
				elseif i == "bash" then
					os.execute(string.format("%s %s", scripts.bash[arg[1]].source,
						str_args))
				elseif i == "python" then
					os.execute(string.format("python %s %s",
						scripts.bash[arg[1]].source, str_args))
				end
			end
		end
	end
end

