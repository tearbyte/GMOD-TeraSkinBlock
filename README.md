
# Simple Skin Blacklist

[Русская версия](README.ru.md)

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
        └── teralib_warning.lua          window shown without TeraLib
```
