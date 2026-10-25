
# Simple Skin Blacklist

[Русская версия](#русская-версия)

A Garry's Mod addon that stops players from using chosen player models, skins and bodygroups. Everything is checked on the server: a player with a forbidden model gets a random allowed one, forbidden skin and bodygroup values are replaced with random allowed values.

Built on [TeraLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464).

## Features

- **Model blacklist.** Every player model that isn't blacklisted is allowed and can replace a blacklisted one. The last allowed model can't be blacklisted.
- **Skins and bodygroups.** Any value of the skin or a bodygroup can be forbidden per model. At least one value of each group always stays allowed.
- **Server-side check.** The model is checked right after spawning and changing the team (DarkRP jobs included), and once a second for models set by other addons. Nothing depends on the client.
- **Menu** in the TeraLib settings window, shown only to players with access.
- **CAMI** privileges if an admin addon provides CAMI (ULX, SAM, ServerGuard…), convars otherwise.
- **Shared database:** the data is stored in `TeraLib.db:GetDefaultDB()`, a shared MySQL if the server registers one, the built-in SQLite otherwise.
- **Player model selectors** can hide forbidden models and values through the client API, TeraLib Player Model Selector does it.
- Languages: English, Russian, Ukrainian.

## Installation

1. Install [TeraLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464).
2. Subscribe on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3006392625) or drop this folder into `garrysmod/addons/`.

Without TeraLib the addon is disabled: the server prints an error and every joining player sees a window about it 10 seconds after joining.

On a dedicated server clients download the addon from the Workshop automatically (`resource.AddWorkshop`). On a listen server it's skipped, so the Workshop copy doesn't replace a local one of the host.

## Usage

Open the TeraLib settings (`teralib_settings`, or the icon in the context menu) and choose **Skin blacklist**. The old command `simple_skin_blacklist_menu` opens the same page.

- **Left click** on a model selects it: the middle panel shows its **Allowed** switch and a switch for every skin and bodygroup value, the preview and the path are on the right.
- **Right click** on a model toggles it.
- Hovering a value shows it on the preview.

Blacklisted models are colored like a disabled switch of the theme.

## Access

| Privilege | Default | Gives |
|---|---|---|
| `simple_skin_blacklist_menu` | superadmin | Opening the menu and editing the lists |
| `simple_skin_blacklist_suppress_check` | admin | Using forbidden models and values |

The privileges are registered in CAMI on `InitPostEntity` if an admin addon provides it. Without CAMI the menu is for superadmins and skipping the check is set by the convars below.

## Convars

| Convar | Default | Description |
|---|---|---|
| `simple_skin_blacklist_enable` | `1` | Enable the blacklist |
| `simple_skin_blacklist_supress_admin` | `1` | Admins skip the check (without CAMI) |
| `simple_skin_blacklist_supress_superadmin` | `1` | Superadmins skip the check (without CAMI) |

With CAMI the menu shows "Skipping the check is configured in the admin addon" instead of the last two switches.

## Data

Two tables in the database of `TeraLib.db:GetDefaultDB()`:

- `simple_skin_blacklist` — blacklisted model paths;
- `simple_skin_blacklist_bodygroups` — a row per forbidden value: model path, bodygroup name (`$skin` for the skin), value.

The `data/simple_skin_blacklist.json` of the old versions is migrated once on the first start and renamed to `simple_skin_blacklist_old.json`.

## Client API

For other addons, for example player model selectors. Both functions take the disabled blacklist and the players skipping the check into account.

```lua
SSB.IsModelAllowed( path ) -- boolean
SSB.IsValueAllowed( path, group, value ) -- group: bodygroup name or SSB.SKIN_GROUP

-- The blacklist, the forbidden values or the access changed
hook.Add( 'SSB.Updated', 'MyAddon.Refresh', function() end )
```

## Limitations

- Addons that change the look only on the clients (PAC3, Outfitter) aren't covered: the server checks the real model of the player.
- A model set by another addon outside spawning and team changes stays up to a second, until the polling catches it.

## Project structure

```
lua/
├── autorun/simple_skin_blacklist.lua    loader
└── simple_skin_blacklist/
    ├── init.lua, lang.lua               shared: constants, convars, sync format, phrases
    ├── server/
    │   ├── access.lua                   CAMI privileges and the fallback
    │   ├── data.lua                     database, lists, migration
    │   ├── check.lua                    model, skin and bodygroup check
    │   └── net.lua                      sync, menu requests, rate limit
    └── client/
        ├── api.lua                      API for other addons
        ├── menu.lua                     TeraLib settings page
        ├── net.lua
        ├── teralib_warning.lua          window shown without TeraLib
        ├── wiki/                        phrases of the wiki pages, a file per language
        └── wiki.lua                     pages in TeraLib Wiki, if it's installed
```

---

# Русская версия

Аддон для Garry's Mod, который не даёт игрокам использовать выбранные модели, скины и бадигруппы. Всё проверяется на сервере: игроку с запрещённой моделью ставится случайная разрешённая, запрещённые значения скина и бадигрупп заменяются случайными разрешёнными.

Сделан на [TeraLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464).

## Возможности

- **Чёрный список моделей.** Любая незапрещённая модель разрешена и может стать заменой. Последнюю разрешённую модель запретить нельзя.
- **Скины и бадигруппы.** Для каждой модели можно запретить любое значение скина или бадигруппы. Хотя бы одно значение каждой группы всегда остаётся разрешённым.
- **Проверка на сервере.** Модель проверяется сразу после спавна и смены команды (включая профессии DarkRP), а модели, выставленные другими аддонами, — раз в секунду. От клиента ничего не зависит.
- **Меню** в окне настроек TeraLib, видно только игрокам с доступом.
- **CAMI-привилегии**, если CAMI предоставляет админ-аддон (ULX, SAM, ServerGuard…), иначе — convar'ы.
- **Общая БД:** данные хранятся в `TeraLib.db:GetDefaultDB()` — общий MySQL, если сервер его зарегистрировал, иначе встроенный SQLite.
- **Селекторы моделей** могут скрывать запрещённые модели и значения через клиентский API — так делает TeraLib Player Model Selector.
- Языки: английский, русский, украинский.

## Установка

1. Установите [TeraLib](https://steamcommunity.com/sharedfiles/filedetails/?id=3013984464).
2. Подпишитесь в [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3006392625) или положите эту папку в `garrysmod/addons/`.

Без TeraLib аддон отключён: сервер пишет ошибку в консоль, а каждый игрок через 10 секунд после входа видит окно об этом.

На выделенном сервере клиенты скачивают аддон из Workshop автоматически (`resource.AddWorkshop`). На listen-сервере это пропускается, чтобы Workshop-копия не подменяла локальную у хоста.

## Использование

Откройте настройки TeraLib (`teralib_settings` или иконка в контекстном меню) и выберите **Чёрный список скинов**. Старая команда `simple_skin_blacklist_menu` открывает ту же страницу.

- **ЛКМ** по модели выбирает её: в панели посередине — переключатель **Разрешено** и переключатель для каждого значения скина и бадигрупп, справа — превью и путь.
- **ПКМ** по модели переключает её.
- Наведение на значение показывает его на превью.

Запрещённые модели окрашены цветом выключенного переключателя темы.

## Доступ

| Привилегия | По умолчанию | Даёт |
|---|---|---|
| `simple_skin_blacklist_menu` | superadmin | Открытие меню и редактирование списков |
| `simple_skin_blacklist_suppress_check` | admin | Использование запрещённых моделей и значений |

Привилегии регистрируются в CAMI на `InitPostEntity`, если его предоставляет админ-аддон. Без CAMI меню доступно суперадминам, а обход проверки задают convar'ы ниже.

## Convar'ы

| Convar | По умолчанию | Описание |
|---|---|---|
| `simple_skin_blacklist_enable` | `1` | Включить чёрный список |
| `simple_skin_blacklist_supress_admin` | `1` | Админы не проверяются (без CAMI) |
| `simple_skin_blacklist_supress_superadmin` | `1` | Суперадмины не проверяются (без CAMI) |

С CAMI вместо двух последних переключателей меню показывает «Обход проверки настраивается в админ-аддоне».

## Данные

Две таблицы в БД `TeraLib.db:GetDefaultDB()`:

- `simple_skin_blacklist` — пути запрещённых моделей;
- `simple_skin_blacklist_bodygroups` — строка на каждое запрещённое значение: путь модели, имя бадигруппы (`$skin` для скина), значение.

`data/simple_skin_blacklist.json` старых версий переносится один раз при первом запуске и переименовывается в `simple_skin_blacklist_old.json`.

## Клиентский API

Для других аддонов, например селекторов моделей. Обе функции учитывают выключенный чёрный список и игроков, которые обходят проверку.

```lua
SSB.IsModelAllowed( path ) -- boolean
SSB.IsValueAllowed( path, group, value ) -- group: имя бадигруппы или SSB.SKIN_GROUP

-- Изменились чёрный список, запрещённые значения или доступ
hook.Add( 'SSB.Updated', 'MyAddon.Refresh', function() end )
```

## Ограничения

- Аддоны, меняющие внешний вид только на клиентах (PAC3, Outfitter), не учитываются: сервер проверяет настоящую модель игрока.
- Модель, выставленная другим аддоном не при спавне и не при смене команды, держится до секунды, пока её не поймает периодическая проверка.

## Структура

```
lua/
├── autorun/simple_skin_blacklist.lua    загрузчик
└── simple_skin_blacklist/
    ├── init.lua, lang.lua               общие: константы, convar'ы, формат синхронизации, фразы
    ├── server/
    │   ├── access.lua                   CAMI-привилегии и запасной вариант
    │   ├── data.lua                     БД, списки, перенос старых данных
    │   ├── check.lua                    проверка модели, скина и бадигрупп
    │   └── net.lua                      синхронизация, запросы меню, ограничение частоты
    └── client/
        ├── api.lua                      API для других аддонов
        ├── menu.lua                     страница в настройках TeraLib
        ├── net.lua
        ├── teralib_warning.lua          окно, если TeraLib нет
        ├── wiki/                        фразы страниц вики, по файлу на язык
        └── wiki.lua                     страницы в TeraLib Wiki, если она установлена
```
