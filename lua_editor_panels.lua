// This file contains the GUI definitions needed to show the lua editor panel.
// 

local function FormatName( str )
	return str:gsub( "[^%/%w%_%. ]", "" )
end

local PANEL = {}
do
	AccessorFunc( PANEL, "m_pPropertySheet", "PropertySheet" ) // Creates Get* & Set* accessors
	AccessorFunc( PANEL, "Name", 			 "Name" )
	Derma_Hook( PANEL, "Paint", "Paint", "Tab" ) // Binds the "Paint" function to some built-in "Tab" paint algorithm.
	
	function PANEL:Init()
		self:SetMouseInputEnabled( true )
		self:SetContentAlignment( 7 )
		self:SetTextInset( 0, 4 )
		self.UpdateColours = DTab.UpdateColours
		local OnStartDragging = self.OnStartDragging
		
		self.OnStartDragging = function( self )
			self:DoClick()
			OnStartDragging( self )
		end
		
		self.Menu = DermaMenu()
		self.Menu:SetDeleteSelf( false )
		self.Menu:Hide()
		self.Menu:SetParent( self )
		
		local SubMenu, SubMenuButton = self.Menu:AddSubMenu( "Close", function() self:Close() end )
		SubMenu:SetDeleteSelf( false )
		SubMenu:Hide()
		SubMenu:SetParent( self.SubMenuButton )
		SubMenuButton:SetIcon( "icon16/cross.png" )
		
		SubMenu:AddOption( "Remove file", function()

			Derma_Query( // This pops up a confirmation GUI to the user to make sure he doesn't delete the file on accident.
				"This action will delete the file. Are you sure?",
				"Confirmation",
				"Delete", function()
					self:GetPropertySheet():GetEditor():DeleteFile( self.Name )
					self:Close()
				end,
				"Cancel", function()end )
			
		end ):SetIcon( "icon16/delete.png" )
		
		self.Menu:AddOption( "Change session", function() self:DoDoubleClick() end ):SetIcon( "icon16/comment_edit.png" )
	end
	
	function PANEL:Setup( name, pPropertySheet )
		self:SetText( name )
		self:SetPropertySheet( pPropertySheet )
		self.Name = FormatName( name )
	end
	
	function PANEL:Close()
		self:GetPropertySheet():GetEditor():RemoveSession( self.Name )
	end
	
	function PANEL:IsActive()
		return self:GetPropertySheet() and self:GetPropertySheet():GetActiveTab() == self or false
	end
	
	function PANEL:DoClick()
		self:GetPropertySheet():SetActiveTab( self )
	end
	
	function PANEL:DoDoubleClick() -- Edit name!
		local TextEdit = vgui.Create( "DTextEntry", self )
		TextEdit:Dock( FILL )
		TextEdit:DockMargin( 4, 3, 4, 8 )
		TextEdit:SetText( self:GetText() )
		TextEdit:SetFont( self:GetFont() )
		TextEdit:SetDrawLanguageID( false )
		
		TextEdit.OnTextChanged = function()
			self:SetText( TextEdit:GetText() )
			self:GetPropertySheet().tabScroller:PerformLayout()
		end
		
		TextEdit.OnLoseFocus = function()
			hook.Run( "OnTextEntryLoseFocus", TextEdit )
			
			local name = FormatName( TextEdit:GetText() )
			if name:len() < 1 then self:Close() return end
			
			self:SetName( name )
			TextEdit:Remove()
		end
		
		TextEdit.OnEnter = TextEdit.OnLoseFocus
		
		TextEdit:RequestFocus()
		TextEdit:OnGetFocus()
		TextEdit:SelectAllText( true )
	end
	
	function PANEL:DoMiddleClick()
		self:Close()
	end
	
	function PANEL:DoRightClick()
		self:DoClick()
		
		if not self.Menu then return end
		self.Menu:Open( self:LocalToScreen( 0, 20 ) )
	end
	
	function PANEL:SetName( new )
		local old = self.Name
		
		self.Name = new
		self:SetText( new )
		self:GetPropertySheet():OnTabNameChanged( old, new )
	end
	
	function PANEL:PerformLayout()
		self:SetTextInset( 10, 4 )
		
		local w, h = self:GetContentSize()
		self:SetSize( w + 10, self:IsActive() and 28 or 20 )
		
		self:ApplySchemeSettings()
	end
end
local lua_editor_TabBtn = vgui.RegisterTable( PANEL, "DButton" )
--

local PANEL = {}
do
	Derma_Hook( PANEL, "Paint", "Paint", "PropertySheet" )
	AccessorFunc( PANEL, "m_pActiveTab", "ActiveTab" 	)
	AccessorFunc( PANEL, "m_iPadding",	 "Padding" 		)
	
	function PANEL:Init()

		self:SetName( "TabControl" )
		self.Loaded = false
		
		self.tabScroller = self:Add( "DHorizontalScroller" )
		self.tabScroller:SetUseLiveDrag( true )
		self.tabScroller:MakeDroppable( "LuaTabs" )
		self.tabScroller:SetOverlap( 5 )
		self.tabScroller:Dock( TOP )
		self.tabScroller:DockMargin( 32, 0, 0, 0 )
		self.tabScroller.OnDragModified = function() self:PerformLayout() end
		
		self.AddBtn = self:Add( lua_editor_TabBtn )
		self.AddBtn:SetVisible( false )
		self.AddBtn:SetPos( 0, 0 )
		self.AddBtn:Setup( "+" )
		self.AddBtn.DoMiddleClick = function() end
		self.AddBtn.DoRightClick  = function() end
		self.AddBtn.DoDoubleClick = function() end
		Derma_Hook( self.AddBtn, "Paint", "Paint", "ActiveTab" )
		
		self.AddBtn.DoClick = function( )
			if ( not self:GetEditor() ) or not self:GetEditor():GetHasLoaded() then return end
			
			local base, i = "New", 0
			local name = base
			
			while self:GetEditor():GetSession( name ) do
				i = i + 1
				name = base .. " " .. i
			end
			
			local tab = self:AddTab( name )
			tab:DoClick()
			tab:DoDoubleClick()
		end
		
		self.AddBtn.ApplySchemeSettings = function( self )
			self:SetTextInset( 10, 4 )
			
			local w, h = self:GetContentSize()
			self:SetSize( w + 10, 28 )
			
			DLabel.ApplySchemeSettings( self )
		end
		
		self.AddBtn.UpdateColours = function( self, skin )
			return self:SetTextStyleColor( skin.Colours.Tab.Active.Down )
		end
		
		self.Editor = vgui.Create( "lua_editor", self ) // This is from lua_editor.lua
		self.Editor:Dock( FILL )
		self.Editor:DockMargin( 4, 0, 4, 4 )
		self.Editor.OnLoaded = function()
			self.AddBtn:SetVisible( true )
			self:LoadTabs()
		end
		
		self.Editor.OnSessionAdded = function( Editor, name, content )
			self:AddTab( FormatName( name ) )
		end
		
		self.Editor.OnSessionRemoved = function( Editor, name )
		    self:CloseTab( self:GetTabByName( name ) )
		end
		
		self.Editor.OnSessionChanged = function( Editor, name )
		    self:SwitchToName( name )
		end

		hook.Add( "ShutDown", self, function() // Making sure we save the active tab and the tabs order before quitting the game.
			if not IsValid( self ) or not self.Loaded then return end
			self:SaveTabsOrder()
			self:SaveActiveTab()
		end )
	end
	
	function PANEL:GetEditor()
		return self.Editor
	end
	
	function PANEL:OnRemove()
		if not self.Loaded then return end
		self:SaveTabsOrder()
		self:SaveActiveTab()
	end
	
	function PANEL:GetTabByName( name )
		for k, Tab in ipairs( self.tabScroller.Panels ) do
			if Tab.Name == name then
				return Tab
			end
		end
		return false
	end
	
	function PANEL:SwitchToName( name )
		local Tab = self:GetTabByName( name )
		if IsValid( Tab ) then Tab:DoClick() end
	end
	
	function PANEL:AddTab( name )
		if not self:GetEditor() then return end
		if self:GetTabByName( name ) then return end
		
		local Tab = vgui.CreateFromTable( lua_editor_TabBtn, self )
		Tab:Setup( name, self )
		
		self.tabScroller:AddPanel( Tab )
		self.tabScroller.OffsetX = self.tabScroller.pnlCanvas:GetWide() - self:GetWide() + Tab:GetWide()
		
		if self.Loaded then
			self:SaveTabsOrder()
		end
		
		return Tab
	end
	
	function PANEL:SetActiveTab( tab )
		if ( self.m_pActiveTab == tab ) then return end
		
		self.m_pActiveTab = tab
		self:InvalidateLayout()
		self:GetEditor():SetSession( tab.Name ) -- -> OnSessionChanged -> SwitchToName -> thisTab:DoClick()
		
		if self.Loaded then
			self:SaveActiveTab()
			self.tabScroller:InvalidateChildren()
			
			local editor = self:GetEditor()
			editor.OnCodeChanged(editor, editor:GetCode())
		end
	end

	function PANEL:OnTabNameChanged( oldName, newName )
		local Editor = self:GetEditor()
		
		if newName:len() < 1 or not Editor:GetHasLoaded() then return end
		
		if oldName != newName then
			Editor:RemoveSession( oldName )
			Editor:SetSession( newName )
		end
		
		self:SaveTabsOrder()
		Editor.HTML:RequestFocus()
	end

	function PANEL:LoadTabs()
		for k, name in ipairs( util.JSONToTable( self:GetCookie( "TabsOrder" ) or "" ) or {} ) do
			self:GetEditor():AddSession( name )
		end
		
		self:SwitchToName( self:GetCookie( "ActiveTab" ) or "" )
		self.Loaded = true
	end
	
	function PANEL:SaveTabsOrder()
		local tabs = {}
		
		for k, v in ipairs( self.tabScroller.Panels ) do
			tabs[ k ] = v.Name
		end
		
		self:SetCookie( "TabsOrder", util.TableToJSON( tabs ) )
		self:OnTabsSaved()
	end
	
	function PANEL:OnTabsSaved()
	end
	
	function PANEL:SaveActiveTab()
		if not self:GetActiveTab() then return end
		
		self:SetCookie( "ActiveTab", self:GetActiveTab().Name )
		self:OnTabsSaved()
	end
	
	function PANEL:PerformLayout()
		local ActiveTab = self:GetActiveTab()
		
		if not ActiveTab or not IsValid( ActiveTab ) then
			if not self.tabScroller.Panels[1] then
				self.AddBtn:DoClick()
			end
			
			return self:SetActiveTab( self.tabScroller.Panels[1] )
		end
		
		for k, Tab in ipairs( self.tabScroller.Panels ) do
			Tab:SetZPos( Tab == ActiveTab and #self.tabScroller.Panels + 1 or ( #self.tabScroller.Panels - k ) )
		end
		
		ActiveTab:InvalidateLayout()
	end
	
	function PANEL:CloseTab( tab )
	    if not tab then return end
	    table.RemoveByValue( self.tabScroller.Panels, tab )
		
		tab:Remove()
		self.tabScroller:InvalidateLayout( true )
		self:PerformLayout()
		self:SaveTabsOrder()
	end
end

derma.DefineControl( "lua_editor_TabControl", "", PANEL, "Panel" )