
local function isRestricted()
	return SSB.convars.enable:GetBool() and not SSB.canSkipCheck
end

function SSB.IsModelAllowed( path )
	return not isRestricted() or not SSB.blacklist[ SSB.NormalizePath( path ) ]
end

function SSB.IsValueAllowed( path, group, value )

	if not isRestricted() then return true end

	local groups = SSB.forbidden[ SSB.NormalizePath( path ) ]
	return not ( groups and groups[ group ] and groups[ group ][ value ] )

end
