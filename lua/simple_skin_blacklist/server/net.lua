
-- Requests a player can send per RATE_WINDOW seconds, the rest are dropped
local RATE_LIMIT = 2
local RATE_WINDOW = 1
-- Replaces the control characters of the strings from the clients in the log, so they can't fake log lines
local LOG_CONTROL_REPLACEMENT = '?'

util.AddNetworkString( SSB.NET_ACCESS )
util.AddNetworkString( SSB.NET_SYNC )
util.AddNetworkString( SSB.NET_CHANGE )
util.AddNetworkString( SSB.NET_CHANGE_BODYGROUP )
util.AddNetworkString( SSB.NET_SET_CONVAR )

-- Request counting window of each player: { start = SysTime(), count = number }
local rateWindows = setmetatable( {}, { __mode = 'k' } )

--[[
	Send the blacklist and the forbidden bodygroup and skin values.
	Every player gets them: the player model selectors hide what is forbidden.
	@param target - see TeraLib.net.SendTo, everyone if nil
]]--
function SSB.SendSync( target )

	net.Start( SSB.NET_SYNC )
	SSB.WriteSync()
	TeraLib.net.SendTo( target )

end

local function sanitizeForLog( str )
	return ( string.gsub( str, '%c', LOG_CONTROL_REPLACEMENT ) )
end

--[[
	Count a request of the player against the rate limit.
	The first dropped request of a window tells an admin about it and sends the lists back, so the menu
	shows the real state again. The next ones are dropped silently, so flooding isn't answered.
	@param ply Player
	@return boolean - true if the request fits the limit
]]--
local function acceptRequest( ply )

	local now = SysTime()
	local window = rateWindows[ ply ]

	if not window or now - window.start >= RATE_WINDOW then
		rateWindows[ ply ] = { start = now, count = 1 }
		return true
	end

	window.count = window.count + 1
	if window.count <= RATE_LIMIT then return true end
	if window.count ~= RATE_LIMIT + 1 then return false end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess or not IsValid( ply ) then return end
		TeraLib.Notify( ply, 'SSB.TooFast', SSB.NOTIFY_ERROR )
		SSB.SendSync( ply )
	end )

	return false

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
	SSB.SendSync( ply )

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

	if not acceptRequest( ply ) then return end

	local model = net.ReadString()
	local isBlacklisted = net.ReadBool()
	if #model > SSB.MODEL_LENGTH then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess or not IsValid( ply ) then return end

		if not SSB.SetBlacklisted( model, isBlacklisted ) then
			TeraLib.Notify( ply, 'SSB.LastAllowed', SSB.NOTIFY_ERROR )
			return
		end

		TeraLib.logger:Info( SSB.LOG_CATEGORY, '%s (%s) %s %s', sanitizeForLog( ply:Nick() ), ply:SteamID(), isBlacklisted and 'blacklisted' or 'allowed', sanitizeForLog( model ) )
		SSB.ResetChecks()
		SSB.SendSync()
	end )

end )

net.Receive( SSB.NET_CHANGE_BODYGROUP, function( _, ply )

	if not acceptRequest( ply ) then return end

	local model = net.ReadString()
	local group = net.ReadString()
	local value = net.ReadUInt( SSB.VALUE_BITS )
	local isAllowed = net.ReadBool()
	if #model > SSB.MODEL_LENGTH or #group > SSB.GROUP_LENGTH then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess or not IsValid( ply ) then return end

		local refusal = SSB.SetBodygroupAllowed( model, group, value, isAllowed )
		if refusal then
			TeraLib.Notify( ply, refusal, SSB.NOTIFY_ERROR )
			-- The menu has already switched the value, the lists bring it back
			SSB.SendSync( ply )
			return
		end

		TeraLib.logger:Info( SSB.LOG_CATEGORY, '%s (%s) %s %s %s of %s', sanitizeForLog( ply:Nick() ), ply:SteamID(), isAllowed and 'allowed' or 'forbade', sanitizeForLog( group ), value, sanitizeForLog( model ) )
		SSB.ResetChecks()
		SSB.SendSync()
	end )

end )

net.Receive( SSB.NET_SET_CONVAR, function( _, ply )

	if not acceptRequest( ply ) then return end

	local convar = SSB.convars[ net.ReadString() ]
	local value = net.ReadBool()
	if not convar then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_MENU, function( hasAccess )
		if not hasAccess then return end
		convar:SetBool( value )
	end )

end )
