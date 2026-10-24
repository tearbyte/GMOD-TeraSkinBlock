
local CHECK_INTERVAL = 1
local CHECK_TIMER = 'SSB.CheckModels'
local KEY_SEPARATOR = ':'

-- Last checked appearance of each player, the polling skips players whose appearance hasn't changed
local checkedAppearance = setmetatable( {}, { __mode = 'k' } )

--[[
	The model, and the skin with bodygroups if the model has restricted values.
	Built every polling tick, so the bodygroups are read only for restricted models.
	@param ply Player
	@return string
]]--
local function getAppearanceKey( ply )

	local model = ply:GetModel()
	if not SSB.forbidden[ string.lower( model ) ] then return model end

	local key = model .. KEY_SEPARATOR .. ply:GetSkin()
	for i = 0, ply:GetNumBodyGroups() - 1 do
		key = key .. KEY_SEPARATOR .. ply:GetBodygroup( i )
	end

	return key

end

--[[
	A random value from 0 to count - 1 that isn't forbidden.
	@param forbidden table - { [ value ] = true }
	@param count number
	@return number|nil - nil if every value is forbidden
]]--
local function getRandomAllowed( forbidden, count )

	local allowed = {}
	for value = 0, count - 1 do
		if forbidden[ value ] then continue end
		allowed[ #allowed + 1 ] = value
	end

	return allowed[ math.random( #allowed ) ]

end

--[[
	Replace the forbidden skin and bodygroup values of the player with random allowed ones.
	@param ply Player
	@return boolean - true if something was replaced
]]--
local function replaceForbiddenValues( ply )

	local groups = SSB.forbidden[ string.lower( ply:GetModel() ) ]
	if not groups then return false end

	local replaced = false

	local forbiddenSkins = groups[ SSB.SKIN_GROUP ]
	if forbiddenSkins and forbiddenSkins[ ply:GetSkin() ] then
		local skin = getRandomAllowed( forbiddenSkins, ply:SkinCount() )
		if skin then
			ply:SetSkin( skin )
			replaced = true
		end
	end

	for _, bodygroup in ipairs( ply:GetBodyGroups() ) do
		local forbidden = groups[ bodygroup.name ]
		if not forbidden or not forbidden[ ply:GetBodygroup( bodygroup.id ) ] then continue end

		local value = getRandomAllowed( forbidden, bodygroup.num )
		if not value then continue end

		ply:SetBodygroup( bodygroup.id, value )
		replaced = true
	end

	return replaced

end

--[[
	Replace the model of the player if it's blacklisted, then its forbidden skin and bodygroup values,
	unless the player can skip the check.
	@param ply Player
]]--
function SSB.CheckPlayer( ply )

	checkedAppearance[ ply ] = getAppearanceKey( ply )

	if not SSB.convars.enable:GetBool() then return end

	local model = ply:GetModel()
	local isBlacklisted = SSB.blacklist[ string.lower( model ) ]
	if not isBlacklisted and not SSB.forbidden[ string.lower( model ) ] then return end

	SSB.CheckAccess( ply, SSB.PRIVILEGE_SUPPRESS_CHECK, function( hasAccess )
		-- The access check may be asynchronous, the model could change meanwhile
		if hasAccess or not IsValid( ply ) or ply:GetModel() ~= model then return end

		if isBlacklisted then ply:SetModel( SSB.GetRandomAlternative() ) end
		-- The alternative may have restricted values too
		local replacedValues = replaceForbiddenValues( ply )
		checkedAppearance[ ply ] = getAppearanceKey( ply )

		if isBlacklisted then
			TeraLib.Notify( ply, 'SSB.Replaced', SSB.NOTIFY_ERROR )
		elseif replacedValues then
			TeraLib.Notify( ply, 'SSB.BodygroupsReplaced', SSB.NOTIFY_ERROR )
		end
	end )

end

--[[
	Make the polling check players again, even if their appearance hasn't changed.
	@param ply Player|nil - one player, everyone if nil
]]--
function SSB.ResetChecks( ply )

	if ply then
		checkedAppearance[ ply ] = nil
		return
	end

	table.Empty( checkedAppearance )

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

-- Catches models, skins and bodygroups set by other addons outside of the hooks above
timer.Create( CHECK_TIMER, CHECK_INTERVAL, 0, function()

	for _, ply in player.Iterator() do
		if checkedAppearance[ ply ] == getAppearanceKey( ply ) then continue end
		SSB.CheckPlayer( ply )
	end

end )

for _, convar in pairs( SSB.convars ) do
	cvars.AddChangeCallback( convar:GetName(), function() SSB.ResetChecks() end, 'SSB.ResetChecks' )
end
