
-- Pages of the addon in TeraWiki, added only if the wiki is installed

local SECTION = 'simple_skin_blacklist'

local function addPages()

	TeraLibWiki.AddSection( {
		id = SECTION,
		title = 'SSB.Wiki.Section',
		icon = 'icon16/user_delete.png',
		order = 20,
	} )

	TeraLibWiki.AddPage( {
		section = SECTION,
		id = 'usage',
		order = 1,
		audience = TeraLibWiki.AUDIENCE_PLAYERS,
		title = 'SSB.Wiki.Usage.Title',
		blocks = {
			{ type = 'text', text = 'SSB.Wiki.Usage.Text1' },
			{ type = 'heading', text = 'SSB.Wiki.Usage.Heading1' },
			{ type = 'text', text = 'SSB.Wiki.Usage.Text2' },
			{ type = 'table',
				columns = { 'SSB.Wiki.Usage.Column1', 'SSB.Wiki.Usage.Column2' },
				rows = {
					{ 'SSB.Wiki.Usage.Cell1', 'SSB.Wiki.Usage.Cell2' },
					{ 'SSB.Wiki.Usage.Cell3', 'SSB.Wiki.Usage.Cell4' },
					{ 'SSB.Wiki.Usage.Cell5', 'SSB.Wiki.Usage.Cell6' },
				},
			},
			{ type = 'note', text = 'SSB.Wiki.Usage.Note1' },
			{ type = 'table',
				columns = { 'SSB.Wiki.Usage.Column3', 'SSB.Wiki.Usage.Column4' },
				rows = {
					{ 'simple_skin_blacklist_menu', 'SSB.Wiki.Usage.Cell7' },
					{ 'simple_skin_blacklist_suppress_check', 'SSB.Wiki.Usage.Cell8' },
					{ 'simple_skin_blacklist_enable', 'SSB.Wiki.Usage.Cell9' },
					{ 'simple_skin_blacklist_supress_admin', 'SSB.Wiki.Usage.Cell10' },
					{ 'simple_skin_blacklist_supress_superadmin', 'SSB.Wiki.Usage.Cell11' },
				},
			},
		},
	} )

	TeraLibWiki.AddPage( {
		section = SECTION,
		id = 'api',
		order = 2,
		audience = TeraLibWiki.AUDIENCE_DEVELOPERS,
		title = 'SSB.Wiki.Api.Title',
		blocks = {
			{ type = 'text', text = 'SSB.Wiki.Api.Text1' },
			{ type = 'code', code = [[
if SSB then
	SSB.IsModelAllowed( 'models/player/alyx.mdl' )
	SSB.IsValueAllowed( 'models/player/alyx.mdl', 'hat', 1 ) -- SSB.SKIN_GROUP for the skin
end

-- The blacklist, the forbidden values or the access changed
hook.Add( 'SSB.Updated', 'MyAddon.Refresh', function()
	MyAddon.RefreshModelList()
end )]] },
			{ type = 'note', text = 'SSB.Wiki.Api.Note1' },
		},
	} )

end

hook.Add( 'InitPostEntity', 'SSB.Wiki', function()

	if not TeraLibWiki then return end
	addPages()

end )
