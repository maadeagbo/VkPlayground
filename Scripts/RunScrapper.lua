#!/usr/bin/env lua

-- run::rungen:=Update/compile all runnable scripts in Script directory

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"

local FileGlossary =
{
	python = "## run::",
	lua    = "-- run::",
	bash   = "## run::",
}

local ScriptGlossary =
{
	python = {},
	lua    = {},
	bash   = {},
}

function GetValueOrInfo(line)
	local mark_idx, mark_end = line:find("^(::)")
	if mark_idx then
		local val = line:sub(3)
		local var_idx, var_end = val:find("^[^:]+")

		return val:sub(var_idx, var_end - var_idx + 1), nil
	end

	mark_idx, mark_end = line:find("^(:=)")
	if mark_idx then
		return nil, line:sub(3)
	end

	return nil, nil
end

function ScrapeLine(line, tag)
	local data = nil

	local tag_idx, tag_end = line:find(tag)
	if tag_idx then
		local extract = line:sub(tag_end + 1)

		local name_idx, name_end = extract:find("^[a-zA-Z0-9_-]+")
		if name_idx then
			data = { name = extract:sub(name_idx, name_end - name_idx + 1) }
		else
			return nil
		end
		extract = extract:sub(name_end + 1)

		local ProcessLine = function(new_line)
			local val, info = GetValueOrInfo(new_line)
			
			if val then
				return { value = val }
			elseif info then
				return { help = info }
			else
				return nil
			end
		end

		local temp = ProcessLine(extract)
		if temp and temp.value then
			data.var = { id = temp.value }

			temp = ProcessLine(extract:sub(temp.value:len() + 3))
			if temp and temp.value then
				data.var.value = temp.value
			elseif temp and temp.help then
				data.var.info = temp.help
			end
		elseif temp and temp.help then
			data.help = temp.help
		end
	end

	return data
end

function AddScriptData(file, data, key)
	if ScriptGlossary[key][data.name] == nil then
		ScriptGlossary[key][data.name] = { help = "", source = file, vars = {} }
	end

  	for k, v in pairs(data) do
  		if type(v) == "table" then
			local v_idx = -1
			for i, var in ipairs(ScriptGlossary[key][data.name].vars) do
				if var.id == v.id then
					v_idx = i
				end
			end

			if v_idx == -1 then
				v_idx = #ScriptGlossary[key][data.name].vars + 1

				ScriptGlossary[key][data.name].vars[v_idx] = {}
				ScriptGlossary[key][data.name].vars[v_idx].id = v.id
				ScriptGlossary[key][data.name].vars[v_idx].vtype = ""
			end
  
  			if v.value then
				if tonumber(v.value) then
					ScriptGlossary[key][data.name].vars[v_idx].vtype =
						"number:"..tostring(v.value)
				else
					ScriptGlossary[key][data.name].vars[v_idx].vtype =
						"string:"..v.value
				end
  			end
  			if v.info then
  				ScriptGlossary[key][data.name].vars[v_idx].info = v.info
  			end
  		else
  			if v and k == "help" then
				ScriptGlossary[key][data.name].help = v
			end
  		end
  	end
end

function ScrapeFile(file, file_type_idx)
	local contents = UtilFuncs:DumpFileToArray(file)

	for i,j in pairs(contents) do
		if j ~= nil then 
			local data = ScrapeLine(j, FileGlossary[file_type_idx])

			if data then
				AddScriptData(file, data, file_type_idx)
			end
		end
	end
end

function ScrapeFileType(file_ext, file_gloss_key)
	local all_files = UtilFuncs:ListFilesInDir(ROOT_DIR.."/Scripts")
	for ifile = 1, #all_files do
		local ext = UtilFuncs:ExtractExtension(all_files[ifile])

		if ext == file_ext then
			--print(string.format("Scrapping : %s", all_files[ifile]))
			
			ScrapeFile(all_files[ifile], file_gloss_key)
		end
	end
end

function DumpContents(data)
	output = "  {\n"
	for i, j in pairs(data) do
		output = output.."    "..i.." = {\n"

		if type(j) == "table" then
			for k, l in pairs(j) do
				output = output.."      "..k.." = "
				if type(l) == "table" then
					output = output.."{\n"
					for m, n in pairs(l) do
						output = output.."        {\n"

						if type(n) == "table" then
							for o, p in pairs(n) do
								output = output.."          "..o.." = \""..p.."\""..",\n"
							end
						end
						output = output.."        },\n"
					end
					output = output.."      },\n"
				else
					output = output.."\""..l.."\""..",\n"
				end
			end
		end
		output = output.."    },\n"
	end
	output = output.."  },"

	return output
end

print("\nScrapping lua files...")
ScrapeFileType("lua", "lua")
print("\nScrapping bash files...")
ScrapeFileType("sh", "bash")
print("\nScrapping python files...")
ScrapeFileType("py", "python")

-- Generate file of array structure
print("\nExporting scripts info...")
local file_loc = ROOT_DIR.."/Scripts/RunGen.lua"
local file = assert(io.open(file_loc, "w"), "Failed to open " .. file_loc )

file:write("local scripts = {")
file:write("\n  lua = "..DumpContents(ScriptGlossary.lua))
file:write("\n  bash = "..DumpContents(ScriptGlossary.bash))
file:write("\n  python = "..DumpContents(ScriptGlossary.python))
file:write("\n}\nreturn scripts")

file:close()

