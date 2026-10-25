
local ROOT = 'simple_skin_blacklist/'
local WORKSHOP_ID = '3006392625'
local WARNING_FILE = ROOT .. 'client/teralib_warning.lua'
local ERROR_COLOR = Color( 255, 80, 80 )

-- Load order matters: init defines the SSB table and the constants for the rest
local SHARED_FILES = { 'init.lua', 'lang.lua' }
local SERVER_FILES = { 'server/access.lua', 'server/data.lua', 'server/check.lua', 'server/net.lua' }
local CLIENT_FILES = { 'client/api.lua', 'client/menu.lua', 'client/net.lua', 'client/wiki/en.lua', 'client/wiki/ru.lua', 'client/wiki/uk.lua', 'client/wiki.lua' }

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
