
local TABLE_NAME = 'simple_skin_blacklist'
local BLACKLIST_ID = 1
local OLD_DATA_FILE = 'simple_skin_blacklist.json'
local OLD_DATA_BACKUP = 'simple_skin_blacklist_old.json'
local BODYGROUPS_TABLE = 'simple_skin_blacklist_bodygroups'
-- Text: a signed TINYINT of MySQL can't hold values over 127
local VALUE_LENGTH = 8
local MODEL_INFO_ENTITY = 'prop_dynamic'

local SELECT_QUERY = 'SELECT model FROM ' .. TABLE_NAME .. ' WHERE list_id = ?'
-- Rows of the removed alternatives list would block the primary key
local CLEANUP_QUERY = 'DELETE FROM ' .. TABLE_NAME .. ' WHERE list_id <> ?'
local INSERT_QUERY = 'INSERT INTO ' .. TABLE_NAME .. ' ( model, list_id ) VALUES ( ?, ? )'
local DELETE_QUERY = 'DELETE FROM ' .. TABLE_NAME .. ' WHERE model = ?'
local SELECT_BODYGROUPS_QUERY = 'SELECT model, bodygroup, value FROM ' .. BODYGROUPS_TABLE
local INSERT_BODYGROUP_QUERY = 'INSERT INTO ' .. BODYGROUPS_TABLE .. ' ( model, bodygroup, value ) VALUES ( ?, ?, ? )'
local DELETE_BODYGROUP_QUERY = 'DELETE FROM ' .. BODYGROUPS_TABLE .. ' WHERE model = ? AND bodygroup = ? AND value = ?'

local db
local alternatives = {}

local function rebuildAlternatives()

	alternatives = {}
	for _, path in pairs( player_manager.AllValidModels() ) do
		if SSB.blacklist[ SSB.NormalizePath( path ) ] then continue end
		alternatives[ #alternatives + 1 ] = path
	end

end

function SSB.GetRandomAlternative()
	return alternatives[ math.random( #alternatives ) ]
end

function SSB.SetBlacklisted( model, isBlacklisted )

	model = SSB.NormalizePath( model )
	if tobool( SSB.blacklist[ model ] ) == isBlacklisted then return true end

	SSB.blacklist[ model ] = isBlacklisted or nil
	rebuildAlternatives()

	if #alternatives == 0 then
		SSB.blacklist[ model ] = nil
		rebuildAlternatives()
		return false
	end

	if isBlacklisted then
		db:Query( INSERT_QUERY, { model, BLACKLIST_ID } )
	else
		db:Query( DELETE_QUERY, { model } )
	end

	return true

end

local function setForbiddenInMemory( model, group, value, isForbidden )

	local groups = SSB.forbidden[ model ] or {}
	local values = groups[ group ] or {}

	values[ value ] = isForbidden or nil
	groups[ group ] = next( values ) and values or nil
	SSB.forbidden[ model ] = next( groups ) and groups or nil

end

local function getGroupCounts( model )

	local ent = ents.Create( MODEL_INFO_ENTITY )
	ent:SetModel( model )

	local counts = { [ SSB.SKIN_GROUP ] = ent:SkinCount() }
	for _, bodygroup in ipairs( ent:GetBodyGroups() ) do
		counts[ bodygroup.name ] = bodygroup.num
	end

	ent:Remove()
	return counts

end

function SSB.SetBodygroupAllowed( model, group, value, isAllowed )

	model = SSB.NormalizePath( model )
	local values = SSB.forbidden[ model ] and SSB.forbidden[ model ][ group ]
	local isForbidden = tobool( values and values[ value ] )
	if isForbidden ~= isAllowed then return end

	if not isAllowed then
		local count = util.IsValidModel( model ) and getGroupCounts( model )[ group ]
		if not count or value >= count then return 'SSB.InvalidValue' end
		if count - table.Count( values or {} ) <= 1 then return 'SSB.LastValue' end
	end

	setForbiddenInMemory( model, group, value, not isAllowed )

	if isAllowed then
		db:Query( DELETE_BODYGROUP_QUERY, { model, group, tostring( value ) } )
	else
		db:Query( INSERT_BODYGROUP_QUERY, { model, group, tostring( value ) } )
	end

end

local function migrateOldData()

	local old = util.JSONToTable( file.Read( OLD_DATA_FILE, 'DATA' ) )
	local models = player_manager.AllValidModels()

	for name in pairs( old.disallowed_skins ) do
		local path = models[ name ]
		if not path then continue end
		SSB.SetBlacklisted( path, true )
	end

	file.Rename( OLD_DATA_FILE, OLD_DATA_BACKUP, 'DATA' )
	TeraLib.logger:Info( SSB.LOG_CATEGORY, 'Old data migrated, %s renamed to %s', OLD_DATA_FILE, OLD_DATA_BACKUP )

end

local function onLoaded( results, err )

	if err then return end

	for _, row in ipairs( results ) do
		SSB.blacklist[ row.model ] = true
	end

	rebuildAlternatives()
	if file.Exists( OLD_DATA_FILE, 'DATA' ) then migrateOldData() end
	SSB.ResetChecks()
	-- Players who joined before the DB answered got empty lists
	SSB.SendSync()

end

local function onBodygroupsLoaded( results, err )

	if err then return end

	for _, row in ipairs( results ) do
		setForbiddenInMemory( row.model, row.bodygroup, tonumber( row.value ), true )
	end

	SSB.ResetChecks()
	SSB.SendSync()

end

hook.Add( 'InitPostEntity', 'SSB.LoadData', function()

	db = TeraLib.db:GetDefaultDB()
	db:MakeTable( TABLE_NAME, {
		{ name = 'model', type = 'VARCHAR', len = SSB.MODEL_LENGTH, primarykey = true },
		{ name = 'list_id', type = 'TINYINT' },
	}, true )
	db:Query( CLEANUP_QUERY, { BLACKLIST_ID } )
	db:Query( SELECT_QUERY, { BLACKLIST_ID }, onLoaded )

	db:MakeTable( BODYGROUPS_TABLE, {
		{ name = 'model', type = 'VARCHAR', len = SSB.MODEL_LENGTH },
		{ name = 'bodygroup', type = 'VARCHAR', len = SSB.GROUP_LENGTH },
		{ name = 'value', type = 'VARCHAR', len = VALUE_LENGTH },
	}, true )
	db:Query( SELECT_BODYGROUPS_QUERY, nil, onBodygroupsLoaded )

end )
