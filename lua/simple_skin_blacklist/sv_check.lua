
local CHECK_INTERVAL = 1
local CHECK_TIMER = 'SSB.CheckModels'

-- Last checked model of each player, the polling skips players whose model hasn't changed
local checkedModels = setmetatable( {}, { __mode = 'k' } )

--[[
	Replace the model of the player if it's blacklisted and the player can't skip the check.
	@param ply Player
]]--
function SSB.CheckPlayer( ply )

	local model = ply:GetModel()
	checkedModels[ ply ] = model

	if not SSB.convars.enable:GetBool() then return end
	if not SSB.blacklist[ string.lower( model ) ] then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_SUPPRESS_CHECK, function( hasAccess )
		-- The access check may be asynchronous, the model could change meanwhile
		if hasAccess or not IsValid( ply ) or ply:GetModel() ~= model then return end

		ply:SetModel( SSB.GetRandomAlternative() )
		TeraLib.Notify( ply, 'SSB.Replaced', SSB.NOTIFY_ERROR )
	end )

end

--[[
	Make the polling check players again, even if their models haven't changed.
	@param ply Player|nil - one player, everyone if nil
]]--
function SSB.ResetChecks( ply )

	if ply then
		checkedModels[ ply ] = nil
		return
	end

	table.Empty( checkedModels )

end

-- The gamemode sets the model right after these hooks
local function checkNextTick( ply )

	timer.Simple( 0, function()
		if not IsValid( ply ) then return end
		SSB.CheckPlayer( ply )
	end )

end

hook.Add( 'PlayerSpawn', 'SSB.CheckModel', checkNextTick )
hook.Add( 'PlayerChangedTeam', 'SSB.CheckModel', checkNextTick )

-- Catches models set by other addons outside of the hooks above
timer.Create( CHECK_TIMER, CHECK_INTERVAL, 0, function()

	for _, ply in player.Iterator() do
		if checkedModels[ ply ] == ply:GetModel() then continue end
		SSB.CheckPlayer( ply )
	end

end )

for _, convar in pairs( SSB.convars ) do
	cvars.AddChangeCallback( convar:GetName(), function() SSB.ResetChecks() end, 'SSB.ResetChecks' )
end
