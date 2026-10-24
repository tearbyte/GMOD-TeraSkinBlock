
local PAGE_PADDING = 5
local ROW_HEIGHT = 24
local HELP_LINES = 3
local SWITCH_PADDING = 4
local SWITCH_TYPE = 5 -- Round knob
local ALIGNMENT_LEFT = 4
local PREVIEW_WIDTH = 300
local PREVIEW_FOV = 30
local PREVIEW_MARGIN = 1.1 -- Free space around the model
local PREVIEW_ANGLE = Angle( 0, 25, 0 ) -- Three-quarter view
local HALF = 0.5
local NAME_COLUMN_WIDTH = 160
local CATEGORY_ICON = 'icon16/user_delete.png'
local MENU_COMMAND = 'simple_skin_blacklist_menu'

local menuPanel, modelList, preview
-- Settings window the category was added to: on GUI reload the old window is still valid until the end of the frame
local menuSettings
-- Scaled sizes, recalculated on every build: the GUI is rebuilt on resolution change
local pad, rowHeight

local function paintBackground( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, TeraLib.vgui.appearance.background )
end

-- Blacklisted rows are colored like a disabled switch, allowed ones keep the list colors. The selection isn't shown
local function paintLine( line, w, h )

	local color = line.m_bAlt and modelList.altLineColor or modelList.lineColor
	if SSB.blacklist[ line.modelPath ] then color = TeraLib.vgui.appearance.switchOff end

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

-- Left click toggles the model instead of selecting the row
local function onLinePressed( line, keyCode )

	if keyCode ~= MOUSE_LEFT then return end

	net.Start( SSB.NET_CHANGE )
	net.WriteString( line.modelPath )
	net.WriteBool( not SSB.blacklist[ line.modelPath ] )
	net.SendToServer()

end

-- The click toggles the model, so the preview follows the cursor
local function onLineHovered( line )
	showPreview( line.modelPath )
end

--[[
	@param filter string - lowercase substring of the name or the path, empty shows everything
]]--
local function fillModelList( filter )

	modelList:Clear()
	for name, path in SortedPairs( player_manager.AllValidModels() ) do
		if filter ~= '' and not string.find( string.lower( name .. ' ' .. path ), filter, 1, true ) then continue end

		local line = modelList:AddLine( name, path )
		-- Lowercase like the blacklist keys, cached for Paint
		line.modelPath = string.lower( path )
		line.Paint = paintLine
		line.OnMousePressed = onLinePressed
		line.OnCursorEntered = onLineHovered
	end

end

--[[
	Row with a switch bound to a convar, the whole row toggles it.
	@param parent Panel
	@param phrase string
	@param convarKey string - key in SSB.convars
]]--
local function switchRow( parent, phrase, convarKey )

	local switchPadding = TeraLib.util.ScrH( SWITCH_PADDING )

	local row = TeraLib.vgui.ColorableButton( {
		parent = parent,
		dock = TOP,
		size = { x = 0, y = rowHeight },
		dockMargin = { 0, 0, 0, pad },
		text = TeraLib.lang.GetPhrase( phrase ),
		alignment = ALIGNMENT_LEFT,
	} )

	local switch = TeraLib.vgui.Switch( {
		parent = row,
		dock = LEFT,
		dockMargin = { switchPadding, switchPadding, 0, switchPadding },
		type = SWITCH_TYPE,
		height = rowHeight - switchPadding * 2,
		active = SSB.convars[ convarKey ]:GetBool(),
		OnToggle = function( _, active )
			net.Start( SSB.NET_SET_CONVAR )
			net.WriteString( convarKey )
			net.WriteBool( active )
			net.SendToServer()
		end,
	} )

	-- Same as the style rows of the TeraLib settings: no row click sound on top of the switch one
	switch:SetMouseInputEnabled( false )
	row.DoClick = function() switch:DoClick() end
	row:SetTextInset( switch:GetWide() + switchPadding + pad, 0 )

end

local function buildMenu()

	pad = TeraLib.util.ScrW( PAGE_PADDING )
	rowHeight = TeraLib.util.ScrH( ROW_HEIGHT )

	local panel = vgui.Create( 'DPanel' )
	panel:DockPadding( pad, pad, pad, pad )
	panel.Paint = paintBackground

	-- TOP, BOTTOM and side docks have to be created before FILL ones
	switchRow( panel, 'SSB.Enable', 'enable' )

	if SSB.hasCAMI then
		TeraLib.vgui.Label( { parent = panel, dock = TOP, size = { x = 0, y = rowHeight }, dockMargin = { 0, 0, 0, pad }, text = TeraLib.lang.GetPhrase( 'SSB.ManagedByAdminMod' ) } )
	else
		switchRow( panel, 'SSB.SupressAdmin', 'supressAdmin' )
		switchRow( panel, 'SSB.SupressSuperadmin', 'supressSuperadmin' )
	end

	TeraLib.vgui.TextEntry( {
		parent = panel,
		dock = TOP,
		size = { x = 0, y = rowHeight },
		dockMargin = { 0, 0, 0, pad },
		placeholder = TeraLib.lang.GetPhrase( 'SSB.Search' ),
		OnUpdate = function( _, value ) fillModelList( string.lower( value ) ) end,
	} )

	local help = TeraLib.vgui.Label( {
		parent = panel,
		dock = BOTTOM,
		size = { x = 0, y = rowHeight * HELP_LINES },
		dockMargin = { 0, pad, 0, 0 },
		text = TeraLib.lang.GetPhrase( 'SSB.Help' ),
	} )
	help:SetWrap( true )

	preview = vgui.Create( 'DModelPanel', panel )
	preview:Dock( RIGHT )
	preview:SetWide( TeraLib.util.ScrW( PREVIEW_WIDTH ) )
	preview:DockMargin( pad, 0, 0, 0 )
	preview:SetFOV( PREVIEW_FOV )
	-- Still three-quarter view instead of the default rotation
	function preview:LayoutEntity( ent )
		ent:SetAngles( PREVIEW_ANGLE )
	end
	-- The size is known only after the layout, the camera depends on it
	preview.PerformLayout = updatePreviewCamera
	showPreview( LocalPlayer():GetModel() )

	modelList = TeraLib.vgui.ListView( {
		parent = panel,
		dock = FILL,
		columns = { { name = TeraLib.lang.GetPhrase( 'SSB.Name' ), width = NAME_COLUMN_WIDTH }, TeraLib.lang.GetPhrase( 'SSB.Path' ) },
	} )
	fillModelList( '' )

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

-- Old command of the standalone menu, now opens the category in the TeraLib settings
concommand.Add( MENU_COMMAND, function()

	if not SSB.access then
		TeraLib.Notify( 'SSB.NoAccess', SSB.NOTIFY_ERROR )
		return
	end

	TeraLib.vgui.ShowSettings( TeraLib.lang.GetPhrase( 'SSB.Title' ) )

end )
