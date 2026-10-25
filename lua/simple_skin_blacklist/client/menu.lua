
local PAGE_PADDING = 5
local ROW_HEIGHT = 24
local HELP_LINES = 3
local HELP_ALPHA = 140
local HINT_LINES = 2
local PATH_LINES = 2
local SEARCH_GAP = 2 -- Paddings between the switches and the search
local SWITCH_PADDING = 4
local ALIGNMENT_LEFT = 4
local BODYGROUPS_WIDTH = 320
local PREVIEW_WIDTH = 300
local PREVIEW_FOV = 30
local PREVIEW_MARGIN = 1.1 -- Free space around the model
local PREVIEW_ANGLE = Angle( 0, 25, 0 ) -- Three-quarter view
local HALF = 0.5
local CATEGORY_ICON = 'icon16/user_delete.png'
local MENU_COMMAND = 'simple_skin_blacklist_menu'
local WIKI_BUTTON_WIDTH = 100
local WIKI_ICON = 'icon16/book_open.png'
local WIKI_SECTION = 'simple_skin_blacklist'
local WIKI_PAGE = 'usage'
local COMPANION_ICON = 'icon16/plugin_link.png'
local COMPANION_URL = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3827098662' -- TeraModel

local menuPanel, modelList, preview, pathLabel, bodygroupsPanel
-- Settings window the category was added to: on GUI reload the old window is still valid until the end of the frame
local menuSettings
-- Scaled sizes, recalculated on every build: the GUI is rebuilt on resolution change
local pad, rowHeight
-- Lowercase path of the model shown in the bodygroups panel
local selectedPath
-- Switches of the bodygroups panel, updated in place on new data, so the scroll position stays
local allowedSwitch
local valueSwitches = {}

local function paintBackground( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, TeraLib.vgui.appearance.background )
end

-- The selected row is active, blacklisted ones are colored like a disabled switch, the rest keep the list colors
local function paintLine( line, w, h )

	local app = TeraLib.vgui.appearance
	local color = line.m_bAlt and modelList.altLineColor or modelList.lineColor
	if SSB.blacklist[ line.modelPath ] then color = app.switchOff end
	if line.modelPath == selectedPath then color = app.active end
	if line:IsHovered() then color = TeraLib.util.HoverColor( color ) end

	draw.RoundedBox( 0, 0, 0, w, h, color )

end

--[[
	Move the camera so the whole model height fits the panel.
	The FOV is horizontal, so the vertical one of the tall panel depends on its aspect ratio.
]]--
local function updatePreviewCamera()

	local w, h = preview:GetSize()
	if h == 0 or not preview.modelCenter then return end

	local distance = preview.modelHalfHeight * PREVIEW_MARGIN * ( w / h ) / math.tan( math.rad( PREVIEW_FOV * HALF ) )
	preview:SetLookAt( preview.modelCenter )
	preview:SetCamPos( preview.modelCenter + Vector( distance, 0, 0 ) )

end

local function showPreview( path )

	preview:SetModel( path )

	local mins, maxs = preview.Entity:GetRenderBounds()
	preview.modelCenter = ( mins + maxs ) * HALF
	preview.modelHalfHeight = ( maxs.z - mins.z ) * HALF
	updatePreviewCamera()

end

local function sendBlacklisted( path, isBlacklisted )

	net.Start( SSB.NET_CHANGE )
	net.WriteString( path )
	net.WriteBool( isBlacklisted )
	net.SendToServer()

end

local function sendBodygroupAllowed( group, value, isAllowed )

	net.Start( SSB.NET_CHANGE_BODYGROUP )
	net.WriteString( selectedPath )
	net.WriteString( group )
	net.WriteUInt( value, SSB.VALUE_BITS )
	net.WriteBool( isAllowed )
	net.SendToServer()

end

-- Forbidden values of a group of the selected model: { [ value ] = true }
local function getForbidden( group )

	local groups = SSB.forbidden[ selectedPath ]
	return groups and groups[ group ] or {}

end

--[[
	Row with a switch, the whole row toggles it.
	@param parent Panel
	@param text string
	@param active boolean
	@param onToggle function( switch, active )
	@return Panel, Panel - the row and the switch
]]--
local function switchRow( parent, text, active, onToggle )

	local switchPadding = TeraLib.util.ScrH( SWITCH_PADDING )

	local row = TeraLib.vgui.ColorableButton( {
		parent = parent,
		dock = TOP,
		size = { x = 0, y = rowHeight },
		dockMargin = { 0, 0, 0, pad },
		text = text,
		alignment = ALIGNMENT_LEFT,
	} )

	local switch = TeraLib.vgui.Switch( {
		parent = row,
		dock = LEFT,
		dockMargin = { switchPadding, switchPadding, 0, switchPadding },
		height = rowHeight - switchPadding * 2,
		active = active,
		OnToggle = onToggle,
	} )

	-- Same as the style rows of the TeraLib settings: no row click sound on top of the switch one
	switch:SetMouseInputEnabled( false )
	row.DoClick = function() switch:DoClick() end
	row:SetTextInset( switch:GetWide() + switchPadding + pad, 0 )

	return row, switch

end

local function convarRow( parent, phrase, convarKey )

	switchRow( parent, TeraLib.lang.GetPhrase( phrase ), SSB.convars[ convarKey ]:GetBool(), function( _, active )
		net.Start( SSB.NET_SET_CONVAR )
		net.WriteString( convarKey )
		net.WriteBool( active )
		net.SendToServer()
	end )

end

local function hintLabel( parent, phrase )

	local label = TeraLib.vgui.Label( { parent = parent, dock = TOP, size = { x = 0, y = rowHeight * HINT_LINES }, text = TeraLib.lang.GetPhrase( phrase ) } )
	label:SetWrap( true )

	return label

end

-- Groups of the selected model with something to choose from: the skin and the bodygroups
local function getModelGroups()

	local ent = preview.Entity
	local groups = {}

	if ent:SkinCount() > 1 then
		groups[ 1 ] = {
			key = SSB.SKIN_GROUP,
			title = TeraLib.lang.GetPhrase( 'SSB.Skin' ),
			count = ent:SkinCount(),
			apply = function( value ) ent:SetSkin( value ) end,
		}
	end

	for _, bodygroup in ipairs( ent:GetBodyGroups() ) do
		if bodygroup.num < 2 then continue end

		groups[ #groups + 1 ] = {
			key = bodygroup.name,
			title = bodygroup.name,
			count = bodygroup.num,
			names = bodygroup.submodels,
			apply = function( value ) ent:SetBodygroup( bodygroup.id, value ) end,
		}
	end

	return groups

end

local function onValueToggled( switch, active )

	local group = switch.group

	-- At least one value of each group stays allowed
	if not active and group.count - table.Count( getForbidden( group.key ) ) <= 1 then
		switch.active = true
		TeraLib.Notify( 'SSB.LastValue', SSB.NOTIFY_ERROR )
		return
	end

	sendBodygroupAllowed( group.key, switch.value, active )

end

local function rebuildBodygroups()

	bodygroupsPanel:Clear()
	allowedSwitch = nil
	valueSwitches = {}

	if not selectedPath then
		bodygroupsPanel:AddItem( hintLabel( bodygroupsPanel, 'SSB.SelectModel' ) )
		return
	end

	local allowedRow
	allowedRow, allowedSwitch = switchRow( bodygroupsPanel, TeraLib.lang.GetPhrase( 'SSB.Allowed' ), not SSB.blacklist[ selectedPath ], function( _, active )
		sendBlacklisted( selectedPath, not active )
	end )
	bodygroupsPanel:AddItem( allowedRow )

	local groups = getModelGroups()
	if #groups == 0 then
		bodygroupsPanel:AddItem( hintLabel( bodygroupsPanel, 'SSB.NoBodygroups' ) )
		return
	end

	for _, group in ipairs( groups ) do
		bodygroupsPanel:AddItem( TeraLib.vgui.Label( { parent = bodygroupsPanel, dock = TOP, size = { x = 0, y = rowHeight }, text = group.title } ) )

		local forbidden = getForbidden( group.key )
		for value = 0, group.count - 1 do
			local name = group.names and group.names[ value ]
			local text = name and name ~= '' and value .. ' - ' .. string.StripExtension( name ) or tostring( value )

			local row, switch = switchRow( bodygroupsPanel, text, not forbidden[ value ], onValueToggled )
			switch.group = group
			switch.value = value

			-- Hovering a value shows it on the preview
			local onCursorEntered = row.OnCursorEntered
			function row:OnCursorEntered()
				if onCursorEntered then onCursorEntered( self ) end
				group.apply( value )
			end

			bodygroupsPanel:AddItem( row )
			valueSwitches[ #valueSwitches + 1 ] = switch
		end
	end

end

local function selectModel( path )

	selectedPath = path
	showPreview( path )
	pathLabel:SetText( path )
	rebuildBodygroups()

end

-- Left click selects the model for the bodygroups panel, right click toggles it
local function onLinePressed( line, keyCode )

	if keyCode == MOUSE_LEFT then
		selectModel( line.modelPath )
		return
	end

	if keyCode ~= MOUSE_RIGHT then return end
	sendBlacklisted( line.modelPath, not SSB.blacklist[ line.modelPath ] )

end

--[[
	@param filter string - lowercase substring of the name or the path, empty shows everything
]]--
local function fillModelList( filter )

	modelList:Clear()
	for name, path in SortedPairs( player_manager.AllValidModels() ) do
		if filter ~= '' and not string.find( string.lower( name .. ' ' .. path ), filter, 1, true ) then continue end

		local line = modelList:AddLine( name )
		-- Normalized like the blacklist keys, cached for Paint
		line.modelPath = SSB.NormalizePath( path )
		line.Paint = paintLine
		line.OnMousePressed = onLinePressed
	end

end

local function buildMenu()

	pad = TeraLib.util.ScrW( PAGE_PADDING )
	rowHeight = TeraLib.util.ScrH( ROW_HEIGHT )

	local app = TeraLib.vgui.appearance

	local panel = vgui.Create( 'DPanel' )
	panel:DockPadding( pad, pad, pad, pad )
	panel.Paint = paintBackground

	-- TOP, BOTTOM and side docks have to be created before FILL ones
	convarRow( panel, 'SSB.Enable', 'enable' )

	if SSB.hasCAMI then
		TeraLib.vgui.Label( { parent = panel, dock = TOP, size = { x = 0, y = rowHeight }, dockMargin = { 0, 0, 0, pad }, text = TeraLib.lang.GetPhrase( 'SSB.ManagedByAdminMod' ) } )
	else
		convarRow( panel, 'SSB.SupressAdmin', 'supressAdmin' )
		convarRow( panel, 'SSB.SupressSuperadmin', 'supressSuperadmin' )
	end

	local searchRow = vgui.Create( 'DPanel', panel )
	searchRow:Dock( TOP )
	searchRow:SetTall( rowHeight )
	searchRow:DockMargin( 0, pad * SEARCH_GAP, 0, pad )
	searchRow:SetPaintBackground( false )

	-- The wiki is an optional addon
	if TeraLibWiki then
		TeraLib.vgui.ColorableButton( {
			parent = searchRow,
			dock = RIGHT,
			size = { x = TeraLib.util.ScrW( WIKI_BUTTON_WIDTH ), y = 0 },
			dockMargin = { pad, 0, 0, 0 },
			text = TeraLib.lang.GetPhrase( 'SSB.Wiki' ),
			icon = WIKI_ICON,
			DoClick = function() TeraLibWiki.Open( WIKI_SECTION, WIKI_PAGE ) end,
		} )
	end

	TeraLib.vgui.TextEntry( {
		parent = searchRow,
		dock = FILL,
		placeholder = TeraLib.lang.GetPhrase( 'SSB.Search' ),
		OnUpdate = function( _, value ) fillModelList( string.lower( value ) ) end,
	} )

	-- Only while the companion addon isn't installed
	if not TeraLibPMS then
		TeraLib.vgui.ColorableButton( {
			parent = panel,
			dock = BOTTOM,
			size = { x = 0, y = rowHeight },
			dockMargin = { 0, pad, 0, 0 },
			text = TeraLib.lang.Format( { 'SSB.WorksWith', { 'SSB.Selector' } } ),
			icon = COMPANION_ICON,
			DoClick = function() gui.OpenURL( COMPANION_URL ) end,
		} )
	end

	local help = TeraLib.vgui.Label( {
		parent = panel,
		dock = BOTTOM,
		size = { x = 0, y = rowHeight * HELP_LINES },
		dockMargin = { 0, pad, 0, 0 },
		text = TeraLib.lang.GetPhrase( 'SSB.Help' ),
	} )
	help:SetWrap( true )
	-- Dimmed, so it doesn't compete with the list
	help:SetTextColor( ColorAlpha( app.text, HELP_ALPHA ) )

	-- Right to left: the preview with the path, then the bodygroups panel
	local previewColumn = vgui.Create( 'DPanel', panel )
	previewColumn:Dock( RIGHT )
	previewColumn:SetWide( TeraLib.util.ScrW( PREVIEW_WIDTH ) )
	previewColumn:DockMargin( pad, 0, 0, 0 )
	previewColumn:SetPaintBackground( false )

	pathLabel = TeraLib.vgui.Label( { parent = previewColumn, dock = BOTTOM, size = { x = 0, y = rowHeight * PATH_LINES } } )
	pathLabel:SetWrap( true )

	preview = vgui.Create( 'DModelPanel', previewColumn )
	preview:Dock( FILL )
	preview:SetFOV( PREVIEW_FOV )
	-- Still three-quarter view instead of the default rotation
	function preview:LayoutEntity( ent )
		ent:SetAngles( PREVIEW_ANGLE )
	end
	-- The size is known only after the layout, the camera depends on it
	preview.PerformLayout = updatePreviewCamera

	bodygroupsPanel = TeraLib.vgui.ScrollPanel( {
		parent = panel,
		dock = RIGHT,
		size = { x = TeraLib.util.ScrW( BODYGROUPS_WIDTH ), y = 0 },
		dockMargin = { pad, 0, 0, 0 },
	} )

	modelList = TeraLib.vgui.ListView( {
		parent = panel,
		dock = FILL,
		columns = { TeraLib.lang.GetPhrase( 'SSB.Name' ) },
	} )
	fillModelList( '' )

	selectModel( SSB.NormalizePath( LocalPlayer():GetModel() ) )

	return panel

end

local function addCategory()

	if not SSB.access or menuSettings == TeraLib.vgui.settings then return end

	menuSettings = TeraLib.vgui.settings
	menuPanel = buildMenu()
	TeraLib.vgui.settings:AddCategory( TeraLib.lang.GetPhrase( 'SSB.Title' ), menuPanel, CATEGORY_ICON )

end

TeraLib.OnReady( 'vgui', 'SSB.Menu', addCategory )

-- Called when the server sends the menu access
function SSB.UpdateAccess()

	if not SSB.access then
		-- TeraLib can't remove a category, the settings window is rebuilt without it
		if IsValid( menuPanel ) then hook.Run( 'TeraLib.vgui.Reload' ) end
		return
	end

	if TeraLib.IsReady( 'vgui' ) then addCategory() end

end

-- Called when the server sends new data, the list rows read it on their own when painted
function SSB.RefreshMenu()

	if not IsValid( allowedSwitch ) then return end

	allowedSwitch.active = not SSB.blacklist[ selectedPath ]
	for _, switch in ipairs( valueSwitches ) do
		switch.active = not getForbidden( switch.group.key )[ switch.value ]
	end

end

-- Old command of the standalone menu, now opens the category in the TeraLib settings
concommand.Add( MENU_COMMAND, function()

	if not SSB.access then
		TeraLib.Notify( 'SSB.NoAccess', SSB.NOTIFY_ERROR )
		return
	end

	TeraLib.vgui.ShowSettings( TeraLib.lang.GetPhrase( 'SSB.Title' ) )

end )
