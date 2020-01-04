#!/usr/bin/env lua

-- run::build:=Compile projects. Multiple arguments (projects) can be supplied
-- run::build::reset:=Wipe build folder and reset cmake
-- run::build::vk_playground:=main vulkan app
-- run::build::release:=build the <project> name written before in release mode (i.e vk_playground release)

-- Add main directory to package path
require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"

local BldArgs = {}

local function Run()
	local new_args = UtilFuncs:ParseArgs()

	for args, val in pairs( new_args ) do
		-- print help info
		if args == "-h" or args == "--help" then
			print( "	Simple compilation script. Compiles provided project" )
			print( "		- reset(r)		Wipe build folder and reset cmake" )
			print( "		- all					Build all apps" )
			print( "		- vk_playground				Build vk_playground app" )
			print( "		- tests				Build engine tests" )
			print( "		- flatc				Build flatbuffers compiler" )
			return -- help stops execution
		end
		
		BldArgs[#BldArgs + 1] = val
	end

	-- Setup the environment for easier use
	
	local result = {}
	
	local build_dir = ""
	local lib_dir = ""
	--build_dir = string.format( ROOT_DIR .. "/build" ):gsub( "/", "\\" )

	if UtilFuncs:GetOS() == UtilFuncs.OS_OTHERS then
		build_dir = string.format( ROOT_DIR .. "/build" )
		lib_dir = string.format( ROOT_DIR .. "/lib" )
	else
		build_dir = string.format( ROOT_DIR .. "\\build" )
		lib_dir = string.format( ROOT_DIR .. "\\lib" )
	end
	
	for k = 1, #BldArgs do
		
		-- build/execute projects and/or commands
		if BldArgs[k] == "all" then
			
			-- build everything
			result = os.execute( string.format( "cmake --build %s/build --target vk_playground", ROOT_DIR ) )
			print( "\n--------------------------> Exit code : " .. tostring( result ) .. "\n" )

		elseif BldArgs[k] == "r" or BldArgs[k] == "reset" then
			
			local mode = BldArgs[k + 1] == "release" and "-DCMAKE_BUILD_TYPE=Release" or "-DCMAKE_BUILD_TYPE=Debug"
			
			-- wipe everything
			print( "\no Wiping build folders...\n" )
			if UtilFuncs:GetOS() == UtilFuncs.OS_WINDOWS then
				os.execute( "rd /s /q " .. build_dir )
				os.execute( "rd /s /q " .. lib_dir )
				os.execute( "mkdir " .. build_dir )

				os.execute( string.format( "cd " .. build_dir .. " && cmake .. -A x64" ) )
			else
				os.execute( "rm -rf " .. ROOT_DIR .. "/build/*" )
				os.execute( "rm -rf " .. ROOT_DIR .. "/lib/*" )

				os.execute( string.format( "cd " .. build_dir .. " && cmake .. " .. mode ) )
			end
			
		elseif BldArgs[k] == "server" then

			local mode = BldArgs[k + 1] == "release" and "--config release" or "--config debug"
			
			-- build build server app
			result = os.execute( string.format( "cmake --build %s/build --target server_program %s", ROOT_DIR, mode ) )
			print( "\n--------------------------> Exit code (server_app) : " .. tostring( result ) .. "\n" )
			
		elseif BldArgs[k] == "flatc" then

			local mode = BldArgs[k + 1] == "release" and "--config release" or "--config debug"
			
			-- build flatbuffer app
			result = os.execute( string.format( "cmake --build %s/build --target flatc %s", ROOT_DIR, mode ) )
			print( "\n--------------------------> Exit code (flatc) : " .. tostring( result ) .. "\n" )
			
		elseif BldArgs[k] == "vk_playground" then

			print( "Formatting code...\n" )
			result = os.execute( string.format( "%s/Scripts/format_code_style.sh", ROOT_DIR ) )
			
			-- build main vk_playground app

			local mode = BldArgs[k + 1] == "release" and "--config release" or "--config debug"

			result = os.execute( string.format( "cmake --build %s/build --target vk_playground %s", ROOT_DIR, mode ) )
			print( "\n--------------------------> Exit code (vk_playground app) : " .. tostring( result ) .. "\n" )

		elseif string.find( BldArgs[k], "test" ) then

			-- build test programs
			result = os.execute( string.format( "cmake --build %s/build --target heap_alloc_test", ROOT_DIR ) )
			print( "\n--------------------------> Exit code (heap_alloc_test) : " .. tostring( result ) .. "\n" )
			
			result = os.execute( string.format( "cmake --build %s/build --target physics_test", ROOT_DIR ) )
			print( "\n--------------------------> Exit code (physics_test) : " .. tostring( result ) .. "\n" )
			
			-- execute tests
			print( "\no Running all heap tests...\n" )
			os.execute( string.format( "%s/bin/heap_alloc_test 0", ROOT_DIR ) )
			
			print( "\no Running all physics tests...\n" )
			os.execute( string.format( "%s/bin/physics_test", ROOT_DIR ) )
		end
	end
end

Run()
