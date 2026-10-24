
local TABLE_NAME = 'simple_skin_blacklist'
local MODEL_LENGTH = 255
-- list_id of blacklisted rows, the column is kept for possible other lists
local BLACKLIST_ID = 1
local OLD_DATA_FILE = 'simple_skin_blacklist.json'
local OLD_DATA_BACKUP = 'simple_skin_blacklist_old.json'

local SELECT_QUERY = 'SELECT model FROM ' .. TABLE_NAME .. ' WHERE list_id = ?'
-- Rows of the removed alternatives list, they would block blacklisting the same models by the primary key
local CLEANUP_QUERY = 'DELETE FROM ' .. TABLE_NAME .. ' WHERE list_id <> ?'
local INSERT_QUERY = 'INSERT INTO ' .. TABLE_NAME .. ' ( model, list_id ) VALUES ( ?, ? )'
local DELETE_QUERY = 'DELETE FROM ' .. TABLE_NAME .. ' WHERE model = ?'

local db
-- Allowed player models for a random pick: every model that isn't blacklisted
local alternatives = {}

local function rebuildAlternatives()

	alternatives = {}
	for _, path in pairs( player_manager.AllValidModels() ) do
		if SSB.blacklist[ string.lower( path ) ] then continue end
		alternatives[ #alternatives + 1 ] = path
	end

end

function SSB.GetRandomAlternative()
	return alternatives[ math.random( #alternatives ) ]
end

--[[
	Blacklist or allow a model. The last allowed player model can't be blacklisted.
	@param model string - model path
	@param isBlacklisted boolean
	@return boolean - false if the model is the last allowed one
]]--
function SSB.SetBlacklisted( model, isBlacklisted )

	model = string.lower( model )
	if tobool( SSB.blacklist[ model ] ) == isBlacklisted then return true end

	SSB.blacklist[ model ] = isBlacklisted or nil
	rebuildAlternatives()

	-- Replacing a skin needs at least one allowed model
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

local function migrateOldData()

	-- The old format stores names: { disallowed_skins = { [ name ] = true }, ... }, unknown names are skipped
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

end

-- DefaultDB is registered by now, see TeraLib.db:GetDefaultDB
hook.Add( 'InitPostEntity', 'SSB.LoadData', function()

	db = TeraLib.db:GetDefaultDB()
	db:MakeTable( TABLE_NAME, {
		{ name = 'model', type = 'VARCHAR', len = MODEL_LENGTH, primarykey = true },
		{ name = 'list_id', type = 'TINYINT' },
	}, true )
	db:Query( CLEANUP_QUERY, { BLACKLIST_ID } )
	db:Query( SELECT_QUERY, { BLACKLIST_ID }, onLoaded )

end )
