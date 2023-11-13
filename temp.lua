local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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

-- PotatoInjector has no script property
local debug = false
if script then debug = true end

