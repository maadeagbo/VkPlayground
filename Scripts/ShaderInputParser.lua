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
local inspect   = require "Scripts.inspect"

local TypesGLSL = require "Scripts.TypesGLSL"
local DefaultFragData = require "Scripts.DefaultFragData"

local InputArgs = {
	attrib = "",
	unif   = "",
	unifA  = "",
	unifO  = "",
}

function GenStructAttrib(data)
	print("\n********************* Cpp(Attrib) *********************\n")

	local out = "alignas(16) struct "..data.id.." {\n"
	for i, j in ipairs(data.cpp) do
		out = out.."\t"..j.."\n"
	end
	out = out.."};\n\n"

	out = out.."namespace "..data.id.."Layout {\n"
	for i, j in ipairs(data.cpp) do
		local name = j:gsub("^[^ ]+", "")
		name = name:gsub("%[.*$", "")
		name = name:gsub(";$", "")

		out = out..string.format("\tconstexpr unsigned int %s = %d;\n",
			name:sub(2), data.slot[i]) 
	end
	out = out.."};\n"

	print(out)
end

function GenStructUnif(data, set_ndx, bind_ndx)
	print("\n********************* Cpp(Unif) *********************\n")
	local out = "alignas(16) struct "..data.id.." {\n"
	for i, j in ipairs(data.cpp) do
		out = out.."\t"..j.."\n"
	end
	out = out.."};\n\n"

	out = out..string.format("#define SET_NDX_%s %d\n", data.id, set_ndx) 
	out = out..string.format("#define BIND_NDX_%s %d\n", data.id, bind_ndx) 

	print(out)
end

function GenShader(data)
	print("\n********************* Shader *********************\n")
	
	local out = "layout(std140, location = 0) in struct GeneratedVertex {\n"
	for i, j in ipairs(data.shader) do
		out = out.."\t"..j.."\n"
	end
	out = out.."} "..data.id..";\n"

	print(out)
end

function GenShaderUnif(data, name, set_ndx, bind_ndx)
	print("\n********************* Shader(Unif) *********************\n")
	
	local out = string.format("layout(std140, set = %d, binding = %d) uniform %s {\n",
		set_ndx, bind_ndx, name) 
	for i, j in ipairs(data.shader) do
		out = out.."\t"..j.."\n"
	end
	out = out.."} "..data.id..";\n"

	print(out)
end

function GenShaderUnifO_In(data)
	print("\n********************* Shader(UnifO In) *********************\n")
	
	local out = ""
	for i, j in ipairs(data.shader) do
		local val = j
		if j:find("^flat") then
			val = val:gsub("^flat ", "flat in ")
		else
			val = "in "..val
		end
		out = out..string.format("layout(location = %d) %s\n", data.slot[i], val)
	end

	print(out)
end

function GenShaderUnifO_Out(data)
	print("\n********************* Shader(UnifO Out) *********************\n")
	
	local out = ""
	for i, j in ipairs(data.shader) do
		local val = j
		val = val:gsub("^flat ", "")
		out = out..string.format("layout(location = %d) out %s\n", data.slot[i], val)
	end

	print(out)
end

function ExtractData(data)
	local output = {id = "", vals = {}}
	if data:len() < 6 then --ex: 1,2,3
		return output
	end

	local id_begin, id_end = data:find("^[^:]+")
	if id_begin and id_end ~= data:len() then
		output.id = data:sub(id_begin, id_end - id_begin + 1)
		data = data:sub(id_end + 2)
	end

	if data:sub(1, 1) == ':' then data = data:sub(2) end

	local keep_parsing = true

	repeat
		local var_begin, var_end = data:find("^[^;]+")
		keep_parsing = var_begin ~= nil

		if var_begin then
			local var = data:sub(var_begin, var_end - var_begin + 1)
			data = data:sub(var_end + 2)

			output.vals[#output.vals + 1] = var
		end
	until(keep_parsing == false)

	return output
end

function ParseAttributes(data)
	print("--------------------------------------------------------")
	print("Parsing attributes...")

	local output = {id = "MeshVertex", shader = {}, cpp = {}, slot = {}}
	local pdata = ExtractData(data)

	output.id = pdata.id:len() > 0 and pdata.id or output.id
	slot = 0

	for idx, val in ipairs(pdata.vals) do
		if val:find("^mat") == nil then
			local c_val = ""
			local slot_offset = 0
			for i, j in pairs(TypesGLSL.types) do
				if val:find("^"..i) then
					c_val = val:gsub("^"..i, j[TypesGLSL.ctype])
					slot_offset = j[TypesGLSL.unif_slots]

					if j[TypesGLSL.array_size] > 0 then
						c_val = c_val.."["..tostring(j[TypesGLSL.array_size]).."]"
					end
					break
				end
			end

			if c_val:len() > 0 then
				output.cpp[#output.cpp + 1] = c_val..";"
				output.shader[#output.shader + 1] = val..";"
				output.slot[#output.slot + 1] = slot

				slot = slot + slot_offset
			end
		end
	end

	print(inspect(output))

	GenStructAttrib(output)
	GenShader(output)
end

function ParseUniforms(data)
	print("--------------------------------------------------------")
	print("Parsing uniforms...")

	local output = {id = "UniformData1", shader = {}, cpp = {}, slot = {}}
	local pdata = ExtractData(data)

	output.id = pdata.id:len() > 0 and pdata.id or output.id
	slot = 0

	for idx, val in ipairs(pdata.vals) do
		local c_val = ""
		local slot_offset = 0
		for i, j in pairs(TypesGLSL.types) do
			if val:find("^"..i) or val:find("^flat "..i) then
				c_val = val:gsub("^"..i, j[TypesGLSL.ctype])
				slot_offset = j[TypesGLSL.unif_slots]

				if j[TypesGLSL.array_size] > 0 then
					c_val = c_val.."["..tostring(j[TypesGLSL.array_size]).."]"
				end
				break
			end
		end

		if c_val:len() > 0 then
			output.cpp[#output.cpp + 1] = c_val..";"
			output.shader[#output.shader + 1] = val..";"
			output.slot[#output.slot + 1] = slot

			slot = slot + slot_offset
		end
	end

	print(inspect(output))

	return output
end

function Main(args)
	for param, param_data in pairs(InputArgs) do
		local idx = "-"..tostring(param)
		if args[idx] then
			InputArgs[param] = args[idx]
		end
	end

	-- vertex attributes
	ParseAttributes(InputArgs.attrib)

	-- uniforms
	local unif_data = ParseUniforms(InputArgs.unif)
	GenStructUnif(unif_data, 0, 0)
	GenShaderUnif(unif_data, "UniformGenA", 0, 0)

	unif_data = ParseUniforms(InputArgs.unifA)
	GenStructUnif(unif_data, 0, 1)
	GenShaderUnif(unif_data, "UniformGenB", 0, 1)

	unif_data = ParseUniforms(InputArgs.unifO)
	GenShaderUnifO_In(unif_data)
	GenShaderUnifO_Out(unif_data)

	-- lights
	light_data = ParseUniforms(DefaultFragData.light)
	GenStructUnif(light_data, 0, 2)
	GenShaderUnif(light_data, "UniformLight", 0, 2)

	-- samplers
	sampler_data = ""

	-- images
	image_data = ""
end

Main(UtilFuncs:ParseArgs())

