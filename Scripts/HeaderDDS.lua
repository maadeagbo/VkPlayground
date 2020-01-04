-- Process a DDS image file and analyze the header contents

require "Scripts.lua_config"
local UtilFuncs = require "Scripts.UtilFuncs"

local HeaderDDS =
{
	dwMagicWord					= "",
	dwSize							= 0,
	dwFlags							= 0,
	dwHeight						= 0,
	dwWidth							= 0,
	dwPitchOrLinearSize = 0,
	dwDepth							= 0,
	dwMipMapCount				= 0,
	dwReserved1					= {},
	ddspf								= 
	{
		dwSize				= 0,
		dwFlags				= 0,
		dwFourCC			= 0,
		dwRBGBitCount = 0,
		dwRBitMask		= 0,
		dwGBitMask		= 0,
		dwBBitMask		= 0,
		dwABitMask		= 0
	},
	dwCaps							= 0,
	dwCaps2							= 0,
	dwCaps3							= 0,
	dwCaps4							= 0,
	dwReserved2					= 0,
	dx10Header					= 
	{
		dxgiFormat				= 0,
		resourceDimension = 0,
		miscFlag					= 0,
		arraySize					= 0,
		miscFlags2				= 0
	}
}

function HeaderDDS:CalcMipSizes( width, height )
	return math.max( 1, math.floor( ( width + 3 ) / 4 ) ) * math.max( 1, math.floor( ( height + 3 ) / 4 ) ) * 16
end

function HeaderDDS:Parse( dds_file )
	-- Convert byte data in binary file to HeaderDDS structure

	-- Read in the binary file
	local bin_image = assert( io.open( dds_file, "rb" ), "Failed to open binary file: " .. dds_file )

	-- Assuming this is BC7, extract the 1st 148 bytes
	local header_chunk = assert( bin_image:read( 148 ), "Failed to reader header in: " .. dds_file )

	local first_set = 
	{
		"dwSize",
		"dwFlags",
		"dwHeight",
		"dwWidth",
		"dwPitchOrLinearSize",
		"dwDepth",
		"dwMipMapCount",
	}

	self.dwMagicWord, next_pos = string.unpack( "c4", header_chunk )
	--print( "	Magic word : " .. self.dwMagicWord )

	for idx = 1, #first_set do
		HeaderDDS[first_set[idx]], next_pos = string.unpack( "=I4", header_chunk, next_pos )
		--print( "	" .. first_set[idx] .. " : " .. HeaderDDS[first_set[idx]] )
	end

	for idx = 1, 11 do
		self.dwReserved1[#self.dwReserved1 + 1], next_pos = string.unpack( "=I4", header_chunk, next_pos )
	end
	--print(	"	 " .. "dwReserved1 (unused 4byte chunks) : " .. #self.dwReserved1 )

	local pixel_set = 
	{
		"dwSize",
		"dwFlags",
		"dwFourCC",
		"dwRGBBitCount",
		"dwRBitMask",
		"dwGBitMask",
		"dwBBitMask",
		"dwABitMask",
	}

	for idx = 1, #pixel_set do
		if pixel_set[idx] == "dwFourCC" then
			self.ddspf[pixel_set[idx]], next_pos = string.unpack( "=c4", header_chunk, next_pos )
		else
			self.ddspf[pixel_set[idx]], next_pos = string.unpack( "=I4", header_chunk, next_pos )
		end
		--print( "	" .. pixel_set[idx] .. " : " .. self.ddspf[pixel_set[idx]] )
	end

	local second_set =
	{
		"dwCaps",
		"dwCaps2",
		"dwCaps3",
		"dwCaps4",
		"dwReserved2"
	}

	for idx = 1, #second_set do
		HeaderDDS[second_set[idx]], next_pos = string.unpack( "=I4", header_chunk, next_pos )
		--print( "	" .. second_set[idx] .. " : " .. HeaderDDS[second_set[idx]] )
	end

	local dx10_set =
	{
		"dxgiFormat",
		"resourceDimension",
		"miscFlag",
		"arraySize",
		"miscFlags2",
	}

	for idx = 1, #dx10_set do
		self.dx10Header[dx10_set[idx]], next_pos = string.unpack( "=I4", header_chunk, next_pos )
		--print( "	" .. dx10_set[idx] .. " : " .. self.dx10Header[dx10_set[idx]] )
	end

	-- Calculate the sizes of the texture
	--local mip_w = self.dwWidth
	--local mip_h = self.dwHeight
	--for mip_lvl = 1, self.dwMipMapCount do
	--	print( "	- Miplvl " .. ( mip_lvl - 1 ) .. " size : " .. self:CalcMipSizes( mip_w, mip_h ) ) 
	--	mip_w = mip_w / 2
	--	mip_h = mip_h / 2
	--end

	return self
end


return HeaderDDS
