
local PHRASES = {
	en = {
		[ 'SSB.Title' ] = 'Skin blacklist',
		[ 'SSB.Search' ] = 'Search...',
		[ 'SSB.Name' ] = 'Name',
		[ 'SSB.Path' ] = 'Path',
		[ 'SSB.Help' ] = 'Left click on a model toggles it. Models colored like a disabled switch are blacklisted, the rest are allowed. A player with a blacklisted model gets a random allowed one, so at least one model always stays allowed.',
		[ 'SSB.Enable' ] = 'Enable the blacklist',
		[ 'SSB.SupressAdmin' ] = 'Skip the check for admins',
		[ 'SSB.SupressSuperadmin' ] = 'Skip the check for superadmins',
		[ 'SSB.ManagedByAdminMod' ] = 'Skipping the check is configured in the admin addon',
		[ 'SSB.Replaced' ] = 'This skin is blacklisted, it was replaced',
		[ 'SSB.NoAccess' ] = 'You don\'t have access to this menu',
		[ 'SSB.LastAllowed' ] = 'The last allowed model can\'t be blacklisted',
	},
	ru = {
		[ 'SSB.Title' ] = 'Чёрный список скинов',
		[ 'SSB.Search' ] = 'Поиск...',
		[ 'SSB.Name' ] = 'Название',
		[ 'SSB.Path' ] = 'Путь',
		[ 'SSB.Help' ] = 'ЛКМ по модели переключает её. Модели цвета выключенного переключателя запрещены, остальные разрешены. Игроку с запрещённой моделью ставится случайная разрешённая, поэтому хотя бы одна модель всегда остаётся разрешённой.',
		[ 'SSB.Enable' ] = 'Включить чёрный список',
		[ 'SSB.SupressAdmin' ] = 'Не проверять админов',
		[ 'SSB.SupressSuperadmin' ] = 'Не проверять суперадминов',
		[ 'SSB.ManagedByAdminMod' ] = 'Обход проверки настраивается в админ-аддоне',
		[ 'SSB.Replaced' ] = 'Этот скин запрещён, он был заменён',
		[ 'SSB.NoAccess' ] = 'У вас нет доступа к этому меню',
		[ 'SSB.LastAllowed' ] = 'Последнюю разрешённую модель нельзя запретить',
	},
}

for lang, phrases in pairs( PHRASES ) do

	for key, phrase in pairs( phrases ) do
		TeraLib.lang.Add( lang, key, phrase )
	end

end
