
SSB = SSB or {}

SSB.MODEL_COUNT_BITS = 16

SSB.PRIVILEGE_MENU = 'simple_skin_blacklist_menu'
SSB.PRIVILEGE_SUPPRESS_CHECK = 'simple_skin_blacklist_suppress_check'

SSB.NET_ACCESS = 'SimpleSkinBlacklist.Access'
SSB.NET_SYNC = 'SimpleSkinBlacklist.Sync'
SSB.NET_CHANGE = 'SimpleSkinBlacklist.Change'
SSB.NET_SET_CONVAR = 'SimpleSkinBlacklist.SetConVar'

SSB.LOG_CATEGORY = 'SimpleSkinBlacklist'

-- TeraLib.Notify data of the addon errors, read-only
SSB.NOTIFY_ERROR = { type = TeraLib.notify.TYPE_ERROR, style = TeraLib.notify.STYLE_TERALIB }

local CONVAR_FLAGS = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

-- Keys are sent by the menu in NET_SET_CONVAR
SSB.convars = {
	enable = CreateConVar( 'simple_skin_blacklist_enable', 1, CONVAR_FLAGS, 'Enable the skin blacklist' ),
	supressAdmin = CreateConVar( 'simple_skin_blacklist_supress_admin', 1, CONVAR_FLAGS, 'Admins skip the skin check (used without CAMI)' ),
	supressSuperadmin = CreateConVar( 'simple_skin_blacklist_supress_superadmin', 1, CONVAR_FLAGS, 'Superadmins skip the skin check (used without CAMI)' ),
}

-- Blacklisted models: { [ lowercase path ] = true }, every other player model is allowed and can replace them
SSB.blacklist = {}

--[[
	Write an array of model paths into the started net message.
	@param models table - array of strings
]]--
function SSB.WriteModels( models )

	net.WriteUInt( #models, SSB.MODEL_COUNT_BITS )
	for _, model in ipairs( models ) do
		net.WriteString( model )
	end

end

--[[
	Read an array of model paths written by SSB.WriteModels.
	@return table - array of strings
]]--
function SSB.ReadModels()

	local models = {}
	for i = 1, net.ReadUInt( SSB.MODEL_COUNT_BITS ) do
		models[ i ] = net.ReadString()
	end

	return models

end
