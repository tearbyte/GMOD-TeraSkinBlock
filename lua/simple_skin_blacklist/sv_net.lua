
util.AddNetworkString( SSB.NET_ACCESS )
util.AddNetworkString( SSB.NET_SYNC )
util.AddNetworkString( SSB.NET_CHANGE )
util.AddNetworkString( SSB.NET_SET_CONVAR )

-- Players with access to the menu, they get the blacklist
local menuUsers = setmetatable( {}, { __mode = 'k' } )

local function isMenuUser( ply )
	return menuUsers[ ply ] == true
end

--[[
	Send the blacklist.
	@param target - see TeraLib.net.SendTo
]]--
local function sendSync( target )

	net.Start( SSB.NET_SYNC )
	SSB.WriteModels( table.GetKeys( SSB.blacklist ) )
	TeraLib.net.SendTo( target )

end

--[[
	Check the menu access of the player and tell the client, whether it can open the menu
	and whether the check skipping is configured by an admin addon.
	@param ply Player
]]--
local function sendAccess( ply )

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not IsValid( ply ) then return end

		menuUsers[ ply ] = hasAccess or nil

		net.Start( SSB.NET_ACCESS )
		net.WriteBool( hasAccess )
		net.WriteBool( CAMI ~= nil )
		net.Send( ply )

		if hasAccess then sendSync( ply ) end
	end )

end

hook.Add( 'TeraLib.PlayerFullyInitialized', 'SSB.SendAccess', sendAccess )

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
		sendSync( isMenuUser )
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
