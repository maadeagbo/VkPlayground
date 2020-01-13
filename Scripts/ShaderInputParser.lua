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
	attrib  = "",
	unif    = "",
	unifA   = "",
	unifO   = "",
	fragO   = "",
	fragDef = "",
}

function GenStructAttrib(data)
	local out = "alignas(16) struct "..data.id.."Sh {\n"
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

	return out
end

function SplitInput(input)
	local out = {}
	local keep_parsing = true

	repeat
		local var_begin, var_end = input:find("^[^,]+")
		keep_parsing = var_begin ~= nil

		if var_begin then
			local var = input:sub(var_begin, var_end - var_begin + 1)
			input = input:sub(var_end + 2)

			var = var:gsub("\n", "")
			var = var:gsub("\t", "")

			out[#out + 1] = var
		end
	until(keep_parsing == false)

	return out
end

function GenStructUnif(data, set_ndx, bind_ndx)
	local out = "alignas(16) struct "..data.id.."Sh {\n"
	for i, j in ipairs(data.cpp) do
		out = out.."\t"..j.."\n"
	end
	out = out.."};\n\n"

	out = out..string.format("#define SET_NDX_%s %d\n", data.id, set_ndx) 
	out = out..string.format("#define BIND_NDX_%s %d\n", data.id, bind_ndx) 
	
	return out
end

function GenStructTexture(data, set_ndx)
	local out = "namespace TextureLayout {\n"
	for i, j in ipairs(data.cpp) do
		local name = data.shader[i]:gsub("^.* ", "")

		out = out..string.format("\tconstexpr unsigned int %s_w = %d;\n",
			name, j[1]) 
		out = out..string.format("\tconstexpr unsigned int %s_h = %d;\n",
			name, j[2]) 
	end
	out = out.."};\n"

	for i, j in ipairs(data.shader) do
		local name = j:gsub("^.* ", "")

		out = out..string.format("#define SET_NDX_%s %d\n", name, set_ndx) 
		out = out..string.format("#define BIND_NDX_%s %d\n", name, data.bind[i]) 
		if data.shader[i]:find("^texture2D") then
			out = out..string.format("#define TEX2D_COUNT_%s %d\n", name,
				data.cpp[i][3]) 
		end
	end
	
	return out
end

function GenShader(data)
	local out = ""
	for i, j in ipairs(data.shader) do
		out = out..string.format("layout(location = %d) in %s\n", data.slot[i], j)
	end

	return out
end

function GenShaderUnif(data, name, set_ndx, bind_ndx)
	local out = string.format("layout(std140, set = %d, binding = %d) uniform %s {\n",
		set_ndx, bind_ndx, name) 
	for i, j in ipairs(data.shader) do
		out = out.."\t"..j.."\n"
	end
	out = out.."} "..data.id..";\n"

	return out
end

function GenShaderUnifO_In(data)
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

	return out
end

function GenShaderUnifO_Out(data)
	local out = ""
	for i, j in ipairs(data.shader) do
		local val = j
		val = val:gsub("^flat ", "")
		out = out..string.format("layout(location = %d) out %s\n", data.slot[i], val)
	end

	return out
end

function GenShaderTexture(data, set_ndx)
	local out = "" 
	for i, j in ipairs(data.shader) do
		if j:find("^sampler") then
			out = out..string.format(
				"layout(set = %d, binding = %d) uniform %s;\n",
				set_ndx, data.bind[i], j)
		else
			out = out..string.format(
				"layout(set = %d, binding = %d) uniform %s[%d];\n",
				set_ndx, data.bind[i], j, data.cpp[i][3])
		end
	end

	return out
end

function ExtractData(data)
	local output = {id = "", vals = {}}
	if data:len() < 6 then --ex: 1,2,3
		return output
	end

	local id_begin, id_end = data:find("^[^:]+")
	if id_begin and id_end ~= data:len() then
		output.id = data:sub(id_begin, id_end - id_begin + 1)
		output.id = output.id:gsub("\n", "")
		output.id = output.id:gsub("\t", "")
		output.id = output.id:gsub(" ", "")

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

			var = var:gsub("\n", "")
			var = var:gsub("\t", "")

			output.vals[#output.vals + 1] = var
		end
	until(keep_parsing == false)

	return output
end

function ParseAttributes(data)
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

	return output
end

function ParseUniforms(data)
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

				if val:find("%[.+%]") then
					local num_bgn, num_end = val:find("%[.+%]")
					local num = math.floor(tonumber(
						val:sub(num_bgn + 1, num_end - 1)))

					slot_offset = slot_offset + num
				end

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

	return output
end

function ParseTextures(samplers, images, set_ndx, bind_ndx)
	local output = {cpp = {}, shader = {}, bind = {}}

	local nxt_bind_ndx = bind_ndx

	local pdata = ExtractData(samplers)
	for i, j in ipairs(pdata.vals) do
		if(j:len() > 0) then
			local vdata = SplitInput(j)

			output.shader[#output.shader + 1] = string.format("sampler %s",
				vdata[1])

			output.cpp[#output.cpp + 1] = {
				tonumber(vdata[2]),
				tonumber(vdata[3]),}

			output.bind[#output.bind + 1] = nxt_bind_ndx
			nxt_bind_ndx = nxt_bind_ndx + 1
		end
	end

	pdata = ExtractData(images)
	for i, j in ipairs(pdata.vals) do
		if(j:len() > 0) then
			local vdata = SplitInput(j)

			-- Always a texture array
			if tonumber(vdata[4]) > 1 then
				output.shader[#output.shader + 1] = string.format("texture2D %s",
					vdata[1])

				output.cpp[#output.cpp + 1] = {
					tonumber(vdata[2]),
					tonumber(vdata[3]),
					tonumber(vdata[4]),}

				output.bind[#output.bind + 1] = nxt_bind_ndx
				nxt_bind_ndx = nxt_bind_ndx + vdata[4]
			end
		end
	end

	return output
end

function ParseDefines(data)
	local pdata = ExtractData(data)

	local out = ""
	for i, j in ipairs(pdata.vals) do
		out = out.."#define "..j.."\n"
	end

	return out
end

function Main(args)
	for param, param_data in pairs(InputArgs) do
		local idx = "-"..tostring(param)
		if args[idx] then
			InputArgs[param] = args[idx]
		end
	end

	local vertex_sh = "#version 450\n"
	local fragment_sh = "#version 450\n"
	local cpp_header = "#pragma once\n"

	-- defines
	local defs = ParseDefines(InputArgs.fragDef)

	-- vertex attributes
	local attrib_data = ParseAttributes(InputArgs.attrib)
	cpp_header = cpp_header.."\n"..GenStructAttrib(attrib_data)
	vertex_sh = vertex_sh.."\n"..GenShader(attrib_data)

	-- uniforms
	local unif_data = ParseUniforms(InputArgs.unif)
	cpp_header = cpp_header.."\n"..GenStructUnif(unif_data, 0, 0)
	vertex_sh = vertex_sh.."\n"..GenShaderUnif(unif_data, "UniformGenA", 0, 0)

	unif_data = ParseUniforms(InputArgs.unifA)
	cpp_header = cpp_header.."\n"..GenStructUnif(unif_data, 0, 1)
	vertex_sh = vertex_sh.."\n"..GenShaderUnif(unif_data, "UniformGenB", 0, 1)

	unif_data = ParseUniforms(InputArgs.fragO)
	fragment_sh = fragment_sh.."\n"..GenShaderUnifO_Out(unif_data)

	unif_data = ParseUniforms(InputArgs.unifO)
	fragment_sh = fragment_sh.."\n"..GenShaderUnifO_In(unif_data)
	vertex_sh = vertex_sh.."\n"..GenShaderUnifO_Out(unif_data)

	-- lights
	local light_data = ParseUniforms(DefaultFragData.light)
	cpp_header = cpp_header.."\n"..GenStructUnif(light_data, 0, 2)
	fragment_sh = fragment_sh.."\n"..GenShaderUnif(light_data, "UniformLight", 0, 2)

	-- samplers & images
	local image_data = ParseTextures(DefaultFragData.samplers, 
		DefaultFragData.images, 0, 3)
	cpp_header = cpp_header.."\n"..GenStructTexture(image_data, 0)
	fragment_sh = fragment_sh.."\n"..GenShaderTexture(image_data, 0)

	-- Shader code
	local vert_code = UtilFuncs:DumpFileContents(ROOT_DIR..
		"/src/Shaders/BasicMesh.vert")
	local frag_code = UtilFuncs:DumpFileContents(ROOT_DIR..
		"/src/Shaders/BasicMesh.frag")

	print("--------------------------------------------------------")
	local vert_dump = vertex_sh.."\n"..defs.."\n"..vert_code
	print("Vertex shader:\n\n"..vert_dump)

	print("--------------------------------------------------------")
	local frag_dump = fragment_sh.."\n"..defs.."\n"..frag_code
	print("Fragment shader:\n\n"..frag_dump)

	print("--------------------------------------------------------")
	print("C++ header:\n\n"..cpp_header.."\n"..defs.."\n")

	print("--------------------------------------------------------")

	UtilFuncs:DumpContentsToFile(ROOT_DIR.."/bin/generated.vert", vert_dump)
	UtilFuncs:DumpContentsToFile(ROOT_DIR.."/bin/generated.frag", frag_dump)
	UtilFuncs:DumpContentsToFile(ROOT_DIR.."/bin/GenShader.hpp", cpp_header..defs)
end

Main(UtilFuncs:ParseArgs())

