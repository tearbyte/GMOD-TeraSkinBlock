
-- English phrases of the TeraWiki pages of the addon

local PHRASES = {
	-- Page usage
	[ 'SSB.Wiki.Section' ] = 'TeraSkinBlock',
	[ 'SSB.Wiki.Usage.Title' ] = 'How it works',
	[ 'SSB.Wiki.Usage.Text1' ] = 'The server forbids some player models, skins and bodygroups. A player with a forbidden model gets a random allowed one, forbidden skin and bodygroup values are replaced with random allowed ones, and the player gets a notification. Model selectors on TeraLib hide what is forbidden.',
	[ 'SSB.Wiki.Usage.Heading1' ] = 'For admins',
	[ 'SSB.Wiki.Usage.Text2' ] = 'The Skin blacklist page of the TeraLib settings is shown to players with access (the command simple_skin_blacklist_menu opens it).',
	[ 'SSB.Wiki.Usage.Column1' ] = 'Action',
	[ 'SSB.Wiki.Usage.Column2' ] = 'Result',
	[ 'SSB.Wiki.Usage.Cell1' ] = 'Left click on a model',
	[ 'SSB.Wiki.Usage.Cell2' ] = 'Selects it for the middle panel',
	[ 'SSB.Wiki.Usage.Cell3' ] = 'Right click on a model',
	[ 'SSB.Wiki.Usage.Cell4' ] = 'Forbids or allows it',
	[ 'SSB.Wiki.Usage.Cell5' ] = 'A switch in the middle panel',
	[ 'SSB.Wiki.Usage.Cell6' ] = 'Forbids or allows a skin or bodygroup value',
	[ 'SSB.Wiki.Usage.Note1' ] = 'At least one model and one value of each group always stay allowed: there must be something to replace the forbidden ones with.',
	[ 'SSB.Wiki.Usage.Column3' ] = 'Privilege or convar',
	[ 'SSB.Wiki.Usage.Column4' ] = 'Gives',
	[ 'SSB.Wiki.Usage.Cell7' ] = 'The menu, superadmins by default',
	[ 'SSB.Wiki.Usage.Cell8' ] = 'Skipping the check, admins by default',
	[ 'SSB.Wiki.Usage.Cell9' ] = 'Enables the blacklist',
	[ 'SSB.Wiki.Usage.Cell10' ] = 'Without CAMI: admins skip the check',
	[ 'SSB.Wiki.Usage.Cell11' ] = 'Without CAMI: superadmins skip the check',

	-- Page api
	[ 'SSB.Wiki.Api.Title' ] = 'Client API',
	[ 'SSB.Wiki.Api.Text1' ] = 'Other addons, for example player model selectors, can ask what the local player may use. Both functions take the disabled blacklist and the players skipping the check into account.',
	[ 'SSB.Wiki.Api.Note1' ] = 'Hiding is a convenience: the server checks the real model anyway.',
}

for key, phrase in pairs( PHRASES ) do
	TeraLib.lang.Add( 'en', key, phrase )
end
