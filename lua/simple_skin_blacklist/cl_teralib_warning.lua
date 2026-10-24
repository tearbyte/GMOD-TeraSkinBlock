
-- Works without TeraLib, so only stock Derma and resource/localization are used here

local WARNING_DELAY = 10
local WINDOW_WIDTH = 500
local WINDOW_HEIGHT = 170
local TEXT_PADDING = 5
local TEXT_ALIGNMENT = 7 -- Top left, numpad layout
local BUTTON_WIDTH = 120
local BUTTON_HEIGHT = 25
local TERALIB_URL = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464'

local function showWarning()

	-- Checked when the timer fires: all autorun files are loaded for sure
	if TeraLib then return end

	local frame = vgui.Create( 'DFrame' )
	frame:SetSize( WINDOW_WIDTH, WINDOW_HEIGHT )
	frame:SetTitle( '#simple_skin_blacklist.teralib_missing.title' )
	frame:Center()
	frame:MakePopup()

	local button = vgui.Create( 'DButton', frame )
	button:Dock( BOTTOM )
	button:SetTall( BUTTON_HEIGHT )
	-- Centered: equal side margins
	local sideMargin = ( WINDOW_WIDTH - BUTTON_WIDTH ) / 2
	button:DockMargin( sideMargin, 0, sideMargin, 0 )
	button:SetText( '#simple_skin_blacklist.teralib_missing.install' )
	button.DoClick = function() gui.OpenURL( TERALIB_URL ) end

	local text = vgui.Create( 'DLabel', frame )
	text:Dock( FILL )
	text:DockMargin( TEXT_PADDING, TEXT_PADDING, TEXT_PADDING, TEXT_PADDING )
	text:SetWrap( true )
	text:SetContentAlignment( TEXT_ALIGNMENT )
	text:SetText( '#simple_skin_blacklist.teralib_missing.text' )

end

hook.Add( 'InitPostEntity', 'SSB.TeraLibWarning', function()
	timer.Simple( WARNING_DELAY, showWarning )
end )
