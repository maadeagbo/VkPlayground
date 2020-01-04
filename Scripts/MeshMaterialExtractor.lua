#!/usr/bin/env lua

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"
local Json			= require "Scripts.JSON"
Json.strictTypes = true

local MmeArgs =
{
	h =
	{
		info = "Material extractor script. Consumes DDM files then extracts & ouptuts a material file"
	},
	i =
	{
		info = "Input mesh file name",
		val	 = ""
	},
	o =
	{
		info = "Output material file name",
		val  = ""
	},
}

function MeshMaterialExtractor()
	local new_args = UtilFuncs:ParseArgs()
	
	-- Lambda for dumping all set function args
	local DumpArgs = function( )
		for param, param_data in pairs( MmeArgs ) do
			print( string.format( " o %s : %s", param, param_data.val ) )
		end
	end

	for args, vals in pairs( new_args ) do
		-- print help info
		if args == "-h" or args == "--help" then
			print( MmeArgs.h.info )
			for param, param_data in pairs( MmeArgs ) do
				if param ~= "h" then print( string.format( "	- %s	%s", param, param_data.info ) ) end
			end
			return --help stops execution
		end
		
		-- set values
		for param, param_data in pairs( MmeArgs ) do
			if string.sub( args, 2, 2 ) == param then MmeArgs[param].val = vals end
		end
	end
	
	print( "o Running Mesh Material Extractor..." )

	-- search for input mesh file
	local search_file_name = UtilFuncs:ExtractNameFromPath( MmeArgs.i.val )
	local all_files = UtilFuncs:ListFilesInDir( MESH_DIR )
	local search_file_abs_path = ""

	for k = 1, #all_files do
		if string.find( all_files[k], search_file_name ) and string.find( all_files[k], ".ddm" ) then 
			print( string.format( " - Selecting mesh : %s", all_files[k] ) )

			search_file_abs_path = all_files[k]
			
			break -- stop at 1st match
		end
	end

	-- extract material data
	if search_file_abs_path == "" then
		return
	end

	local file = assert(io.open( search_file_abs_path ), "MeshMaterialExtractor :: Failed to open " .. search_file_abs_path )

	-- Lambda for extracting float arrays
	local GrabFloats = function ( str )
		local buff = {}

		for num in str:gmatch( "%S+" ) do
			buff[#buff + 1] = tonumber( num )
		end
		
		return buff
	end
	
	-- switch table to extract arguments
	local mat_switch = {
		["n "] = function ( x, idx, mats )
			mats[idx]["name"] = x:sub( 3 )
			print( "   o Found material : " .. mats[idx]["name"] )
		end,
		["d "] = function ( x, idx, mats ) mats[idx]["diffuse"] = GrabFloats( x:sub( 3 ) ) end,
		["s "] = function ( x, idx, mats ) mats[idx]["specular"] = GrabFloats( x:sub( 3 ) ) end,
		["D "] = function ( x, idx, mats ) mats[idx]["diffuse_tex"] = x:sub( 3 ) end,
		["N "] = function ( x, idx, mats ) mats[idx]["normal_tex"] = x:sub( 3 ) end,
		["S "] = function ( x, idx, mats ) mats[idx]["specular_tex"] = x:sub( 3 ) end,
		["R "] = function ( x, idx, mats ) mats[idx]["rough_tex"] = x:sub( 3 ) end,
		["M "] = function ( x, idx, mats ) mats[idx]["metal_tex"] = x:sub( 3 ) end,
		["E "] = function ( x, idx, mats ) mats[idx]["emit_tex"] = x:sub( 3 ) end,
		["A "] = function ( x, idx, mats ) mats[idx]["ao_tex"] = x:sub( 3 ) end,
	}

	local output_name = string.format( "%s%s%s", MATERIAL_DIR, OS_SLASH, "temp.ddr" )

	local material_output = {}

	local log_new_mat = false
	local curr_index = 0

	for line in file:lines() do
		-- extract material attributes
		if log_new_mat then
			local mat_attribute = line:sub( 1, 2 )
			if mat_switch[mat_attribute] then
				mat_switch[mat_attribute]( line, curr_index, material_output )
			end
		end

		-- activate/deactivate material attribute extraction
		if line:find( "<material" ) then
			log_new_mat = true
			curr_index = curr_index + 1
			material_output[curr_index] = {}
		end
		if line:find( "/material" ) then
			log_new_mat = false
		end
	end
	file:close()

	print( Json:encode_pretty( material_output ) )

	local out_file = assert(io.open( output_name, "w" ), "MeshMaterialExtractor :: Failed to open " .. output_name )
	out_file:write( Json:encode( material_output ) )
	out_file:close()
end

MeshMaterialExtractor()
