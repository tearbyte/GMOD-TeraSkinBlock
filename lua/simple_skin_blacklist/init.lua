
SSB = SSB or {}

SSB.VALUE_BITS = 8
-- Sizes of the DB columns
SSB.MODEL_LENGTH = 255
SSB.GROUP_LENGTH = 64
-- The skin is restricted as one more bodygroup
SSB.SKIN_GROUP = '$skin'

SSB.PRIVILEGE_MENU = 'simple_skin_blacklist_menu'
SSB.PRIVILEGE_SUPPRESS_CHECK = 'simple_skin_blacklist_suppress_check'

SSB.NET_ACCESS = 'SimpleSkinBlacklist.Access'
SSB.NET_SYNC = 'SimpleSkinBlacklist.Sync'
SSB.NET_CHANGE = 'SimpleSkinBlacklist.Change'
SSB.NET_CHANGE_BODYGROUP = 'SimpleSkinBlacklist.ChangeBodygroup'
SSB.NET_SET_CONVAR = 'SimpleSkinBlacklist.SetConVar'

SSB.LOG_CATEGORY = 'SimpleSkinBlacklist'

SSB.NOTIFY_ERROR = { type = TeraLib.notify.TYPE_ERROR, style = TeraLib.notify.STYLE_TERALIB }

local CONVAR_FLAGS = { FCVAR_ARCHIVE, FCVAR_REPLICATED }
local SYNC_SIZE_BITS = 32
local LINE_SEPARATOR = '\n'
local FIELD_SEPARATOR = '\t'
local BLACKLIST_RECORD = 'b'
local FORBIDDEN_RECORD = 'f'
-- So the compressed text is never empty
local SYNC_HEADER = 'ssb'

SSB.convars = {
	enable = CreateConVar( 'simple_skin_blacklist_enable', 1, CONVAR_FLAGS, 'Enable the skin blacklist' ),
	supressAdmin = CreateConVar( 'simple_skin_blacklist_supress_admin', 1, CONVAR_FLAGS, 'Admins skip the skin check (used without CAMI)' ),
	supressSuperadmin = CreateConVar( 'simple_skin_blacklist_supress_superadmin', 1, CONVAR_FLAGS, 'Superadmins skip the skin check (used without CAMI)' ),
}

SSB.blacklist = {}
-- { [ path ] = { [ group ] = { [ value ] = true } } }
SSB.forbidden = {}

function SSB.NormalizePath( path )
	return ( string.gsub( string.lower( path ), '\\', '/' ) )
end

function SSB.WriteSync()

	local lines = { SYNC_HEADER }
	for model in pairs( SSB.blacklist ) do
		lines[ #lines + 1 ] = BLACKLIST_RECORD .. FIELD_SEPARATOR .. model
	end

	for model, groups in pairs( SSB.forbidden ) do
		for group, values in pairs( groups ) do
			for value in pairs( values ) do
				lines[ #lines + 1 ] = table.concat( { FORBIDDEN_RECORD, model, group, value }, FIELD_SEPARATOR )
			end
		end
	end

	local data = util.Compress( table.concat( lines, LINE_SEPARATOR ) )
	net.WriteUInt( #data, SYNC_SIZE_BITS )
	net.WriteData( data, #data )

end

function SSB.ReadSync()

	local blacklist = {}
	local forbidden = {}
	local text = util.Decompress( net.ReadData( net.ReadUInt( SYNC_SIZE_BITS ) ) )

	for _, line in ipairs( string.Explode( LINE_SEPARATOR, text ) ) do
		local fields = string.Explode( FIELD_SEPARATOR, line )
		if fields[ 1 ] == BLACKLIST_RECORD then
			blacklist[ fields[ 2 ] ] = true
			continue
		end

		if fields[ 1 ] ~= FORBIDDEN_RECORD then continue end

		local groups = forbidden[ fields[ 2 ] ] or {}
		forbidden[ fields[ 2 ] ] = groups
		groups[ fields[ 3 ] ] = groups[ fields[ 3 ] ] or {}
		groups[ fields[ 3 ] ][ tonumber( fields[ 4 ] ) ] = true
	end

	return blacklist, forbidden

end
