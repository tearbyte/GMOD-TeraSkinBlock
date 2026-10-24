
local ROOT = 'simple_skin_blacklist/'
local WORKSHOP_ID = '3006392625'
local WARNING_FILE = ROOT .. 'cl_teralib_warning.lua'
local ERROR_COLOR = Color( 255, 80, 80 )

-- Load order matters: sh_init defines the SSB table and the constants for the rest
local SHARED_FILES = { 'sh_init.lua', 'sh_lang.lua' }
local SERVER_FILES = { 'sv_access.lua', 'sv_data.lua', 'sv_check.lua', 'sv_net.lua' }
local CLIENT_FILES = { 'cl_menu.lua', 'cl_net.lua' }

if SERVER then

	-- On a listen server it would mount the Workshop copy over the local one of the host
	if game.IsDedicated() then resource.AddWorkshop( WORKSHOP_ID ) end
	AddCSLuaFile( WARNING_FILE )

	for _, name in ipairs( SHARED_FILES ) do
		AddCSLuaFile( ROOT .. name )
	end

	for _, name in ipairs( CLIENT_FILES ) do
		AddCSLuaFile( ROOT .. name )
	end

end

-- Shows its window only if TeraLib is missing
if CLIENT then include( WARNING_FILE ) end

-- TeraLib loads before every other autorun file, so if it's missing now, it's not installed
if not TeraLib then

	if SERVER then MsgC( ERROR_COLOR, '[Simple Skin Blacklist] TeraLib is not installed, the addon is disabled\n' ) end
	return

end

TeraLib.OnReady( 'loaded', 'SSB.Init', function()

	for _, name in ipairs( SHARED_FILES ) do
		include( ROOT .. name )
	end

	for _, name in ipairs( SERVER and SERVER_FILES or CLIENT_FILES ) do
		include( ROOT .. name )
	end

end )
