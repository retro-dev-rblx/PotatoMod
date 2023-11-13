-- Retrostudio Potato Mod release v0.1.1
local debug = 0 -- debug mode, contains features that the average consumer may not need


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
if Players.LocalPlayer.Name == "RULLY84726" then debug=1 end

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio

local Windows = StudioGui:FindFirstChild("Windows")
local BasicObjects = Windows:FindFirstChild("Basic Objects") -- Menu with insertable objects
local Explorer = Windows:FindFirstChild("Explorer") -- Explorer menu with Workspace, Players, etc.
local Output = Windows:FindFirstChild("Output") -- Output menu that shows print functions and errors
local Properties = Windows:FindFirstChild("Properties") -- Property menu
local Toolbox = Windows:FindFirstChild("Toolbox") -- Toolbox Menu

local Viewport = StudioGui:FindFirstChild("Viewport")
local CodeEditor = Viewport:FindFirstChild("CodeEditor") -- Script Editor

local Popups = StudioGui:FindFirstChild("Popups")
local MessageDialog = Popups:FindFirstChild("MessageDialog") -- Publish Confirmation Window
local ModelExport = Popups:FindFirstChild("ModelExport") -- Menu to export Model
local ModelImport = Popups:FindFirstChild("ModelImport") -- Menu to import Model
local Popup = Popups:FindFirstChild("Popup") -- Saving Place Popup
local PublishAs = Popups:FindFirstChild("PublishAs") -- 'Select a place to overwrite' Selection
local PublishAs2 = Popups:FindFirstChild("PublishAs2") -- Possibly old or beta version of Overwrite/Copy menu
local PublishAsConfirm = Popups:FindFirstChild("PublishAsConfirm") -- Are you sure you would like to overwite?
local RibbonBarUIStyle = StudioGui:FindFirstChild("RibbonBarUIStyle") -- Functionless Modern Studio Gui
local Settings = Popups:FindFirstChild("Settings") -- Unused menu that is most likely studio settings

local TopBar = StudioGui:FindFirstChild("Topbar")
local TitleBar = TopBar:FindFirstChild("TitleBar") -- Orange (by default) bar at top with name of place
local MenusBar = TopBar:FindFirstChild("MenusBar") -- Bar at top with File, Insert, and the such
local ToolBar = TopBar:FindFirstChild("ToolBar") --Bar at top with image buttons

local TabBar = StudioGui:FindFirstChild("TabBar") -- Bar at top with name of place and opened scripts
local BottomBar = StudioGui:FindFirstChild("BottomBar") -- Bar at bottom

local PotatoTab = MenusBar:FindFirstChild("WindowButton")
local ClosePotatoMod, GuiEditor
local Black = Color3.fromRGB(0,0,0)
local Blue = Color3.fromRGB(0,0,255)
local LightBlue = Color3.fromRGB(0,155,255)
local DarkBack = Color3.fromRGB(40,40,40)
local LightBack = Color3.fromRGB(80,80,80)
local LightBack2 = Color3.fromRGB(120,120,120)
local WhiteText = Color3.fromRGB(240,240,240)
local Outline = Color3.fromRGB(100,100,100)
local SourceSans = Enum.Font.SourceSans
local render
--stop previous executions of PotatoMod
if (1 == 1) then
	if StudioGui:FindFirstChild("PotatoMod") then
		--StudioGui:FindFirstChild("PotatoMod").Destroy.Value = true
		StudioGui:FindFirstChild("PotatoMod"):Destroy()
		local children = Output.ListOutline:GetChildren()
		for i, child in ipairs(children) do
			if(child.Name == "ClrConsole") then
				print("Killing previous Instance...")
				child:Destroy()
			end
		end
		task.wait(0.01)
	end
end
print("Potato Mod initializing...")

--TODO fix this so it doesn't mess up the script editor
-- Delete the auto save Popup
--if StudioGui:FindFirstChild("SaveReminder") then StudioGui:FindFirstChild("SaveReminder"):Destroy() end

-- Check for previous script running --
if StudioGui:FindFirstChild("PotatoMod") then
	print("Oops! It seems there is already an instace of this script running.")
	script:Destroy()
else
	PmGui = Instance.new("Frame")
	PmGui.Parent = StudioGui
	PmGui.Name = "PotatoMod"
	pmDestroy = Instance.new("BoolValue")
	pmDestroy.Parent = PmGui
	pmDestroy.Name = "Destroy"
end

local function changeScrollbar(ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)
	ScrollbarBackground.BackgroundColor3 = bgColor
	ScrollbarBackground.BorderColor3 = olColor
	ScrollbarBackground.BorderSizePixel = 1
	
	ScrollbarBackground.Corner.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Corner.LowerBorder.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Corner.RightBorder.BackgroundColor3 = lbgColor2
	
	ScrollbarBackground.Vertical.LeftBorder.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Vertical.RightBorder.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Vertical.BarExtents.Image = ""
	ScrollbarBackground.Vertical.UpButton.ImageColor3 = lbgColor
	ScrollbarBackground.Vertical.DownButton.ImageColor3 = lbgColor
	ScrollbarBackground.Vertical.BarExtents.Bar.BackgroundTransparency = 0
	ScrollbarBackground.Vertical.BarExtents.Bar.Image = ""
	ScrollbarBackground.Vertical.BarExtents.Bar.BackgroundColor3 = lbgColor
	ScrollbarBackground.Vertical.BarExtents.Bar.Thing.BackgroundTransparency = 0
	ScrollbarBackground.Vertical.BarExtents.Bar.Thing.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Vertical.BarExtents.Bar.Thing.Image = ""
	ScrollbarBackground.Vertical.BarExtents.Bar.Thing.Size = UDim2.new(0,10,0,10) 
	
	ScrollbarBackground.Horizontal.LowerBorder.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Horizontal.UpperBorder.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Horizontal.BarExtents.Image = ""
	ScrollbarBackground.Horizontal.LeftButton.ImageColor3 = lbgColor
	ScrollbarBackground.Horizontal.RightButton.ImageColor3 = lbgColor
	ScrollbarBackground.Horizontal.BarExtents.Bar.BackgroundTransparency = 0
	ScrollbarBackground.Horizontal.BarExtents.Bar.Image = ""
	ScrollbarBackground.Horizontal.BarExtents.Bar.BackgroundColor3 = lbgColor
	ScrollbarBackground.Horizontal.BarExtents.Bar.Thing.BackgroundTransparency = 0
	ScrollbarBackground.Horizontal.BarExtents.Bar.Thing.BackgroundColor3 = lbgColor2
	ScrollbarBackground.Horizontal.BarExtents.Bar.Thing.Image = ""
	ScrollbarBackground.Horizontal.BarExtents.Bar.Thing.Size = UDim2.new(0,10,0,10) 
end

local function customGuiInit(bgColor, txtColor, olColor, lbgColor, lbgColor2)
	--Custom Gui
	PmClrConsole = Instance.new("TextButton")
	PmClrConsole.Parent = Output.ListOutline
	PmClrConsole.Name = "ClrConsole"
	PmClrConsole.BackgroundColor3 = lbgColor
	PmClrConsole.BorderColor3 = olColor
	PmClrConsole.ZIndex = 3
	PmClrConsole.Text = "Clear Console"
	PmClrConsole.TextColor3 = txtColor
	PmClrConsole.Size = UDim2.new(0,80,0,20)
	PmClrConsole.Position = UDim2.new(1,-100,0,0)
	PmClrConsole.Font = "SourceSans"
	PmClrConsole.TextSize = 14
	PotatoTab.TextLabel.Text = "PotatoMod"
	PotatoTab.Visible = true
	PotatoTab.MenuFrame.Size = UDim2.new(0,420,0,220)
	ClosePotatoMod = Instance.new("TextButton")
	ClosePotatoMod.Parent = PotatoTab.MenuFrame
	ClosePotatoMod.Name = "ClosePotatoMod"
	ClosePotatoMod.ZIndex = 3
	ClosePotatoMod.BackgroundColor3 = lbgColor
	ClosePotatoMod.BorderColor3 = olColor
	ClosePotatoMod.Size = UDim2.new(0,80,0,20)
	ClosePotatoMod.Position = UDim2.new(1,-84,0,4)
	ClosePotatoMod.TextColor3 = txtColor
	ClosePotatoMod.Text = "Exit PotatoMod"
	ClosePotatoMod.Font = "SourceSans"
	ClosePotatoMod.TextSize = 14
	local PotatoModLogo = Instance.new("ImageLabel")
	PotatoModLogo.Parent = PotatoTab.MenuFrame
	PotatoModLogo.Name = "PotatoModLogo"
	PotatoModLogo.Image = "rbxassetid://11830984146"
	PotatoModLogo.Position = UDim2.new(0,10,0,10)
	PotatoModLogo.Size = UDim2.new(0,174,0,200)
	PotatoModLogo.BackgroundTransparency = 1
	local CrisThanks=Instance.new("TextLabel")
	CrisThanks.Parent = PotatoTab.MenuFrame
	CrisThanks.Name = "CrisThanks"
	CrisThanks.Size = UDim2.new(0,230,0,20)
	CrisThanks.Position = UDim2.new(1,-234,1,-24)
	CrisThanks.BackgroundTransparency = 1
	CrisThanks.TextColor3 = lbgColor2
	CrisThanks.TextSize = 14
	CrisThanks.Font = "SourceSans"
	CrisThanks.Text = "Big thanks to Cristiano for making this possible"
	GuiEditor = Instance.new("Frame")
	GuiEditor.Parent = PmGui
	GuiEditor.Name = "GuiEditor"
	GuiEditor.Size = UDim2.new(1,0,1,0)
	GuiEditor.BackgroundTransparency = 1
end

local function themeInit(bgColor, txtColor, olColor, lbgColor, lbgColor2, fontName)

	--Code Editor
	local CodeEditorLocal = CodeEditor.CodeManagerLocal.ScriptTemplate.CodeEditorLocal
	CodeEditorLocal.PropertiesUiModule.BrickColor.BrickColorPalette.Image = ""
	CodeEditorLocal.PropertiesUiModule.BrickColor.BrickColorPalette.BackgroundTransparency = 0
	CodeEditorLocal.PropertiesUiModule.BrickColor.BrickColorPalette.BorderColor3 = olColor
	CodeEditorLocal.PropertiesUiModule.BrickColor.BrickColorPalette.BackgroundColor3 = bgColor
	CodeEditorLocal.PropertiesUiModule.BrickColor.BrickColorPalette.BorderSizePixel = 1

	--Properties
	Properties.BackgroundColor3 = bgColor
	Properties.BorderColor3 = olColor
	Properties.WindowHeader.TextColor3 = txtColor
	Properties.WindowHeader.Font = fontName
	Properties.WindowHeader.BackgroundColor3 = lbgColor
	Properties.WindowHeader.BorderColor3 = olColor
	Properties.ListOutline.BackgroundColor3 = bgColor
	Properties.ListOutline.BorderColor3 = olColor
	Properties.ListOutline.Header.BackgroundColor3 = bgColor
	Properties.ListOutline.Header.Frame.BackgroundColor3 = olColor
	Properties.ListOutline.PropertyList.BumpForHeader.BackgroundColor3 = bgColor
	Properties.IdentityBackground.ImageColor3 = lbgColor
	Properties.IdentityBackground.IdentityLabel.TextColor3 = txtColor
	Properties.IdentityBackground.IdentityLabel.Font = fontName
	Properties.PropertiesScript.EnumList.Image = ""
	Properties.PropertiesScript.EnumList.BackgroundTransparency = 0
	Properties.PropertiesScript.EnumList.BackgroundColor3 = olColor
	Properties.PropertiesScript.EnumList.ScrollingFrame.BackgroundColor3 = bgColor
	Properties.PropertiesScript.EnumList.ScrollingFrame.ListItem.BackgroundColor3 = bgColor
	Properties.PropertiesScript.EnumList.ScrollingFrame.ListItem.TextColor3 = txtColor
	Properties.PropertiesScript.EnumList.ScrollingFrame.ListItem.Font = fontName
	Properties.PropertiesScript.EnumList.ScrollingFrame.ListItem.TextLabel.TextColor3 = txtColor
	Properties.PropertiesScript.EnumList.ScrollingFrame.ListItem.TextLabel.Font = fontName
	Properties.PropertiesScript.PropertyBrickColorPalette.Image = ""
	Properties.PropertiesScript.PropertyBrickColorPalette.BackgroundTransparency = 0
	Properties.PropertiesScript.PropertyBrickColorPalette.BorderColor3 = olColor
	Properties.PropertiesScript.PropertyBrickColorPalette.BackgroundColor3 = bgColor
	Properties.PropertiesScript.PropertyBrickColorPalette.BorderSizePixel = 1

	local children = Properties.ListOutline.Header:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextLabel") then
			child.TextColor3 = txtColor
			child.Font = fontName
			child.BackgroundColor3 = bgColor
			child.BorderColor3 = olColor
		end
	end
	changeScrollbar(Properties.ListOutline.ScrollbarBackground,
		bgColor, txtColor, olColor, lbgColor, lbgColor2)


	--Toolbox
	Toolbox.BackgroundColor3 = bgColor
	Toolbox.WindowHeader.TextColor3 = txtColor
	Toolbox.WindowHeader.Font = fontName
	Toolbox.WindowHeader.BackgroundColor3 = lbgColor
	Toolbox.WindowHeader.BorderColor3 = olColor
	Toolbox.EmbedOutline.BackgroundColor3 = bgColor
	Toolbox.EmbedOutline.BorderColor3 = olColor
	local Controls = Toolbox.EmbedOutline.Controls
	Controls.BackgroundTransparency = 1
	Controls.SearchControls.SearchBackground.BackgroundTransparency = 1
	Controls.SearchControls.SearchBar.BackgroundColor3 = bgColor
	Controls.SearchControls.SearchBar.BorderColor3 = olColor
	Controls.SearchControls.SearchBar.TextColor3 = txtColor
	Controls.SearchControls.SearchBar.Font = fontName
	Controls.SearchControls.DisplayLabel.DropdownButton.TextColor3 = txtColor
	Controls.SearchControls.DisplayLabel.DropdownButton.Font = fontName
	Controls.SearchControls.DisplayLabel.DropdownButton.BackgroundColor3 = bgColor
	Controls.SearchControls.DisplayLabel.DropdownButton.BorderColor3 = olColor
	Controls.SearchControls.DisplayLabel.DropdownButton.ImageButton.ImageColor3 = lbgColor2
	Controls.SearchControls.DisplayLabel.DropdownList.BackgroundColor3 = bgColor
	Controls.SearchControls.DisplayLabel.DropdownList.BorderColor3 = olColor
	local children = Controls.SearchControls.DisplayLabel.DropdownList:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.TextColor3 = txtColor
			child.Font = fontName
		end
	end
	Controls.Tabs.BackgroundColor3 = bgColor
	Controls.Tabs.BorderSizePixel = 0
	Controls.Tabs.Inventory.BorderColor3 = olColor
	Controls.Tabs.Inventory.TextColor3 = txtColor
	Controls.Tabs.Inventory.Font = fontName
	Controls.Tabs.Search.BorderColor3 = olColor
	Controls.Tabs.Search.TextColor3 = txtColor
	Controls.Tabs.Search.Font = fontName
	Controls.InventoryControls.SortLabel.TextColor3 = txtColor
	Controls.InventoryControls.SortLabel.Font = fontName
	Controls.InventoryControls.SortLabel.DropdownButton.TextColor3 = txtColor
	Controls.InventoryControls.SortLabel.DropdownButton.Font = fontName
	Controls.InventoryControls.SortLabel.DropdownButton.BackgroundColor3 = bgColor
	Controls.InventoryControls.SortLabel.DropdownButton.BorderColor3 = olColor
	Controls.InventoryControls.SortLabel.DropdownButton.ImageButton.ImageColor3 = lbgColor2
	Toolbox.EmbedOutline.ListFrame.List.BackgroundTransparency = 0
	Toolbox.EmbedOutline.ListFrame.List.BackgroundColor3 = bgColor
	Toolbox.EmbedOutline.ListFrame.List.BorderColor3 = olColor
	local children = Toolbox.EmbedOutline.ListFrame.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "Frame") then
			child.TextLabel.TextColor3 = txtColor
			child.TextLabel.Font = fontName
			child.ImageLabel.BackgroundColor3 = bgColor
		end
	end
	changeScrollbar(Toolbox.EmbedOutline.ListFrame.ScrollbarBackground,
		bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--Basic Objects
	BasicObjects.BackgroundColor3 = bgColor
	BasicObjects.BorderColor3 = olColor
	BasicObjects.ListOutline.BackgroundColor3 = bgColor
	BasicObjects.ListOutline.BorderColor3 = olColor
	BasicObjects.ListOutline.List.BackgroundColor3 = bgColor
	BasicObjects.ListOutline.List.BorderColor3 = olColor
	BasicObjects.ListOutline.List.BackgroundTransparency = 0
	BasicObjects.WindowHeader.BackgroundColor3 = lbgColor
	BasicObjects.WindowHeader.BorderColor3 = olColor
	BasicObjects.WindowHeader.TextColor3 = txtColor
	BasicObjects.WindowHeader.Font = fontName
	BasicObjects.BasicObjectsScript.ItemTemplate.BackgroundColor3 = bgColor
	BasicObjects.BasicObjectsScript.ItemTemplate.BorderColor3 = olColor
	BasicObjects.SearchBar.Image = ""
	BasicObjects.SearchBar.BackgroundColor3 = lbgColor
	BasicObjects.SearchBar.BorderColor3 = olColor
	BasicObjects.SearchBar.TextBox.TextColor3 = txtColor
	BasicObjects.SearchBar.TextBox.Font = fontName
	BasicObjects.SelectText.TextColor3 = txtColor
	BasicObjects.SelectText.Font = fontName
	changeScrollbar(BasicObjects.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--TitleBar
	TitleBar.BackgroundColor3 = lbgColor
	TitleBar.TextLabel.TextColor3 = txtColor
	TitleBar.TextLabel.Font = fontName
	TitleBar.CloseButton.Visible = false

	--ToolBar
	ToolBar.Tools.Color.ColorPaletteTemplate.Image = ""
	ToolBar.Tools.Color.ColorPaletteTemplate.BackgroundTransparency = 0
	ToolBar.Tools.Color.ColorPaletteTemplate.BorderColor3 = olColor
	ToolBar.Tools.Color.ColorPaletteTemplate.BackgroundColor3 = bgColor
	ToolBar.Tools.Color.ColorPaletteTemplate.BorderSizePixel = 1
	ToolBar.ImageTransparency = 1
	ToolBar.BackgroundColor3 = bgColor
	ToolBar.BorderColor3 = olColor
	local children = ToolBar:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "ImageLabel") then
			child.Image = ""
			child.BackgroundColor3 = bgColor
			local children2 = child:GetChildren()
			for i, child2 in ipairs(children2) do
				if(child2.ClassName == "Frame") then
					child2.BackgroundColor3 = bgColor
				end
			end
		end

	end


	--TabBar
	TabBar.BackgroundColor3 = bgColor
	TabBar.BottomLine.BackgroundColor3 = olColor
	TabBar.BottomLine.BorderColor3 = olColor

	--Output
	Output.BackgroundColor3 = bgColor
	Output.BorderColor3 = olColor
	Output.ListOutline.BackgroundColor3 = bgColor
	Output.ListOutline.BorderColor3 = olColor
	Output.WindowHeader.BackgroundColor3 = lbgColor
	Output.WindowHeader.BorderColor3 = olColor
	Output.WindowHeader.TextColor3 = txtColor
	Output.WindowHeader.Font = fontName
	changeScrollbar(Output.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--BottomBar
	BottomBar.TextLabel.BackgroundColor3 = bgColor
	BottomBar.TextLabel.TextColor3 = txtColor
	BottomBar.TextLabel.Font = fontName
	BottomBar.TextLabel.BackgroundTransparency = 0
	BottomBar.Image = ""

	--Explorer
	Explorer.BackgroundColor3 = bgColor
	Explorer.ListOutline.BackgroundColor3 = bgColor
	Explorer.ListOutline.BorderColor3 = olColor
	Explorer.WindowHeader.BackgroundColor3 = lbgColor
	Explorer.WindowHeader.BorderColor3 = olColor
	Explorer.WindowHeader.TextColor3 = txtColor
	Explorer.WindowHeader.Font = fontName
	changeScrollbar(Explorer.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--MenusBar
	MenusBar.BackgroundColor3 = bgColor
	MenusBar.BackgroundTransparency = 0
	MenusBar.Image = ""
	local children = MenusBar:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.TextLabel.TextColor3 = txtColor
			child.TextLabel.Font = fontName
			child.TextLabel.BackgroundColor3 = lbgColor
			child.TextLabel.BorderColor3 = olColor
			child.Background.ImageTransparency = 1
			child.Background.BackgroundTransparency = 0
			child.Background.BackgroundColor3 = lbgColor
			child.Background.BorderColor3 = olColor
			child.MenuFrame.BackgroundColor3 = bgColor
			child.MenuFrame.BorderColor3 = olColor
			child.MenuFrame.BackgroundTransparency = 0
			child.MenuFrame.BorderSizePixel = 1
			if child.MenuFrame.ClassName == "ImageLabel" then child.MenuFrame.ImageTransparency = 1 end
			local children2 = child.MenuFrame:GetDescendants()
			for i, child2 in ipairs(children2) do
				if(child2.ClassName == "TextButton" or child2.ClassName == "TextLabel") then
					child2.TextColor3 = txtColor
					child2.Font = fontName
				end
			end
		end
	end


end

local function themeStep(bgColor, txtColor, olColor, lbgColor, lbgColor2, fontName)

	--Properties
	if Properties.PropertiesScript:FindFirstChild("CategoryItem") then
		local children =  Properties.PropertiesScript.CategoryItem:GetChildren()
		for i, child in ipairs(children) do
			if(child.Name == "Outline") then
				child.BackgroundColor3 = olColor
			end
		end
	end

	local children = Properties.ListOutline.PropertyList:GetChildren()
	for i, child in ipairs(children) do
		if(child.Name == "CategoryTemplate") then
			local children2 = child:GetChildren()
			for i, child2 in ipairs(children2) do
				if(child2.ClassName == "Frame") then
					if child2.Name == "1Topbar" then
						child2.HoverGlow.Image = ""
						child2.BackgroundColor3 = lbgColor
						child2.CategoryName.TextColor3 = txtColor
						child2.CategoryName.Font = fontName
					else
						child2.SelectionHighlight.Image = ""
						child2.MouseOverHighlight.Image = ""
						child2.ValueHalf.BackgroundColor3 = bgColor
						if child2.PropertyHalf.TextLabel.TextColor3 == Color3.fromRGB(128,128,128) then
							--do nothing 
						else
							child2.PropertyHalf.TextLabel.TextColor3 = txtColor
							child2.PropertyHalf.TextLabel.Font = fontName
						end
						local valChildren = child2.ValueHalf:GetChildren()
						for i, valChild in ipairs(valChildren) do
							if valChild.ClassName == "TextLabel" or valChild.ClassName == "TextBox" then
								if valChild.TextColor3 == Color3.fromRGB(128,128,128) then
									--do nothing
								else
									valChild.TextColor3 = txtColor    
									valChild.Font = fontName
								end
							end
						end
						child2.PropertyHalf.Outline.BackgroundColor3 = olColor
						if child2.BackgroundColor3 == Color3.fromRGB(255,255,255) then
							child2.BackgroundColor3 = bgColor 
						elseif child2.BackgroundColor3 == Color3.fromRGB(246,246,246) then
							child2.BackgroundColor3 = Color3.new(
								bgColor.R-0.03,
								bgColor.G-0.03,
								bgColor.B-0.03
							)
						end
					end
				end
			end
		end
	end

	--Toolbox
	local Controls = Toolbox.EmbedOutline.Controls
	if Controls.Tabs.Inventory.BorderSizePixel == 0 then
		Controls.Tabs.Inventory.BackgroundColor3 = lbgColor
	else
		Controls.Tabs.Inventory.BackgroundColor3 = bgColor
	end
	if Controls.Tabs.Search.BorderSizePixel == 0 then
		Controls.Tabs.Search.BackgroundColor3 = lbgColor
	else
		Controls.Tabs.Search.BackgroundColor3 = bgColor
	end
	local children = Controls.InventoryControls.SortLabel.DropdownList:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.TextColor3 = txtColor
			child.Font = fontName
			if child.BackgroundColor3 == Color3.fromRGB(43,145,242) then
				--do nothing
			else
				child.BackgroundColor3 = bgColor
			end
		end
	end

	--ToolTipSquare
	if StudioGui:FindFirstChild("ToolTipSquare") then
		StudioGui:FindFirstChild("ToolTipSquare").Image = ""
		StudioGui:FindFirstChild("ToolTipSquare").BackgroundTransparency = 0
		StudioGui:FindFirstChild("ToolTipSquare").BackgroundColor3 = bgColor
		StudioGui:FindFirstChild("ToolTipSquare").BorderColor3 = olColor
		StudioGui:FindFirstChild("ToolTipSquare").TextLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ToolTipSquare").TextLabel.Font = fontName
	end

	--BasicObjects
	local children = BasicObjects.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.BackgroundColor3 = bgColor
			child.ObjectName.TextColor3 = txtColor
			child.ObjectName.Font = fontName
		end
	end

	--TabBar
	local children = TabBar.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "ImageButton") then
			child.Image = ""
			child.HoverImage = ""
			child.BackgroundColor3 = lbgColor
			child.TextLabel.TextColor3 = txtColor
			child.TextLabel.Font = fontName
			child.BottomLine.BackgroundColor3 = Outline
			child.BorderColor3 = Outline
		end
	end

	--Output
	local children = Output.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextBox") then
			if(child.TextColor3 == Black) then
				child.TextColor3 = txtColor  
				child.Font = fontName
			elseif(child.TextColor3 == Blue) then
				child.TextColor3 = LightBlue
				child.Font = fontName
			end

		end
	end

	--Explorer
	local children = Explorer.ListOutline.Explorer:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "ImageLabel") then
			child.ObjectName.TextColor3 = txtColor
			child.ObjectName.Font = fontName
		end
	end

	--Right click menu (location of this menu changes, hence the FindFirstChilds)
	if Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup") then
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Image = ""
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.BackgroundTransparency = 0
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.BackgroundColor3 = bgColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.BorderColor3 = olColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Divider.BackgroundColor3 = olColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Cut.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Cut.NameLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Cut.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Cut.ShortcutLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Copy.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Copy.NameLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Copy.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Copy.ShortcutLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.NameLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.ShortcutLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Clear.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Clear.NameLabel.Font = fontName
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Clear.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Group.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Group.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Ungroup.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Ungroup.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.SelectChildren.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.SelectChildren.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.ZoomTo.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.ZoomTo.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Rename.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Background.Rename.ShortcutLabel.TextColor3 = txtColor
	end
	if StudioGui:FindFirstChild("ExplorerRightClickPopup") then
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Image = ""
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.BackgroundTransparency = 0
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.BackgroundColor3 = bgColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.BorderColor3 = olColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Divider.BackgroundColor3 = olColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Cut.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Cut.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Copy.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Copy.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.PasteInto.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Clear.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Clear.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Group.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Group.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Ungroup.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Ungroup.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.SelectChildren.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.SelectChildren.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.ZoomTo.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.ZoomTo.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Rename.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Background.Rename.ShortcutLabel.TextColor3 = txtColor
	end

end

local function destroySelf()
	print("Goodbye!")
	render:Disconnect()
	PmClrConsole:Destroy()
	PmGui:Destroy()
	local children = MenusBar.WindowButton.MenuFrame:GetChildren()
	for i, child in ipairs(children) do
		child:Destroy()
	end
	PotatoTab.Visible = false
	themeInit(Color3.fromRGB(240,240,240),Color3.fromRGB(0,0,0), Color3.fromRGB(130,135,144),
		Color3.fromRGB(185,185,185), Color3.fromRGB(185,185,185), SourceSans)
	themeStep(Color3.fromRGB(240,240,240),Color3.fromRGB(0,0,0), Color3.fromRGB(130,135,144),
		Color3.fromRGB(185,185,185), Color3.fromRGB(185,185,185), SourceSans)
	local children = Output.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextBox") then
			if(child.TextColor3 == WhiteText) then
				child.TextColor3 = Black   
			elseif(child.TextColor3 == LightBlue) then
				child.TextColor3 = Blue	            
			end

		end
	end
	script.Disabled = true
	while task.wait(0.03) do end
end

local function renderStepped(_currentTime, deltaTime)
	--Check if script needs to stop
	if not StudioGui:FindFirstChild("PotatoMod") then
		destroySelf()
	end

	if(pmDestroy.Value == true) then
		destroySelf()
	end
	
	if LocalPlayer.UserId == 20406776 or LocalPlayer.UserId == 1304156816 then
		themeStep(Color3.fromRGB(240, 240, 240), Color3.fromRGB(0, 0, 0), Color3.fromRGB(130, 135, 144), Color3.fromRGB(185, 185, 185), Color3.fromRGB(185, 185, 185), SourceSans)
	else
		themeStep(DarkBack, WhiteText, Outline, LightBack, LightBack2, SourceSans)
	end
end

local function clearConsole()
	local children = Output.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextBox") then
			child:Destroy()
		end
	end
	Output.ListOutline.ScrollbarBackground.Visible = false
end

if LocalPlayer.UserId == 20406776 or LocalPlayer.UserId == 1304156816 then
	print("Potato Mod - Theme API init")
	themeInit(Color3.fromRGB(240, 240, 240), Color3.fromRGB(0, 0, 0), Color3.fromRGB(130, 135, 144), Color3.fromRGB(185, 185, 185), Color3.fromRGB(185, 185, 185), SourceSans)
	print("Potato Mod - Gui init")
	customGuiInit(Color3.fromRGB(240, 240, 240), Color3.fromRGB(0, 0, 0), Color3.fromRGB(130, 135, 144), Color3.fromRGB(185, 185, 185), Color3.fromRGB(185, 185, 185))
else
	print("Potato Mod - Theme API init")
	themeInit(DarkBack, WhiteText, Outline, LightBack, LightBack2, SourceSans)
	print("Potato Mod - Gui init")
	customGuiInit(DarkBack, WhiteText, Outline, LightBack, LightBack2)
end
print("--------------------------")
print("Potato Mod loaded!")
print("--------------------------")

render = RunService.Stepped:Connect(renderStepped)
PmClrConsole.MouseButton1Click:Connect(clearConsole)
ClosePotatoMod.MouseButton1Click:Connect(destroySelf)