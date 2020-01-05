#!/usr/bin/env lua

-- run::shader_parser:=Parse & Generate shader files
-- run::shader_parser::-attrib::id:data
-- run::shader_parser::-attrib:=Vertex attribute data
-- run::shader_parser::-unif::id:data
-- run::shader_parser::-unif:=Vertex/fragment uniform data
-- run::shader_parser::-unifA::id:data
-- run::shader_parser::-unifA:=Vertex/fragment dynamic uniform data
-- run::shader_parser::-unifO::id:data
-- run::shader_parser::-unifO:=Vertex/fragment in/out uniform data

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"
local TypesGLSL = require "Scripts.TypesGLSL"
local inspect = require "Scripts.inspect"

local InputArgs = {
	attrib = "",
	unif   = "",
	unifA  = "",
	unifO  = "",
}

function GenAttributeStruct(data)
	out = "struct "..data.id.." {\n"
	for i, j in ipairs(data.cpp) do
		out = out.."\t"..j.."\n"
	end
	out = out.."};\n"

	print(out)
end

function GenAttributeShader(data)
	out = ""
	for i, j in ipairs(data.shader) do
		out = out..j.."\n"
	end

	print(out)
end

function ParseAttributes(data)
	if data:len() < 6 then --ex: 1,2,3
		return
	end

	local output = {id = "MeshVertex", shader = {}, cpp = {}}

	local id_begin, id_end = data:find("^[^:]+")
	if id_begin and id_end ~= data:len() then
		output.id = data:sub(id_begin, id_end - id_begin + 1)
		data = data:sub(id_end + 2)
	end

	if data:sub(1, 1) == ':' then data = data:sub(2) end

	print(string.format("Attributes\n Id = %s {remainder : %s}", output.id,
		data))

	local keep_parsing = true

	print(" Extracting vars...")
	repeat
		local var_begin, var_end = data:find("^[^;]+")
		keep_parsing = var_begin ~= nil

		if var_begin then
			local var = data:sub(var_begin, var_end - var_begin + 1)
			data = data:sub(var_end + 2)

			print(string.format("  - %s", var))

			c_var = var
			for i, j in pairs(TypesGLSL.types) do
				if (i:find("^mat") or i:find("vec")) and c_var:find("^"..i) then
					c_var = c_var:gsub("^"..i,
						TypesGLSL.types[i][TypesGLSL.ctype])

					c_var = c_var.."["..tostring(
						TypesGLSL.types[i][TypesGLSL.array_size]).."]"
					break
				elseif c_var:find("^"..i) then
					c_var = c_var:gsub("^"..i,
						TypesGLSL.types[i][TypesGLSL.ctype])
					break
				end
			end

			print(string.format("  -> %s", c_var))

			output.cpp[#output.cpp + 1] = "alignas(16) "..c_var..";"
			output.shader[#output.shader + 1] =
				"layout(location = "..tostring(#output.shader)..") in "..var..";"
		end
	until(keep_parsing == false)

	print(inspect(output))

	GenAttributeStruct(output)
	GenAttributeShader(output)
end

function Main(args)
	for param, param_data in pairs(InputArgs) do
		local idx = "-"..tostring(param)
		if args[idx] then
			InputArgs[param] = args[idx]
		end
	end

	ParseAttributes(InputArgs.attrib)
end

Main(UtilFuncs:ParseArgs())

