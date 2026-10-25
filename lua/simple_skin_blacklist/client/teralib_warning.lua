
-- Included only without TeraLib, so only stock Derma and its own phrases are used here.
-- Every TeraLib addon ships this file: the addons add their names to one list, one window shows them all

local ADDON_NAME = 'Simple Skin Blacklist'
local WARNING_DELAY = 10
local WINDOW_WIDTH = 500
local WINDOW_BASE_HEIGHT = 170
local ADDON_LINE_HEIGHT = 18
local TEXT_PADDING = 5
local TEXT_ALIGNMENT = 7 -- Top left, numpad layout
local BUTTON_WIDTH = 120
local BUTTON_HEIGHT = 25
local DEFAULT_LANG = 'en'
local TERALIB_URL = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464'

-- By gmod_language, other languages get the English phrases. {addons} is the list of the addons
local PHRASES = {
	en = {
		title = 'TeraLib is required',
		text = 'TeraLib is not installed on this server, these addons don\'t work without it:\n\n{addons}\n\nIf you are not an administrator, please let the server administration know about it.',
		install = 'Open TeraLib',
	},
	ru = {
		title = 'Требуется TeraLib',
		text = 'На сервере не установлена TeraLib, без неё не работают аддоны:\n\n{addons}\n\nЕсли вы не администратор, сообщите об этом администрации сервера.',
		install = 'Открыть TeraLib',
	},
	uk = {
		title = 'Потрібна TeraLib',
		text = 'На сервері не встановлено TeraLib, без неї не працюють аддони:\n\n{addons}\n\nЯкщо ви не адміністратор, повідомте про це адміністрацію сервера.',
		install = 'Відкрити TeraLib',
	},
}

TeraLibMissingAddons = TeraLibMissingAddons or {}
table.insert( TeraLibMissingAddons, ADDON_NAME )

-- The first addon shows the window for every one of them
if #TeraLibMissingAddons > 1 then return end

local function showWarning()

	local phrases = PHRASES[ GetConVar( 'gmod_language' ):GetString() ] or PHRASES[ DEFAULT_LANG ]
	local addons = '• ' .. table.concat( TeraLibMissingAddons, '\n• ' )

	local frame = vgui.Create( 'DFrame' )
	frame:SetSize( WINDOW_WIDTH, WINDOW_BASE_HEIGHT + #TeraLibMissingAddons * ADDON_LINE_HEIGHT )
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
	text:SetText( string.Replace( phrases.text, '{addons}', addons ) )

end

-- The other addons register their names while the autorun files run, the window is shown after
hook.Add( 'InitPostEntity', 'TeraLib.MissingWarning', function()
	timer.Simple( WARNING_DELAY, showWarning )
end )
