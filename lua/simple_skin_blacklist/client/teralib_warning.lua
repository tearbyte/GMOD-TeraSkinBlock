
-- Works without TeraLib, so only stock Derma and its own phrases are used here

local WARNING_DELAY = 10
local WINDOW_WIDTH = 500
local WINDOW_HEIGHT = 170
local TEXT_PADDING = 5
local TEXT_ALIGNMENT = 7 -- Top left, numpad layout
local BUTTON_WIDTH = 120
local BUTTON_HEIGHT = 25
local DEFAULT_LANG = 'en'
local TERALIB_URL = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464'

-- By gmod_language, other languages get the English phrases
local PHRASES = {
	en = {
		title = 'Simple Skin Blacklist requires TeraLib',
		text = 'TeraLib is not installed on this server, so Simple Skin Blacklist doesn\'t work.\n\nIf you are not an administrator, please let the server administration know about it.',
		install = 'Open TeraLib',
	},
	ru = {
		title = 'Simple Skin Blacklist требует TeraLib',
		text = 'На сервере не установлена TeraLib, поэтому Simple Skin Blacklist не работает.\n\nЕсли вы не администратор, сообщите об этом администрации сервера.',
		install = 'Открыть TeraLib',
	},
	uk = {
		title = 'Simple Skin Blacklist потребує TeraLib',
		text = 'На сервері не встановлено TeraLib, тому Simple Skin Blacklist не працює.\n\nЯкщо ви не адміністратор, повідомте про це адміністрацію сервера.',
		install = 'Відкрити TeraLib',
	},
}

local function showWarning()

	-- Checked when the timer fires: all autorun files are loaded for sure
	if TeraLib then return end

	local phrases = PHRASES[ GetConVar( 'gmod_language' ):GetString() ] or PHRASES[ DEFAULT_LANG ]

	local frame = vgui.Create( 'DFrame' )
	frame:SetSize( WINDOW_WIDTH, WINDOW_HEIGHT )
	frame:SetTitle( phrases.title )
	frame:Center()
	frame:MakePopup()

	local button = vgui.Create( 'DButton', frame )
	button:Dock( BOTTOM )
	button:SetTall( BUTTON_HEIGHT )
	-- Centered: equal side margins
	local sideMargin = ( WINDOW_WIDTH - BUTTON_WIDTH ) / 2
	button:DockMargin( sideMargin, 0, sideMargin, 0 )
	button:SetText( phrases.install )
	button.DoClick = function() gui.OpenURL( TERALIB_URL ) end

	local text = vgui.Create( 'DLabel', frame )
	text:Dock( FILL )
	text:DockMargin( TEXT_PADDING, TEXT_PADDING, TEXT_PADDING, TEXT_PADDING )
	text:SetWrap( true )
	text:SetContentAlignment( TEXT_ALIGNMENT )
	text:SetText( phrases.text )

end

hook.Add( 'InitPostEntity', 'SSB.TeraLibWarning', function()
	timer.Simple( WARNING_DELAY, showWarning )
end )
