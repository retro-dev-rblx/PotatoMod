-- Retrostudio Potato Mod prerelease v0.1.0
debug = 0 -- debug mode, contains features that the average consumer may not need

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio

local BasicObjects = StudioGui:FindFirstChild("Basic Objects") -- Menu with insertable objects
local CodeEditor = StudioGui:FindFirstChild("CodeEditor") -- Script Editor
local Explorer = StudioGui:FindFirstChild("Explorer") -- Explorer menu with Workspace, Players, etc.
local MessageDialog = StudioGui:FindFirstChild("MessageDialog") -- Publish Confirmation Window
local ModelExport = StudioGui:FindFirstChild("ModelExport") -- Menu to export Model
local ModelImport = StudioGui:FindFirstChild("ModelImport") -- Menu to import Model
local Output = StudioGui:FindFirstChild("Output") -- Output menu that shows print functions and errors
local Popup = StudioGui:FindFirstChild("Popup") -- Saving Place Popup
local Properties = StudioGui:FindFirstChild("Properties") -- Property menu
local PublishAs = StudioGui:FindFirstChild("PublishAs") -- 'Select a place to overwrite' Selection
local PublishAs2 = StudioGui:FindFirstChild("PublishAs2") -- Possibly old or beta version of Overwrite/Copy menu
local PublishAsConfirm = StudioGui:FindFirstChild("PublishAsConfirm") -- Are you sure you would like to overwite?
local RibbonBarUIStyle = StudioGui:FindFirstChild("RibbonBarUIStyle") -- Functionless Modern Studio Gui
local Settings = StudioGui:FindFirstChild("Settings") -- Unused menu that is most likely studio settings
local TabBar = StudioGui:FindFirstChild("TabBar") -- Bar at top with name of place and opened scripts
local TitleBar = StudioGui:FindFirstChild("TitleBar") -- Orange (by default) bar at top with name of place
local Toolbox = StudioGui:FindFirstChild("Toolbox") -- Toolbox Menu
local BottomBar = StudioGui:FindFirstChild("BottomBar") -- Bar at bottom
local MenusBar = StudioGui:FindFirstChild("MenusBar") -- Bar at top with File, Insert, and the such
local ToolBar = StudioGui:FindFirstChild("ToolBar") --Bar at top with image buttons

local PotatoTab = MenusBar:FindFirstChild("WindowButton")

Black = Color3.fromRGB(0,0,0)
Blue = Color3.fromRGB(0,0,255)
LightBlue = Color3.fromRGB(0,155,255)
DarkBack = Color3.fromRGB(40,40,40)
LightBack = Color3.fromRGB(80,80,80)
LightBack2 = Color3.fromRGB(120,120,120)
WhiteText = Color3.fromRGB(240,240,240)
Outline = Color3.fromRGB(100,100,100)

-- If in debug mode, stop previous executions of PotatoMod
if (debug == 1) then
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
		wait(0.01)
	end
end
print("Potato Mod initializing...")

-- Delete the auto save Popup
if StudioGui:FindFirstChild("SaveReminder") then StudioGui:FindFirstChild("SaveReminder"):Destroy() end

-- Check for previous script running --
if StudioGui:FindFirstChild("PotatoMod") then
	print("Oops! It seems there is already an instace of this script running.")
	Script:Destroy()
else
	pmGui = Instance.new("Frame")
	pmGui.Parent = StudioGui
	pmGui.Name = "PotatoMod"
	pmDestroy = Instance.new("BoolValue")
	pmDestroy.Parent = pmGui
	pmDestroy.Name = "Destroy"
end

function changeScrollbar(ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)
	ScrollbarBackground.BackgroundColor3 = bgColor
	ScrollbarBackground.BorderColor3 = olColor
	ScrollbarBackground.BorderSizePixel = 1
	ScrollbarBackground.BarExtents.Image = ""
	ScrollbarBackground.UpButton.ImageColor3 = lbgColor
	ScrollbarBackground.DownButton.ImageColor3 = lbgColor
	ScrollbarBackground.BarExtents.Bar.BackgroundTransparency = 0
	ScrollbarBackground.BarExtents.Bar.Image = ""
	ScrollbarBackground.BarExtents.Bar.BackgroundColor3 = lbgColor
	ScrollbarBackground.BarExtents.Bar.Thing.BackgroundTransparency = 0
	ScrollbarBackground.BarExtents.Bar.Thing.BackgroundColor3 = lbgColor2
	ScrollbarBackground.BarExtents.Bar.Thing.Image = ""
	ScrollbarBackground.BarExtents.Bar.Thing.Size = UDim2.new(0,10,0,10) 
end

local function customGuiInit(bgColor, txtColor, olColor, lbgColor, lbgColor2)
	--Custom Gui
	pmClrConsole = Instance.new("TextButton")
	pmClrConsole.Parent = Output.ListOutline
	pmClrConsole.Name = "ClrConsole"
	pmClrConsole.BackgroundColor3 = lbgColor
	pmClrConsole.BorderColor3 = olColor
	pmClrConsole.ZIndex = 3
	pmClrConsole.Text = "Clear Console"
	pmClrConsole.TextColor3 = txtColor
	pmClrConsole.Size = UDim2.new(0,80,0,20)
	pmClrConsole.Position = UDim2.new(1,-100,0,0)
	pmClrConsole.Font = "SourceSans"
	pmClrConsole.TextSize = 14
	PotatoTab.TextLabel.Text = "PotatoMod"
	PotatoTab.Visible = true
	PotatoTab.MenuFrame.Size = UDim2.new(0,86,0,26)
	closePotatoMod = Instance.new("TextButton")
	closePotatoMod.Parent = PotatoTab.MenuFrame
	closePotatoMod.ZIndex = 3
	closePotatoMod.BackgroundColor3 = lbgColor
	closePotatoMod.BorderColor3 = olColor
	closePotatoMod.Size = UDim2.new(0,80,0,20)
	closePotatoMod.Position = UDim2.new(0,2,0,2)
	closePotatoMod.TextColor3 = txtColor
	closePotatoMod.Text = "Exit PotatoMod"
	closePotatoMod.Font = "SourceSans"
	closePotatoMod.TextSize = 14
end

local function themeInit(bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--Properties
	Properties.BackgroundColor3 = bgColor
	Properties.BorderColor3 = olColor
	Properties.TextLabel.TextColor3 = txtColor
	Properties.TextLabel.BackgroundColor3 = lbgColor
	Properties.TextLabel.BorderColor3 = olColor
	Properties.ListOutline.BackgroundColor3 = bgColor
	Properties.ListOutline.BorderColor3 = olColor
	Properties.ListOutline.Header.BackgroundColor3 = bgColor
	Properties.ListOutline.Header.Frame.BackgroundColor3 = olColor
	Properties.ListOutline.PropertyList.BumpForHeader.BackgroundColor3 = bgColor
	Properties.IdentityBackground.ImageColor3 = lbgColor
	Properties.IdentityBackground.IdentityLabel.TextColor3 = txtColor
	local children =  Properties.PropertiesScript.CategoryItem:GetChildren()
	for i, child in ipairs(children) do
		if(child.Name == "Outline") then
			child.BackgroundColor3 = olColor
		end
	end
	local children = Properties.ListOutline.Header:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextLabel") then
			child.TextColor3 = txtColor
			child.BackgroundColor3 = bgColor
			child.BorderColor3 = olColor
		end
	end
	changeScrollbar(Properties.ListOutline.ScrollbarBackground,
		bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--Toolbox
	Toolbox.BackgroundColor3 = bgColor
	Toolbox.TextLabel.TextColor3 = txtColor
	Toolbox.TextLabel.BackgroundColor3 = lbgColor
	Toolbox.TextLabel.BorderColor3 = olColor
	Toolbox.EmbedOutline.BackgroundColor3 = bgColor
	Toolbox.EmbedOutline.BorderColor3 = olColor
	local Controls = Toolbox.EmbedOutline.Embed.ClientToolbox.Controls
	Controls.BackgroundTransparency = 1
	Controls.SearchBackground.BackgroundTransparency = 1
	Controls.SearchControls.SearchBar.BackgroundColor3 = bgColor
	Controls.SearchControls.SearchBar.BorderColor3 = olColor
	Controls.SearchControls.SearchBar.TextColor3 = txtColor
	Controls.SearchControls.DisplayLabel.DropdownButton.TextColor3 = txtColor
	Controls.SearchControls.DisplayLabel.DropdownButton.BackgroundColor3 = bgColor
	Controls.SearchControls.DisplayLabel.DropdownButton.BorderColor3 = olColor
	Controls.SearchControls.DisplayLabel.DropdownButton.ImageButton.ImageColor3 = lbgColor2
	Controls.SearchControls.DisplayLabel.DropdownList.BackgroundColor3 = bgColor
	Controls.SearchControls.DisplayLabel.DropdownList.BorderColor3 = olColor
	local children = Controls.SearchControls.DisplayLabel.DropdownList:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.TextColor3 = txtColor
		end
	end
	Controls.Tabs.BackgroundColor3 = bgColor
	Controls.Tabs.BorderSizePixel = 0
	Controls.Tabs.Inventory.BorderColor3 = olColor
	Controls.Tabs.Inventory.TextColor3 = txtColor
	Controls.Tabs.Search.BorderColor3 = olColor
	Controls.Tabs.Search.TextColor3 = txtColor
	Controls.InventoryControls.SortLabel.TextColor3 = txtColor
	Controls.InventoryControls.SortLabel.DropdownButton.TextColor3 = txtColor
	Controls.InventoryControls.SortLabel.DropdownButton.BackgroundColor3 = bgColor
	Controls.InventoryControls.SortLabel.DropdownButton.BorderColor3 = olColor
	Controls.InventoryControls.SortLabel.DropdownButton.ImageButton.ImageColor3 = lbgColor2
	Toolbox.EmbedOutline.Embed.ClientToolbox.ListFrame.List.BackgroundTransparency = 0
	Toolbox.EmbedOutline.Embed.ClientToolbox.ListFrame.List.BackgroundColor3 = bgColor
	Toolbox.EmbedOutline.Embed.ClientToolbox.ListFrame.List.BorderColor3 = olColor
	local children = Toolbox.EmbedOutline.Embed.ClientToolbox.ListFrame.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "Frame") then
			child.TextLabel.TextColor3 = txtColor
			child.ImageLabel.BackgroundColor3 = bgColor
		end
	end
	changeScrollbar(Toolbox.EmbedOutline.Embed.ClientToolbox.ListFrame.ScrollbarBackground,
		bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--Basic Objects
	BasicObjects.BackgroundColor3 = bgColor
	BasicObjects.BorderColor3 = olColor
	BasicObjects.ListOutline.BackgroundColor3 = bgColor
	BasicObjects.ListOutline.BorderColor3 = olColor
	BasicObjects.ListOutline.List.BackgroundColor3 = bgColor
	BasicObjects.ListOutline.List.BorderColor3 = olColor
	BasicObjects.ListOutline.List.BackgroundTransparency = 0
	BasicObjects.TextLabel.BackgroundColor3 = lbgColor
	BasicObjects.TextLabel.BorderColor3 = olColor
	BasicObjects.TextLabel.TextColor3 = txtColor
	BasicObjects.BasicObjectsScript.ItemTemplate.BackgroundColor3 = bgColor
	BasicObjects.BasicObjectsScript.ItemTemplate.BorderColor3 = olColor
	BasicObjects.SearchBar.Image = ""
	BasicObjects.SearchBar.BackgroundColor3 = lbgColor
	BasicObjects.SearchBar.BorderColor3 = olColor
	BasicObjects.SearchBar.TextBox.TextColor3 = txtColor
	BasicObjects.SelectText.TextColor3 = txtColor
	changeScrollbar(BasicObjects.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--TitleBar
	TitleBar.BackgroundColor3 = lbgColor
	TitleBar.TextLabel.TextColor3 = txtColor
	TitleBar.CloseButton.Visible = false

	--ToolBar
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
	Output.TextLabel.BackgroundColor3 = lbgColor
	Output.TextLabel.BorderColor3 = olColor
	Output.TextLabel.TextColor3 = txtColor
	changeScrollbar(Output.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--BottomBar
	BottomBar.TextLabel.BackgroundColor3 = bgColor
	BottomBar.TextLabel.TextColor3 = txtColor
	BottomBar.TextLabel.BackgroundTransparency = 0
	BottomBar.Image = ""

	--Explorer
	Explorer.BackgroundColor3 = bgColor
	Explorer.ListOutline.BackgroundColor3 = bgColor
	Explorer.ListOutline.BorderColor3 = olColor
	Explorer.TextLabel.BackgroundColor3 = lbgColor
	Explorer.TextLabel.BorderColor3 = olColor
	Explorer.TextLabel.TextColor3 = txtColor
	changeScrollbar(Explorer.ListOutline.ScrollbarBackground, bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--MenusBar
	MenusBar.BackgroundColor3 = bgColor
	MenusBar.BackgroundTransparency = 0
	MenusBar.Image = ""
	local children = MenusBar:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.TextLabel.TextColor3 = txtColor
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
				end
			end
		end
	end


end

local function themeStep(bgColor, txtColor, olColor, lbgColor, lbgColor2)

	--Properties

	local children = Properties.ListOutline.PropertyList:GetChildren()
	for i, child in ipairs(children) do
		if(child.Name == "CategoryTemplate") then
			local children2 = child:GetChildren()
			for i, child2 in ipairs(children2) do
				if(child2.ClassName == "Frame") then
					if child2.Name == "1Topbar" then
						child2.BackgroundColor3 = lbgColor
						child2.CategoryName.TextColor3 = txtColor
					else
						if child2.PropertyHalf.TextLabel.TextColor3 == Color3.fromRGB(128,128,128) then
							--do nothing 
						else
							child2.PropertyHalf.TextLabel.TextColor3 = txtColor
						end
						child2.SelectionHighlight.Image = ""
						child2.MouseOverHighlight.Image = ""
						child2.ValueHalf.BackgroundColor3 = bgColor
						local valChildren = child2.ValueHalf:GetChildren()
						for i, valChild in ipairs(valChildren) do
							if valChild.ClassName == "TextLabel" or valChild.ClassName == "TextBox" then
								if valChild.TextColor3 == Color3.fromRGB(128,128,128) then
									--do nothing
								else
									valChild.TextColor3 = txtColor    
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
	local Controls = Toolbox.EmbedOutline.Embed.ClientToolbox.Controls
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
	end

	--BasicObjects
	local children = BasicObjects.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextButton") then
			child.BackgroundColor3 = bgColor
			child.ObjectName.TextColor3 = txtColor
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
			elseif(child.TextColor3 == Blue) then
				child.TextColor3 = LightBlue	            
			end

		end
	end

	--Explorer
	local children = Explorer.ListOutline.Explorer:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "ImageLabel") then
			child.ObjectName.TextColor3 = txtColor
		end
	end

	--Right click menu (location of this menu changes, hence the FindFirstChilds)
	if Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup") then
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Image = ""
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").BackgroundTransparency = 0
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").BackgroundColor3 = bgColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").BorderColor3 = olColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Divider.BackgroundColor3 = olColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Cut.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Cut.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Copy.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Copy.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").PasteInto.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").PasteInto.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Clear.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Clear.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Group.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Group.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Ungroup.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Ungroup.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").SelectChildren.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").SelectChildren.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").ZoomTo.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").ZoomTo.ShortcutLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Rename.NameLabel.TextColor3 = txtColor
		Explorer.ExplorerScript:FindFirstChild("ExplorerRightClickPopup").Rename.ShortcutLabel.TextColor3 = txtColor
	end
	if StudioGui:FindFirstChild("ExplorerRightClickPopup") then
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Image = ""
		StudioGui:FindFirstChild("ExplorerRightClickPopup").BackgroundTransparency = 0
		StudioGui:FindFirstChild("ExplorerRightClickPopup").BackgroundColor3 = bgColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").BorderColor3 = olColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Divider.BackgroundColor3 = olColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Cut.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Cut.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Copy.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Copy.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").PasteInto.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").PasteInto.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Clear.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Clear.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Group.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Group.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Ungroup.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Ungroup.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").SelectChildren.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").SelectChildren.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").ZoomTo.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").ZoomTo.ShortcutLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Rename.NameLabel.TextColor3 = txtColor
		StudioGui:FindFirstChild("ExplorerRightClickPopup").Rename.ShortcutLabel.TextColor3 = txtColor
	end

end

function destroySelf()
	print("Goodbye!")
	render:Disconnect()
	pmClrConsole:Destroy()
	pmGui:Destroy()
	closePotatoMod:Destroy()
	PotatoTab.Visible = false
	themeInit(Color3.fromRGB(240,240,240),Color3.fromRGB(0,0,0), Color3.fromRGB(130,135,144),
		Color3.fromRGB(185,185,185), Color3.fromRGB(185,185,185))
	themeStep(Color3.fromRGB(240,240,240),Color3.fromRGB(0,0,0), Color3.fromRGB(130,135,144),
		Color3.fromRGB(185,185,185), Color3.fromRGB(185,185,185))
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
	script.Enabled = false
	while wait() do end
end

local function renderStepped(_currentTime, deltaTime)
	--Check if script needs to stop
	if not StudioGui:FindFirstChild("PotatoMod") then
		destroySelf()
	end

	if(pmDestroy.Value == true) then
		destroySelf()
	end

	themeStep(DarkBack, WhiteText, Outline, LightBack, LightBack2)
end

function clearConsole()
	local children = Output.ListOutline.List:GetChildren()
	for i, child in ipairs(children) do
		if(child.ClassName == "TextBox") then
			child:Destroy()
		end
	end
	Output.ListOutline.ScrollbarBackground.Visible = false
end

print("------------------")
print("Potato Mod loaded!")
print("------------------")
themeInit(DarkBack, WhiteText, Outline, LightBack, LightBack2)
customGuiInit(DarkBack, WhiteText, Outline, LightBack, LightBack2)

render = RunService.Stepped:Connect(renderStepped)
pmClrConsole.MouseButton1Click:Connect(clearConsole)
closePotatoMod.MouseButton1Click:Connect(destroySelf)
