
-- Ukrainian phrases of the TeraLib Wiki pages of the addon

local PHRASES = {
	-- Page usage
	[ 'SSB.Wiki.Section' ] = 'Чорний список скінів',
	[ 'SSB.Wiki.Usage.Title' ] = 'Як це працює',
	[ 'SSB.Wiki.Usage.Text1' ] = 'Сервер забороняє деякі моделі гравців, скіни та бадигрупи. Гравцю із забороненою моделлю ставиться випадкова дозволена, заборонені значення скіна й бадигруп замінюються випадковими дозволеними, а гравець отримує сповіщення. Селектори моделей на TeraLib приховують заборонене.',
	[ 'SSB.Wiki.Usage.Heading1' ] = 'Для адмінів',
	[ 'SSB.Wiki.Usage.Text2' ] = 'Сторінку «Чорний список скінів» у налаштуваннях TeraLib бачать гравці з доступом (її відкриває команда simple_skin_blacklist_menu).',
	[ 'SSB.Wiki.Usage.Column1' ] = 'Дія',
	[ 'SSB.Wiki.Usage.Column2' ] = 'Результат',
	[ 'SSB.Wiki.Usage.Cell1' ] = 'ЛКМ по моделі',
	[ 'SSB.Wiki.Usage.Cell2' ] = 'Вибирає її для панелі посередині',
	[ 'SSB.Wiki.Usage.Cell3' ] = 'ПКМ по моделі',
	[ 'SSB.Wiki.Usage.Cell4' ] = 'Забороняє або дозволяє її',
	[ 'SSB.Wiki.Usage.Cell5' ] = 'Перемикач у панелі посередині',
	[ 'SSB.Wiki.Usage.Cell6' ] = 'Забороняє або дозволяє значення скіна чи бадигрупи',
	[ 'SSB.Wiki.Usage.Note1' ] = 'Хоча б одна модель і одне значення кожної групи завжди залишаються дозволеними: заборонене має бути на що замінити.',
	[ 'SSB.Wiki.Usage.Column3' ] = 'Привілей або convar',
	[ 'SSB.Wiki.Usage.Column4' ] = 'Дає',
	[ 'SSB.Wiki.Usage.Cell7' ] = 'Меню, за замовчуванням суперадміни',
	[ 'SSB.Wiki.Usage.Cell8' ] = 'Обхід перевірки, за замовчуванням адміни',
	[ 'SSB.Wiki.Usage.Cell9' ] = 'Вмикає чорний список',
	[ 'SSB.Wiki.Usage.Cell10' ] = 'Без CAMI: адміни не перевіряються',
	[ 'SSB.Wiki.Usage.Cell11' ] = 'Без CAMI: суперадміни не перевіряються',

	-- Page api
	[ 'SSB.Wiki.Api.Title' ] = 'Клієнтський API',
	[ 'SSB.Wiki.Api.Text1' ] = 'Інші аддони, наприклад селектори моделей, можуть дізнатися, що може використовувати локальний гравець. Обидві функції враховують вимкнений чорний список і гравців, які обходять перевірку.',
	[ 'SSB.Wiki.Api.Note1' ] = 'Приховування — лише зручність: сервер однаково перевіряє справжню модель.',
}

for key, phrase in pairs( PHRASES ) do
	TeraLib.lang.Add( 'uk', key, phrase )
end
