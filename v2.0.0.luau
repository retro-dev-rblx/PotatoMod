local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio
local Windows = StudioGui.Windows -- The main windows of the studio
local Topbar = StudioGui.Topbar
local MenusBar = Topbar.MenusBar

local Blue = Color3.fromRGB(0,0,255)
local LightBlue = Color3.fromRGB(0,155,255)

local themes = {
    dark = {
        bg = Color3.new(0,0,0),
        bgl_1 = Color3.new(80,80,80),
        bgl_2 = Color3.new(120,120,120),
        bgd = Color3.new(40,40,40),
        outline = Color3.new(100,100,100),
        font = Enum.Font.SourceSans,
        text = Color3.new(240,240,240),
        text_error = Color3.new(255,0,0),
        text_warn = Color3.new(255, 128, 0)
    }
}

themes["current"] = themes.dark
local curTheme = themes.current

function splitString(inputString, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    inputString:gsub(pattern, function(substring)
        table.insert(result, substring)
    end)
    
    return result
end

-- PotatoInjector has no script property
local debug = false
if not script then debug = true end

local staticGuiList = {}
local dynamicGuiList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod has died (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
    print("Challenge Complete: How did we get here?") -- this should not run
end

local function getNested(obj, children, debug)
    debug = debug or false
    if not obj then
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end 
    children = splitString(children,".")
    for k, v in pairs(children) do
        if not obj:FindFirstChild(v) or not obj:IsA("Instance") then
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
        obj = obj[v]
    end
    return obj
end


if not MenusBar:FindFirstChild("WindowButton") then handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs!") end

local PotatoTab
local ClosePotatoMod

local function customGuiInit(bgColor, txtColor, olColor, lbgColor, lbgColor2)
	--Custom Gui
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


--[[
    1 - instance
    2 - property
        1 - default
        2 - potato
    Register new object
]]
local function registerStatic(instance, child, debug)
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and instance:FindFirstChild(child) then 
        local new = {instance[child],{}}
        staticGuiList[#staticGuiList+1] = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function registerProperty(instance, property, value, debug)
    debug = debug or false
    if instance then
        instance[2][property] = {instance[1][property],value}
    else
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end
end



-- Toolbar
-- Static
local Toolbar = registerStatic(Topbar,"ToolBar")
if Toolbar then
    
end

-- TabBar
-- Static
local TabBar = registerStatic(StudioGui,"TabBar")
if TabBar then
    registerProperty(TabBar,"BackgroundColor3",curTheme.bg)
    local BottomLine = registerStatic(TabBar,"BottomLine")
    if BottomLine then
        registerProperty(BottomLine,"BackgroundColor3",curTheme.outline)
        registerProperty(BottomLine,"BorderColor3",curTheme.outline)
    end
end

-- Output
-- Static
local Output = registerStatic(Windows,"Output")
if Output then
    registerProperty(Output,"BackgroundColor3",curTheme.bg)
    registerProperty(Output,"BorderColor3",curTheme.outline)
    local ListOutline = registerStatic(Output,"ListOutline")
    if ListOutline then
        registerProperty(ListOutline,"BackgroundColor3",curTheme.bg)
        registerProperty(ListOutline,"BorderColor3",curTheme.outline)
    end
    local WindowHeader = registerStatic(Output,"WindowHeader")
    if WindowHeader then
        registerStatic(WindowHeader,"BackgroundColor3",curTheme.bgl_1)
        registerStatic(WindowHeader,"BorderColor3",curTheme.outline)
        registerStatic(WindowHeader,"TextColor3",curTheme.text)
        registerStatic(WindowHeader,"Font",curTheme.font)
    end
end

-- BottomBar
-- Static
local BottomBar = registerStatic(StudioGui,"BottomBar")
if BottomBar then
    
end


if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local function renderStatic(state)
    for k,v in pairs(staticGuiList) do
        for property,value in pairs(v[2]) do
            v[1][property] = value[state]
        end
    end
end

renderStatic(RENDER_STATE_POTATO)


warn("PotatoInjector has injected PotatoMod2!!! wow!!!")