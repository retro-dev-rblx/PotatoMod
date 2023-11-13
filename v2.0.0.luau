local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio

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
if not script then debug = true end

local staticGuiList = {}
local dynamicGuiList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod has died (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
    print("Challenge Complete: How did we get here?") -- this should not run
end

local function getNested(obj, children)
    if not obj then
        guiLayoutUnknown = true
        return nil
    end
    local nestChild
    for k, v in ipairs({...}) do
        if not obj[v] or not obj:IsA("Instance") then
            return nil
        end
        obj = obj[v]
    end
    return nestChild
end

--[[
    1 - instance
    2 - potatoProperties
    3 - retroProperties
    Register new object
]]
local function registerStatic(instance)
    if instance then 
        local new = {instance,{},{}}
        staticGuiList[#staticGuiList] = new
        return new
    else
        return nil
    end
end

local function registerDynamic(instance)
    if instance then 
        local new = {instance,{},{}}
        dynamicGuiList[#dynamicGuiList] = new
        return new
    else
        return nil
    end
end

-- Output
-- Static

