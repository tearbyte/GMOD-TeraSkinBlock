
local PHRASES = {
	en = {
		[ 'SSB.Title' ] = 'Skin blacklist',
		[ 'SSB.Search' ] = 'Search...',
		[ 'SSB.Name' ] = 'Name',
		[ 'SSB.Help' ] = 'Left click selects a model and opens its skins and bodygroups in the middle, right click toggles the model. Models colored like a disabled switch are blacklisted. A player with a blacklisted model or value gets a random allowed one, so at least one model and one value of each group always stay allowed.',
		[ 'SSB.Enable' ] = 'Enable the blacklist',
		[ 'SSB.SupressAdmin' ] = 'Skip the check for admins',
		[ 'SSB.SupressSuperadmin' ] = 'Skip the check for superadmins',
		[ 'SSB.ManagedByAdminMod' ] = 'Skipping the check is configured in the admin addon',
		[ 'SSB.Replaced' ] = 'This skin is blacklisted, it was replaced',
		[ 'SSB.NoAccess' ] = 'You don\'t have access to this menu',
		[ 'SSB.LastAllowed' ] = 'The last allowed model can\'t be blacklisted',
		[ 'SSB.Allowed' ] = 'Allowed',
		[ 'SSB.Skin' ] = 'Skin',
		[ 'SSB.SelectModel' ] = 'Left click a model to see its skins and bodygroups',
		[ 'SSB.NoBodygroups' ] = 'The model has no skins or bodygroups to choose from',
		[ 'SSB.BodygroupsReplaced' ] = 'Forbidden skin or bodygroups were replaced',
		[ 'SSB.LastValue' ] = 'The last allowed value can\'t be forbidden',
	},
	ru = {
		[ 'SSB.Title' ] = 'Чёрный список скинов',
		[ 'SSB.Search' ] = 'Поиск...',
		[ 'SSB.Name' ] = 'Название',
		[ 'SSB.Help' ] = 'ЛКМ выбирает модель и открывает её скины и бадигруппы посередине, ПКМ переключает модель. Модели цвета выключенного переключателя запрещены. Игроку с запрещённой моделью или значением ставится случайное разрешённое, поэтому хотя бы одна модель и одно значение каждой группы всегда остаются разрешёнными.',
		[ 'SSB.Enable' ] = 'Включить чёрный список',
		[ 'SSB.SupressAdmin' ] = 'Не проверять админов',
		[ 'SSB.SupressSuperadmin' ] = 'Не проверять суперадминов',
		[ 'SSB.ManagedByAdminMod' ] = 'Обход проверки настраивается в админ-аддоне',
		[ 'SSB.Replaced' ] = 'Этот скин запрещён, он был заменён',
		[ 'SSB.NoAccess' ] = 'У вас нет доступа к этому меню',
		[ 'SSB.LastAllowed' ] = 'Последнюю разрешённую модель нельзя запретить',
		[ 'SSB.Allowed' ] = 'Разрешено',
		[ 'SSB.Skin' ] = 'Скин',
		[ 'SSB.SelectModel' ] = 'Выберите модель ЛКМ, чтобы увидеть её скины и бадигруппы',
		[ 'SSB.NoBodygroups' ] = 'У модели нет скинов и бадигрупп на выбор',
		[ 'SSB.BodygroupsReplaced' ] = 'Запрещённые скин или бадигруппы были заменены',
		[ 'SSB.LastValue' ] = 'Последнее разрешённое значение нельзя запретить',
	},
	uk = {
		[ 'SSB.Title' ] = 'Чорний список скінів',
		[ 'SSB.Search' ] = 'Пошук...',
		[ 'SSB.Name' ] = 'Назва',
		[ 'SSB.Help' ] = 'ЛКМ вибирає модель і відкриває її скіни та бодігрупи посередині, ПКМ перемикає модель. Моделі кольору вимкненого перемикача заборонені. Гравцю із забороненою моделлю чи значенням ставиться випадкове дозволене, тому хоча б одна модель і одне значення кожної групи завжди залишаються дозволеними.',
		[ 'SSB.Enable' ] = 'Увімкнути чорний список',
		[ 'SSB.SupressAdmin' ] = 'Не перевіряти адмінів',
		[ 'SSB.SupressSuperadmin' ] = 'Не перевіряти суперадмінів',
		[ 'SSB.ManagedByAdminMod' ] = 'Обхід перевірки налаштовується в адмін-аддоні',
		[ 'SSB.Replaced' ] = 'Цей скін заборонено, його було замінено',
		[ 'SSB.NoAccess' ] = 'У вас немає доступу до цього меню',
		[ 'SSB.LastAllowed' ] = 'Останню дозволену модель не можна заборонити',
		[ 'SSB.Allowed' ] = 'Дозволено',
		[ 'SSB.Skin' ] = 'Скін',
		[ 'SSB.SelectModel' ] = 'Виберіть модель ЛКМ, щоб побачити її скіни та бодігрупи',
		[ 'SSB.NoBodygroups' ] = 'У моделі немає скінів і бодігруп на вибір',
		[ 'SSB.BodygroupsReplaced' ] = 'Заборонені скін або бодігрупи було замінено',
		[ 'SSB.LastValue' ] = 'Останнє дозволене значення не можна заборонити',
	},
}

for lang, phrases in pairs( PHRASES ) do

	for key, phrase in pairs( phrases ) do
		TeraLib.lang.Add( lang, key, phrase )
	end

end
