
-- Russian phrases of the TeraLib Wiki pages of the addon

local PHRASES = {
	-- Page usage
	[ 'SSB.Wiki.Section' ] = 'Чёрный список скинов',
	[ 'SSB.Wiki.Usage.Title' ] = 'Как это работает',
	[ 'SSB.Wiki.Usage.Text1' ] = 'Сервер запрещает некоторые модели игроков, скины и бадигруппы. Игроку с запрещённой моделью ставится случайная разрешённая, запрещённые значения скина и бадигрупп заменяются случайными разрешёнными, а игрок получает уведомление. Селекторы моделей на TeraLib скрывают запрещённое.',
	[ 'SSB.Wiki.Usage.Heading1' ] = 'Для админов',
	[ 'SSB.Wiki.Usage.Text2' ] = 'Страница «Чёрный список скинов» в настройках TeraLib видна игрокам с доступом (её открывает команда simple_skin_blacklist_menu).',
	[ 'SSB.Wiki.Usage.Column1' ] = 'Действие',
	[ 'SSB.Wiki.Usage.Column2' ] = 'Результат',
	[ 'SSB.Wiki.Usage.Cell1' ] = 'ЛКМ по модели',
	[ 'SSB.Wiki.Usage.Cell2' ] = 'Выбирает её для панели посередине',
	[ 'SSB.Wiki.Usage.Cell3' ] = 'ПКМ по модели',
	[ 'SSB.Wiki.Usage.Cell4' ] = 'Запрещает или разрешает её',
	[ 'SSB.Wiki.Usage.Cell5' ] = 'Переключатель в панели посередине',
	[ 'SSB.Wiki.Usage.Cell6' ] = 'Запрещает или разрешает значение скина или бадигруппы',
	[ 'SSB.Wiki.Usage.Note1' ] = 'Хотя бы одна модель и одно значение каждой группы всегда остаются разрешёнными: запрещённое должно быть на что заменить.',
	[ 'SSB.Wiki.Usage.Column3' ] = 'Привилегия или convar',
	[ 'SSB.Wiki.Usage.Column4' ] = 'Даёт',
	[ 'SSB.Wiki.Usage.Cell7' ] = 'Меню, по умолчанию суперадмины',
	[ 'SSB.Wiki.Usage.Cell8' ] = 'Обход проверки, по умолчанию админы',
	[ 'SSB.Wiki.Usage.Cell9' ] = 'Включает чёрный список',
	[ 'SSB.Wiki.Usage.Cell10' ] = 'Без CAMI: админы не проверяются',
	[ 'SSB.Wiki.Usage.Cell11' ] = 'Без CAMI: суперадмины не проверяются',

	-- Page api
	[ 'SSB.Wiki.Api.Title' ] = 'Клиентский API',
	[ 'SSB.Wiki.Api.Text1' ] = 'Другие аддоны, например селекторы моделей, могут узнать, что может использовать локальный игрок. Обе функции учитывают выключенный чёрный список и игроков, которые обходят проверку.',
	[ 'SSB.Wiki.Api.Note1' ] = 'Скрытие — только удобство: сервер всё равно проверяет настоящую модель.',
}

for key, phrase in pairs( PHRASES ) do
	TeraLib.lang.Add( 'ru', key, phrase )
end
