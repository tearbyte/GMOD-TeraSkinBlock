
local PRIVILEGES = {
	{
		Name = SSB.PRIVILEGE_MENU,
		MinAccess = 'superadmin',
		Description = 'Open the TeraSkinBlock menu and edit the lists',
	},
	{
		Name = SSB.PRIVILEGE_SUPPRESS_CHECK,
		MinAccess = 'admin',
		Description = 'Use blacklisted skins',
	},
}

-- CAMI extra info per privilege: used if the check happens before the privileges are registered
local extraInfo = {}
for _, privilege in ipairs( PRIVILEGES ) do
	extraInfo[ privilege.Name ] = { Fallback = privilege.MinAccess }
end

-- Access without CAMI
local fallbackChecks = {
	[ SSB.PRIVILEGE_MENU ] = function( ply ) return ply:IsSuperAdmin() end,
	[ SSB.PRIVILEGE_SUPPRESS_CHECK ] = function( ply )
		if ply:IsSuperAdmin() then return SSB.convars.supressSuperadmin:GetBool() end
		return ply:IsAdmin() and SSB.convars.supressAdmin:GetBool()
	end,
}

--[[
	Check a privilege of the player: through CAMI if an admin addon provides it, otherwise by the fallback.
	CAMI is checked on every call, so the load order of the admin addon doesn't matter.
	@param ply Player
	@param privilegeName string - SSB.PRIVILEGE_*
	@param callback function( hasAccess ) - may be called asynchronously
]]--
function SSB.CheckAccess( ply, privilegeName, callback )

	if not CAMI then
		callback( fallbackChecks[ privilegeName ]( ply ) )
		return
	end

	CAMI.PlayerHasAccess( ply, privilegeName, callback, nil, extraInfo[ privilegeName ] )

end

-- All autorun files, including CAMI of admin addons, are loaded by now
hook.Add( 'InitPostEntity', 'SSB.RegisterPrivileges', function()

	if not CAMI then return end

	for _, privilege in ipairs( PRIVILEGES ) do
		CAMI.RegisterPrivilege( privilege )
	end

end )
