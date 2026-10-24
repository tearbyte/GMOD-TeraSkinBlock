
--[[
	Client API for other addons, player model selectors for example.
	Both functions take the disabled blacklist and the players skipping the check into account.
	The hook SSB.Updated is run when the blacklist, the forbidden values or the access change.
]]--

local function isRestricted()
	return SSB.convars.enable:GetBool() and not SSB.canSkipCheck
end

--[[
	@param path string - model path
	@return boolean - whether the local player can use the model
]]--
function SSB.IsModelAllowed( path )
	return not isRestricted() or not SSB.blacklist[ SSB.NormalizePath( path ) ]
end

--[[
	@param path string - model path
	@param group string - bodygroup name or SSB.SKIN_GROUP
	@param value number
	@return boolean - whether the local player can use the bodygroup or skin value
]]--
function SSB.IsValueAllowed( path, group, value )

	if not isRestricted() then return true end

	local groups = SSB.forbidden[ SSB.NormalizePath( path ) ]
	return not ( groups and groups[ group ] and groups[ group ][ value ] )

end
