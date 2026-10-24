
util.AddNetworkString( SSB.NET_ACCESS )
util.AddNetworkString( SSB.NET_SYNC )
util.AddNetworkString( SSB.NET_CHANGE )
util.AddNetworkString( SSB.NET_CHANGE_BODYGROUP )
util.AddNetworkString( SSB.NET_SET_CONVAR )

--[[
	Send the blacklist and the forbidden bodygroup and skin values.
	Every player gets them: the player model selectors hide what is forbidden.
	@param target - see TeraLib.net.SendTo
]]--
local function sendSync( target )

	net.Start( SSB.NET_SYNC )
	SSB.WriteModels( table.GetKeys( SSB.blacklist ) )
	SSB.WriteForbidden()
	TeraLib.net.SendTo( target )

end

--[[
	Tell the client whether it can open the menu, whether it skips the check,
	and whether the check skipping is configured by an admin addon.
	@param ply Player
]]--
local function sendAccess( ply )

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not IsValid( ply ) then return end

		SSB.CheckAccess( ply, SSB.PRIVILEGE_SUPPRESS_CHECK, function( canSkipCheck )
			if not IsValid( ply ) then return end

			net.Start( SSB.NET_ACCESS )
			net.WriteBool( hasAccess )
			net.WriteBool( canSkipCheck )
			net.WriteBool( CAMI ~= nil )
			net.Send( ply )
		end )
	end )

end

hook.Add( 'TeraLib.PlayerFullyInitialized', 'SSB.SendAccess', function( ply )

	sendAccess( ply )
	sendSync( ply )

end )

-- Without CAMI these convars decide who skips the check
for _, convar in ipairs( { SSB.convars.supressAdmin, SSB.convars.supressSuperadmin } ) do
	cvars.AddChangeCallback( convar:GetName(), function()
		for _, ply in player.Iterator() do
			sendAccess( ply )
		end
	end, 'SSB.UpdateAccess' )
end

hook.Add( 'CAMI.PlayerUsergroupChanged', 'SSB.UpdateAccess', function( ply )

	-- The admin addon may apply the new usergroup after the signal
	timer.Simple( 0, function()
		if not IsValid( ply ) then return end
		SSB.ResetChecks( ply )
		sendAccess( ply )
	end )

end )

net.Receive( SSB.NET_CHANGE, function( _, ply )

	local model = net.ReadString()
	local isBlacklisted = net.ReadBool()

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess or not IsValid( ply ) then return end

		if not SSB.SetBlacklisted( model, isBlacklisted ) then
			TeraLib.Notify( ply, 'SSB.LastAllowed', SSB.NOTIFY_ERROR )
			return
		end

		TeraLib.logger:Info( SSB.LOG_CATEGORY, '%s (%s) %s %s', ply:Nick(), ply:SteamID(), isBlacklisted and 'blacklisted' or 'allowed', model )
		SSB.ResetChecks()
		sendSync()
	end )

end )

net.Receive( SSB.NET_CHANGE_BODYGROUP, function( _, ply )

	local model = net.ReadString()
	local group = net.ReadString()
	local value = net.ReadUInt( SSB.VALUE_BITS )
	local isAllowed = net.ReadBool()

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess or not IsValid( ply ) then return end

		SSB.SetBodygroupAllowed( model, group, value, isAllowed )

		TeraLib.logger:Info( SSB.LOG_CATEGORY, '%s (%s) %s %s %s of %s', ply:Nick(), ply:SteamID(), isAllowed and 'allowed' or 'forbade', group, value, model )
		SSB.ResetChecks()
		sendSync()
	end )

end )

net.Receive( SSB.NET_SET_CONVAR, function( _, ply )

	local convar = SSB.convars[ net.ReadString() ]
	local value = net.ReadBool()
	if not convar then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess then return end
		convar:SetBool( value )
	end )

end )
