#!/usr/bin/env lua

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"
local Json		= require "Scripts.JSON"
Json.strictTypes = true
local HeaderDDS = require "Scripts.HeaderDDS"

local TexBldr = 
{
	json_input	   = "",
	json_output	   = "",
	texture_input  = "",
	texture_output = "",
}

-- run::texbuild:=Generates dxt compressed texture and exports to readable asset file
-- run::texbuild::-i::\"png\"
-- run::texbuild::-i:=Input texture (file/wildcard) to compress & export (default value: \"png\")
-- run::texbuild::-r::\"default\"
-- run::texbuild::-r:=Json/asset file (file/wildcard) to export texture info (default value: \"default\") 
-- run::texbuild::-s::2048
-- run::texbuild::-s:=Input texture size (default value: 2048) 

local TexBldrArgs =
{
	h =	 
	{ 
		info = "Texture builder script. Generates mip maps & converts texture into a useable format for engine consumption"
	},
	i = 
	{ 
		info = "Input texture name",
		val	 = "png"
	},
	o =	 
	{ 
		info = "Output texture name",
		val	 = ""
	},
	r =	 
	{ 
		info = "Input json",
		val	 = ""
	},
	d =	 
	{ 
		info = "json directory to search",
		val	 = ""
	}, 
	w =
	{ 
		info = "Output json",
		val	 = ""
	},
	s = 
	{
		info = "Texture size",
		val	 = 2048
	},
	t = 
	{
		info = "Restrict processing to the first matched file",
		val	 = "no"
	}
}

function TexBldr:Run()
	local new_args = UtilFuncs:ParseArgs()

	local DumpArgs = function( )
		for param, param_data in pairs( TexBldrArgs ) do
			print( string.format( " o %s : %s", param, param_data.val ) )
		end
	end
	
	for args, vals in pairs( new_args ) do
		
		-- print help info
		if args == "-h" or args == "--help" then
			print( "	" .. TexBldrArgs.h.info )
			for param, param_data in pairs( TexBldrArgs ) do
				if param ~= "h" then
          print( string.format( "		- %s	%s", param, param_data.info ) )
          print( string.format( "		        { initial val : %s }", tostring( param_data.val ) ) )
        end
			end
			return --help stops execution
		end
		
		-- set TexBldrArgs values
		for param, param_data in pairs( TexBldrArgs ) do
			if string.sub( args, 2, 2 ) == param then TexBldrArgs[param].val = vals end
		end
	end
	
	-- Lambda to extract name w/out full path and ext
	local ExtractName = function( path )
		if UtilFuncs:GetOS() == UtilFuncs.OS_WINDOWS then
			return path:match( "[^\\]+$" ):match( "[^%.]+" )
		else
			return path:match( "[^/]+$" ):match( "[^%.]+" )
		end
	end

	print( "o Running Texture Builder..." )
	
	-- set json search directory & file if not provided
	TexBldrArgs.d.val = TexBldrArgs.d.val == "" and ROOT_DIR	or TexBldrArgs.d.val
	TexBldrArgs.r.val = TexBldrArgs.r.val == "" and "default" or TexBldrArgs.r.val
	
	-- search for input json file
	these_files = UtilFuncs:ListFilesInDir( TexBldrArgs.d.val )
	for k = 1, #these_files do
		if string.find( these_files[k], TexBldrArgs.r.val ) and string.find( these_files[k], ".assets" ) then 
			print( string.format( "	 Selecting json    : %s", these_files[k] ) )
			TexBldrArgs.r.val = these_files[k]
			
			local output_term = ExtractName( TexBldrArgs.r.val )
			
			-- set output json file if not provided
			TexBldrArgs.w.val = TexBldrArgs.w.val == "" and output_term or TexBldrArgs.w.val
			
			break -- stop at 1st match
		end
	end

	tex_program = UtilFuncs:GetOS() == UtilFuncs.OS_WINDOWS and 
		ROOT_DIR .. "\\bin\\TextureMolder.exe" or 
		ROOT_DIR .. "/bin/TextureMolder"

	local input_json = Json:decode( UtilFuncs:DumpFileContents( TexBldrArgs.r.val ) )

	-- search for texture
	if TexBldrArgs.i.val ~= "" then
		local these_files = UtilFuncs:ListFilesInDir( TEX_DIR )
		local search_term = TexBldrArgs.i.val

		for k = 1, #these_files do
			if string.find( these_files[k], search_term ) then 
				print( string.format( "	 Selecting texture : %s", these_files[k] ) )
				TexBldrArgs.i.val = these_files[k]

				local output_term = ExtractName( TexBldrArgs.i.val )
				
				-- set output file if not provided
				TexBldrArgs.o.val = TexBldrArgs.o.val == "" and output_term or TexBldrArgs.o.val
		 
	
				local output_fmt = UtilFuncs:GetOS() == UtilFuncs.OS_WINDOWS and "\\" .. TexBldrArgs.o.val or 
																																	       "/"	.. TexBldrArgs.o.val

				if TexBldrArgs.o.val ~= "" then
					os.execute( "mkdir " .. TEX_DIR .. output_fmt .. "_data" )
				end
				
				-- use texture size to calculate # of mips
				--local tex_size = tonumber( TexBldrArgs.s.val )
				--local num_mips = tex_size and math.floor( math.log10( tex_size ) / math.log10( 2 ) ) or 1

				-- log texture specific data
				local tex_json_object = { { mips = 1, dimen_x = 0, dimen_y = 0 } }

				dds_file	= string.format( "%s%s_data%s.dds", TEX_DIR, output_fmt, output_fmt )
				
				-- generate compressed file ( may not be worth it to use -UseGPUDecompress or -performance )
				os.execute( string.format( "CompressonatorCLI -performance -UseGPUDecompress -fd BC7 -miplevels %d %s %s", 11, TexBldrArgs.i.val, dds_file ) )
					
				local dds_info = HeaderDDS:Parse( dds_file )
				
				tex_json_object[1].mips		 = dds_info.dwMipMapCount
				tex_json_object[1].dimen_x = dds_info.dwWidth
				tex_json_object[1].dimen_y = dds_info.dwHeight

        -- format string for engine consumption
        local texture_folder_idx = dds_file:find( "Textures" ) -- multi return function
        local extracted_location = dds_file:sub( texture_folder_idx )
        extracted_location:gsub( "\\\\", "/" )

				tex_json_object[1].dds = extracted_location
				
				local mip_w = dds_info.dwWidth
				local mip_h = dds_info.dwHeight
				for mip_lvl = 1, tex_json_object[1].mips do
					tex_json_object[#tex_json_object + 1] = HeaderDDS:CalcMipSizes( mip_w, mip_h )
					mip_w = mip_w / 2
					mip_h = mip_h / 2
				end

				-- output json data

				input_json.textures[TexBldrArgs.o.val] = tex_json_object
				
				TexBldrArgs.o.val = "" -- reset for next run

				if TexBldrArgs.t.val == "yes" then break end -- stop at 1st match
			end
		end
	end
	
	print( Json:encode_pretty( input_json ) ) 
	
	local output_json = assert( io.open( TexBldrArgs.r.val, "w" ), "Failed to open json : " .. TexBldrArgs.r.val )

	local updated_contents = Json:encode( input_json, nil, { indent = "	", array_newline = true, align_keys = true } )
	
	if updated_contents then 
		output_json:write( updated_contents ) 
	else
		output_json:write( Json:encode( input_json, nil, { indent = "	", array_newline = true, align_keys = true } ) )
	end		

end

TexBldr:Run()


