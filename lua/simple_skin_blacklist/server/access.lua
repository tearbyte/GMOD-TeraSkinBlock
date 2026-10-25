
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

local extraInfo = {}
for _, privilege in ipairs( PRIVILEGES ) do
	extraInfo[ privilege.Name ] = { Fallback = privilege.MinAccess }
end

local fallbackChecks = {
	[ SSB.PRIVILEGE_MENU ] = function( ply ) return ply:IsSuperAdmin() end,
	[ SSB.PRIVILEGE_SUPPRESS_CHECK ] = function( ply )
		if ply:IsSuperAdmin() then return SSB.convars.supressSuperadmin:GetBool() end
		return ply:IsAdmin() and SSB.convars.supressAdmin:GetBool()
	end,
}

function SSB.CheckAccess( ply, privilegeName, callback )

	if not CAMI then
		callback( fallbackChecks[ privilegeName ]( ply ) )
		return
	end

	CAMI.PlayerHasAccess( ply, privilegeName, callback, nil, extraInfo[ privilegeName ] )

end

-- CAMI of the admin addons is loaded by now
hook.Add( 'InitPostEntity', 'SSB.RegisterPrivileges', function()

	if not CAMI then return end

	for _, privilege in ipairs( PRIVILEGES ) do
		CAMI.RegisterPrivilege( privilege )
	end

end )
