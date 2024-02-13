-- PotatoMod v2.0.0 created by NicePotato (.nicepotato)
-- Credits to Cristiano and Ayray for letting this project exist

-- TODO remake dropdown arrow for theme (toolbox)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GetSettings = ReplicatedStorage.RemoteFunctions.GetPotatoModSettings
local SetSettings = ReplicatedStorage.RemoteEvents.SetPotatoModSettings

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local StudioGui = PlayerGui.StudioGui-- The GUI of the studio
local Windows = StudioGui.Windows -- The main windows of the studio
local Topbar = StudioGui.Topbar
local MenusBar = Topbar.MenusBar

local themes = {
    dark = {
        header = Color3.fromRGB(60,60,60),
        bg = Color3.fromRGB(46,46,46),
        ol = Color3.fromRGB(60,60,60),
        font = Enum.Font.SourceSans,
        font_bold = Enum.Font.SourceSansBold,
        text = Color3.fromRGB(240,240,240),
        text_print = Color3.fromRGB(240,240,240),
        text_info = Color3.fromRGB(0,155,255),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0)
    },
    classic = {
        header = Color3.fromRGB(80,80,80),
        bg = Color3.fromRGB(40,40,40),
        ol = Color3.fromRGB(100,100,100),
        font = Enum.Font.SourceSans,
        font_bold = Enum.Font.SourceSansBold,
        text = Color3.fromRGB(240,240,240),
        text_print = Color3.fromRGB(240,240,240),
        text_info = Color3.fromRGB(0,155,255),
        text_error = Color3.fromRGB(255,0,0),
        text_warn = Color3.fromRGB(255, 128, 0)
    }
}

local theme = {
    header = "header",
    bg = "bg",
    ol = "ol",
    font = "font",
    font_bold = "font_bold",
    text = "text",
    text_print = "text_print",
    text_info = "text_info",
    text_error = "text_error",
    text_warn = "text_warn"
}

-- PotatoInjector has no script property
local maindebug = false
if not script then
    warn("PotatoInjector has injected PotatoMod2!!! wow!!!")
    maindebug = true
else
    task.wait(1) -- Wait for studio to get ready
end

local instanceList = {}

local guiLayoutUnknown = false -- Has the gui been changed/updated?

local function handleError(errorString)
    error("\nPotatoMod2 has died (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
    print("Challenge Complete: How did we get here?") -- this should not run
end

local function splitString(inputString, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    inputString:gsub(pattern, function(substring)
        table.insert(result, substring)
    end)
    
    return result
end

local function getNested(obj, children, debug)
    debug = debug or false
    children = splitString(children,".")
    for _, v in pairs(children) do
        if not obj:IsA("Instance") or not obj:FindFirstChild(v) then
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
        obj = obj[v]
    end
    return obj
end

-- Handle Settings
local Settings = GetSettings:InvokeServer()

local function printTable(table,depth, key)
    depth = depth or 1
    if key then
        print(string.rep("\t",depth-1).."["..tostring(key).."] = ".."{")
    else
        print(string.rep("\t",depth-1).."{")
    end
    for k,v in pairs(table) do
        if type(v) == "table" then
            printTable(v,depth+1,k)
        else
            print(string.rep("\t",depth).."["..tostring(k).."] = "..tostring(v))
        end
    end
    print(string.rep("\t",depth-1).."}")
end

printTable(Settings)

local defaultSettings = {
    version = 1,
    toggles = {
        autoLaunch = false,
        enableTheme = true
    },
    themedata = {
        current = "dark",
        customTheme = {}
    }
}

for k,v in pairs(themes.dark) do
    defaultSettings.themedata.customTheme[k] = v
end

Settings = defaultSettings

themes["current"] = themes[Settings.themedata.current]

SetSettings:FireServer(defaultSettings)

--[[
    1 - instance
    2 - theme
        1 - default
        2 - potato
            [property]
                {initial, replace}
    3 - dynamic
        [entry]
            1 - connect function
            2 - disconnect function
            3 - arg table
            4 - connections
    4 - property
        1 - default
        2 - potato
            [property]
                {initial, replace}
    Register new object
]]

local currentInst -- Instance to apply property to

-- I made these lowercase to type them easier
local function newreg(instance, child, debug) -- Register a new instance to be modified
    debug = debug or false
    if type(instance) == "table" then instance = instance[1] end
    if instance and getNested(instance,child) then 
        local new = {getNested(instance,child),{},{},{}} -- {instance, themeProperties, dynamics, properties}
        instanceList[#instanceList+1] = new
        currentInst = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.."."..child.. " is missing!")
            guiLayoutUnknown = true
            currentInst = nil
            return nil
        end
    end
end

local function newself(instance,debug)
    debug = debug or false
    if instance then 
        local new = {instance,{},{},{}} -- {instance, themeProperties, dynamics, properties}
        instanceList[#instanceList+1] = new
        currentInst = new
        return new
    else
        if not debug then
            warn("PotatoMod2: "..instance.Name.. " is missing!")
            guiLayoutUnknown = true
            currentInst = nil
            return nil
        end
    end
end

local function regtheme(property, value, instance, debug) -- Register a static property theme change
    -- This takes keys for the theme table
    instance = instance or currentInst
    debug = debug or false
    local set, message = pcall(function()
        if instance then
            instance[2][property] = {instance[1][property],value} -- {initial,replace}
        else
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
    end)
    if not set then
        if not debug then
            warn("PotatoMod2: "..message)
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function regprop(property, value, instance, debug) -- Register a static property change
    -- This is the exact same as theme change, but it gets rendered in another step
    -- This takes any arbitrary value
    instance = instance or currentInst
    debug = debug or false
    local set, message = pcall(function()
        if instance then
            instance[4][property] = {instance[1][property],value} -- {initial,replace}
        else
            if not debug then
                guiLayoutUnknown = true
                return nil
            end
        end
    end)
    if not set then
        if not debug then
            warn("PotatoMod2: "..message)
            guiLayoutUnknown = true
            return nil
        end
    end
end

local function regdynamic(connectFunc, disconnectFunc, argtable, instance, debug) -- Register a dynamic change
    instance = instance or currentInst
    debug = debug or false
    argtable = argtable or {}

    if instance then
        instance[3][#instance[3]+1] = {connectFunc,disconnectFunc,argtable,{}} -- {connectFunc,disconnectFunc,args,connections}
    else
        if not debug then
            guiLayoutUnknown = true
            return nil
        end
    end

end


local function dynamicReplaceThemeConnect(instance,entry) -- replace all theme property [keys] with [value]
    -- argtable
        -- [property]
            -- [original]
                -- = replace
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == init then
                instance[property] = themes.current[replace]
            end
            local connection = instance:GetPropertyChangedSignal(property):Connect(function()
                -- Really hope they don't start fighting over each other for their wanted value! (please don't)
                if instance[property] == init then
                    instance[property] = themes.current[replace]
                end
            end)
            entry[4][#entry[4]+1] = connection
        end
    end
end

local function dynamicReplaceThemeDisconnect(instance,entry) -- kill active replaces and reset to inital value
    for _,connection in pairs(entry[4]) do -- for all connections
        connection:Disconnect()
    end
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == themes.current[replace] then -- if value has been replaced, restore it
                instance[property] = init
            end
        end
    end
end

local function dynamicReplacePropertyConnect(instance,entry) -- replace all property [keys] with [value]
    -- argtable
        -- [property]
            -- [original]
                -- = replace
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == init then
                instance[property] = replace
            end
            local connection = instance:GetPropertyChangedSignal(property):Connect(function()
                -- Really hope they don't start fighting over each other for their wanted value! (please don't)
                if instance[property] == init then
                    instance[property] = replace
                end
            end)
            entry[4][#entry[4]+1] = connection
        end
    end
end

local function dynamicReplacePropertyDisconnect(instance,entry) -- kill active replaces and reset to inital value
    for _,connection in pairs(entry[4]) do -- for all connections
        connection:Disconnect()
    end
    for property,values in pairs(entry[3]) do -- for all properties in argtable
        for init,replace in pairs(values) do
            if instance[property] == replace then -- if value has been replaced, restore it
                instance[property] = init
            end
        end
    end
end

-- ... used to allow setting static inside of function
local function regfont(...) -- Register a default text change
    regtheme("TextColor3",theme.text)
    regtheme("Font",theme.font)
end

local function regdefault(...) -- Register a default instance property change
    regtheme("BackgroundColor3",theme.bg)
    regtheme("BorderColor3",theme.ol)
    if currentInst[1]:IsA("TextLabel") or currentInst[1]:IsA("TextBox") or currentInst[1]:IsA("TextButton") then
        regfont()
    end
end

local function newdefaultself(instance, debug)
    local newStatic = newself(instance, debug)
    if newStatic then
        regdefault()
    end
    return newStatic
end

local function newdefault(instance, child, debug) -- Register a new instance with default properties
    local newStatic = newreg(instance, child, debug)
    if newStatic then
        regdefault()
    end
    return newStatic
end

local function regheader(...)
    -- default x unhovered rbxassetid://13622951236
    -- default x hovered rbxassetid://13622964770
    -- mod x unhovered rbxassetid://16336560641
    -- mod x hovered rbxassetid://16336555516
    regtheme("BackgroundColor3",theme.header)
    regtheme("BorderColor3",theme.ol)
    regfont()
    local CloseButton = newreg(currentInst,"CloseButton")
    if CloseButton then
        regtheme("ImageColor3",theme.text)
        regdynamic(dynamicReplacePropertyConnect,
            dynamicReplacePropertyDisconnect,
            {
                ["Image"] = {
                                ["rbxassetid://13622951236"] = "rbxassetid://16336560641", -- x unhovered
                                ["rbxassetid://13622964770"] = "rbxassetid://16336555516" -- x hovered
                            }
            })
    end
end

-- CodeEditorLocal

-- TitleBar


-- Toolbox
local Toolbox = newdefault(Windows,"Toolbox")
if Toolbox then
    regheader(newreg(Toolbox,"WindowHeader"))
    
    local EmbedOutline = newdefault(Toolbox,"EmbedOutline")
    if EmbedOutline then
        local List = newdefault(EmbedOutline,"ListFrame.List")
        if List then
            regprop("BackgroundTransparency",0)
            for _,child in pairs(List[1]:GetChildren()) do
                if child:isA("Frame") then
                    local Model = newdefaultself(child)
                    if Model then
                        newdefault(Model,"TextLabel")
                        newdefault(Model,"ImageLabel")
                    end
                end
            end
        end
        local Controls = newdefault(EmbedOutline,"Controls")
        if Controls then
            local InventoryControls = newdefault(Controls,"InventoryControls")
            if InventoryControls then
                local Border = newreg(InventoryControls,"Border")
                if Border then
                    regtheme("BackgroundColor3",theme.ol)
                    regtheme("BorderColor3",theme.ol)
                end
                local SortLabel = newdefault(InventoryControls,"SortLabel")
                if SortLabel then
                    local DropdownButton = newdefault(SortLabel,"DropdownButton")
                    if DropdownButton then
                        -- TODO remake dropdown arrow for theme
                    end
                    local DropdownList = newdefault(SortLabel,"DropdownList")
                    if DropdownList then
                        for _,child in pairs(DropdownList[1]:GetChildren()) do
                            if child:isA("TextButton") then
                                newdefaultself(child)
                            end
                        end
                    end
                end
            end
            local SearchControls = newreg(Controls,"SearchControls")
            if SearchControls then
                local SearchBackground = newreg(SearchControls,"SearchBackground")
                if SearchBackground then
                    regprop("BackgroundTransparency",1)
                end
                newdefault(SearchControls,"SearchBar")
                local Border = newreg(InventoryControls,"Border")
                if Border then
                    regtheme("BackgroundColor3",theme.ol)
                    regtheme("BorderColor3",theme.ol)
                end
                local DisplayLabel = newreg(SearchControls,"DisplayLabel")
                if DisplayLabel then
                    local DropdownButton = newdefault(DisplayLabel,"DropdownButton")
                    if DropdownButton then
                        -- TODO remake dropdown arrow for theme
                    end
                    local DropdownList = newdefault(DisplayLabel,"DropdownList")
                    if DropdownList then
                        for _,child in pairs(DropdownList[1]:GetChildren()) do
                            if child:isA("TextButton") then
                                newdefaultself(child)
                            end
                        end
                    end
                end
            end
            
            local Tabs = newreg(Controls,"Tabs")
            if Tabs then
                regtheme("BackgroundColor3",theme.header)
                regtheme("BorderColor3",theme.ol)
                local replaceColors = {
                    ["BackgroundColor3"] = {
                        [Color3.fromRGB(240,240,240)] = theme.bg,
                        [Color3.fromRGB(201,201,201)] = theme.header
                    }
                }
                local Inventory = newreg(Tabs,"Inventory")
                if Inventory then
                    regtheme("BorderColor3",theme.ol)
                    regfont()
                    regdynamic(dynamicReplaceThemeConnect,
                        dynamicReplaceThemeDisconnect,
                        replaceColors)
                end
                local Search = newreg(Tabs,"Search")
                if Search then
                    regtheme("BorderColor3",theme.ol)
                    regfont()
                    regdynamic(dynamicReplaceThemeConnect,
                        dynamicReplaceThemeDisconnect,
                        replaceColors)
                end
            end
        end
    end
end

-- BasicObjects
local BasicObjects = newdefault(Windows,"Basic Objects")
if BasicObjects then
    regheader(newreg(BasicObjects,"WindowHeader"))
    local ListOutline = newdefault(BasicObjects,"ListOutline")
    if ListOutline then
        local List = newdefault(ListOutline,"List")
        if List then
            regtheme("BackgroundTransparency",0)
        end
    end
    local SearchBar = newreg(BasicObjects,"SearchBar")
    if SearchBar then
        regprop("ImageTransparency",1)
        regtheme("BackgroundColor3",theme.bg)
        regtheme("BorderColor3",theme.ol)
    end
    local ItemTemplate = regdefault(BasicObjects,"BasicObjectsScript.ItemTemplate")
    newdefault(BasicObjects,"SelectText")
end

----Basic Objects
--BasicObjects.BasicObjectsScript.ItemTemplate.BackgroundColor3 = bgColor
--BasicObjects.BasicObjectsScript.ItemTemplate.BorderColor3 = olColor

-- Explorer
local Explorer = newdefault(Windows,"Explorer")
if Explorer then
    regheader(newreg(Explorer,"WindowHeader"))
    local ListOutline = newdefault(Explorer,"ListOutline")
    if ListOutline then
        
    end
end

--Explorer.ListOutline.BackgroundColor3 = bgColor
--Explorer.ListOutline.BorderColor3 = olColor

--Properties
local Properties = newdefault(Windows,"Properties")
if Properties then
    regheader(newreg(Properties,"WindowHeader"))
    local ListOutline = newdefault(Properties,"ListOutline")
    if ListOutline then
        local Header = newdefault(ListOutline,"Header")
        if Header then
            local Frame = newreg(Header,"Frame")
            if Frame then
                regtheme("BackgroundColor3",theme.ol)
            end
        end
        local PropertyList = newdefault(ListOutline,"PropertyList")
        if PropertyList then
            
        end
        local LeftOutlineOverHeader = newreg(ListOutline,"LeftOutlineOverHeader")
        if LeftOutlineOverHeader then
            regtheme("BackgroundColor3",theme.ol)
        end
    end
    local IdentityBackground = newreg(Properties,"IdentityBackground")
    if IdentityBackground then
        regtheme("ImageColor3",theme.header)
        local IdentityLabel = newreg(IdentityBackground,"IdentityLabel")
        if IdentityLabel then
            regfont()
        end
    end
    local PropertiesScript = newreg(Properties,"PropertiesScript")
    if PropertiesScript then
        local EnumList = newreg(PropertiesScript,"EnumList")
        if EnumList then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BackgroundColor3",theme.ol)
            local ScrollingFrame = newreg(EnumList,"Frame.ScrollingFrame")
            if ScrollingFrame then
                regtheme("BackgroundColor3",theme.bg)
                local ListItem = newreg(ScrollingFrame,"ListItem")
                if ListItem then
                    regtheme("BackgroundColor3",theme.bg)
                    regfont()
                    local TextLabel = newreg(ListItem,"TextLabel")
                    if TextLabel then
                        regfont()
                    end
                end
            end
        end
        local PropertyBrickColorPalette = newreg(PropertiesScript,"PropertyBrickColorPalette")
        if PropertyBrickColorPalette then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BorderColor3",theme.ol)
            regtheme("BackgroundColor3",theme.bg)
            regprop("BorderSizePixel",1)
        end
    end
end



-- TabBar
local TabBar = newdefault(StudioGui,"TabBar")
if TabBar then
    local BottomLine = newreg(TabBar,"BottomLine")
    if BottomLine then
        regtheme("BackgroundColor3",theme.ol)
        regtheme("BorderColor3",theme.ol)
    end
end

-- Topbar
local Topbar = newreg(StudioGui,"Topbar")
if Topbar then
    -- TitleBar
    local TitleBar = newreg(Topbar,"TitleBar")
    if TitleBar then
        regtheme("BackgroundColor3",theme.bg)
        local UIGradient = newreg(TitleBar,"UIGradient")
        if UIGradient then
            regprop("Enabled", false)
        end
        local TextLabel = newreg(TitleBar,"TextLabel")
        if TextLabel then
            regfont()
        end
    end

    -- Toolbar
    local Toolbar = newdefault(Topbar,"ToolBar")
    if Toolbar then
        regprop("ImageTransparency",1)
        local PropertyBrickColorPalette = newreg(Toolbar,"Tools.Color.ColorPaletteTemplate")
        if PropertyBrickColorPalette then
            regprop("ImageTransparency",1)
            regprop("BackgroundTransparency",0)
            regtheme("BorderColor3",theme.ol)
            regtheme("BackgroundColor3",theme.bg)
            regprop("BorderSizePixel",1)
        end
        for _,child in pairs(Toolbar[1]:GetChildren()) do
            if child:IsA("ImageLabel") then
                local ImageLabel = newdefaultself(child)
                if ImageLabel then
                    regprop("ImageTransparency",1)
                    for _,child in pairs(child:GetChildren()) do
                        if child:IsA("Frame") then
                            newdefaultself(child)
                        end
                    end
                end
            end
        end
    end

    local MenusBar = newreg(Topbar,"MenusBar")
    if MenusBar then
        regtheme("BackgroundColor3",theme.header)
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        for _,child in pairs(MenusBar[1]:GetChildren()) do
            if child:IsA("TextButton") then
                local TextButton = newself(child)
                if TextButton then
                    regprop("BackgroundTransparency",0)
                    regtheme("BackgroundColor3",theme.header)
                    local TextLabel = newreg(TextButton,"TextLabel")
                    if TextLabel then
                        regfont()
                        regtheme("BackgroundColor3",theme.header)
                        regtheme("BorderColor3",theme.ol)
                    end
                    local Background = newreg(TextButton,"Background")
                    if Background then
                        regprop("BackgroundTransparency",0)
                        regprop("ImageTransparency",1)
                        regtheme("BackgroundColor3",theme.bg)
                        regtheme("BorderColor3",theme.ol)
                    end
                    if TextButton[1]:FindFirstChild("MenuFrame") then
                        local Background = newdefault(TextButton,"MenuFrame.Background")
                        if Background then
                            regprop("BackgroundTransparency",0)
                            regprop("BorderSizePixel",1)
                            if Background[1]:IsA("ImageLabel") then
                                regprop("ImageTransparency",1)
                            end
                            for _,desc in pairs(Background[1]:GetDescendants()) do
                                if desc:IsA("TextButton") or desc:IsA("TextLabel") or desc:IsA("Frame") then
                                    newdefaultself(desc)
                                end                               
                            end
                        end
                    end
                end
            end
        end
    end

    local PluginBar = newreg(Topbar,"PluginBar")
    if PluginBar then
        regtheme("BackgroundColor3",theme.header)
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        for _,child in pairs(PluginBar[1]:GetChildren()) do
            if child:IsA("ImageLabel") then
                local PluginGroup = newself(child)
                if PluginGroup then
                    regtheme("BackgroundColor3",theme.header)
                    regprop("ImageTransparency",1)
                    regprop("BackgroundTransparency",0)
                end
            end
        end
    end
end

-- BottomBar
local BottomBar = newdefault(StudioGui,"BottomBar")
if BottomBar then
    newdefault(BottomBar,"Diagnostics")
    local TextLabel = newdefault(BottomBar,"TextLabel")
    if TextLabel then
        regprop("BackgroundTransparency",0)
    end
end

-- Output
local outputColorReplace = {
    [Color3.fromRGB(0,0,0)] = theme.text_print,
    [Color3.fromRGB(0,0,255)] = theme.text_info,
    [Color3.fromRGB(255,128,0)] = theme.text_warn,
    [Color3.fromRGB(255,0,0)] = theme.text_error
}

local function dynamicOutputHandlerConnect(instance, entry)
    -- entry
        -- 4 - list connection (not table)
        -- 5 - TextBox entry table
            -- instance
            -- connection

    entry[5] = {} -- TextBox entries

    local function hookTextBox(TextBox)
        if TextBox:IsA("TextBox") then
            for init,replace in pairs(outputColorReplace) do
                if TextBox.TextColor3 == init then
                    if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                        -- We can set this as bold font
                        TextBox.Font = themes.current["font_bold"]
                    else
                        -- We can set this as normal font
                        TextBox.Font = themes.current["font"]
                    end
                    TextBox.TextColor3 = themes.current[replace]
                end
            end
            local connection = TextBox:GetPropertyChangedSignal("TextColor3"):Connect(function()
                for init,replace in pairs(outputColorReplace) do
                    if TextBox.TextColor3 == init then
                        if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                            -- We can set this as bold font
                            TextBox.Font = themes.current["font_bold"]
                        else
                            -- We can set this as normal font
                            TextBox.Font = themes.current["font"]
                        end
                        TextBox.TextColor3 = themes.current[replace]
                    end
                end
            end)
            entry[5][#entry[5]+1] = {TextBox,connection}
        end
    end

    for _,TextBox in pairs(instance:GetChildren()) do
        hookTextBox(TextBox)
    end

    local connection = instance.ChildAdded:Connect(function(child)
        hookTextBox(child)
    end)
    entry[4] = connection
end

local function dynamicOutputHandlerDisconnect(instance, entry)
    if not entry[5] then return end -- If we have never connected, no need to disconnect
                                    -- entry 5 is the TextBox entry table
    entry[4]:Disconnect() -- Disconnect if connected
    for _,textEntry in pairs(entry[5]) do -- Disconnect and reset all TextBoxes
        textEntry[2]:Disconnect()
        for init,replace in pairs(outputColorReplace) do
            if textEntry[1].TextColor3 == themes.current[replace] then
                if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                    -- We can set this as bold font
                    textEntry[1].Font = themes.current["font_bold"]
                else
                    -- We can set this as normal font
                    textEntry[1].Font = themes.current["font"]
                end
                textEntry[1].TextColor3 = init
            end
        end
    end
end

local Output = newdefault(Windows,"Output")
if Output then
    regheader(newreg(Output,"WindowHeader"))
    local ListOutline = newdefault(Output,"ListOutline")
    if ListOutline then
        local List = newreg(ListOutline,"List")
        if List then
            regdynamic(dynamicOutputHandlerConnect,
                dynamicOutputHandlerDisconnect)
        end
    end
end



-- PotatoMod Gui
local PotatoTab = MenusBar:FindFirstChild("WindowButton")
if PotatoTab then
    PotatoTab = newself(PotatoTab)
    regprop("")
    regprop("BackgroundTransparency",0)
    regtheme("BackgroundColor3",theme.header)
    local TextLabel = newreg(PotatoTab,"TextLabel")
    if TextLabel then
        TextLabel[1].Text = "PotatoMod"
        regfont()
        regtheme("BackgroundColor3",theme.header)
        regtheme("BorderColor3",theme.ol)
    end
    local Background = newreg(PotatoTab,"Background")
    if Background then
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        regtheme("BackgroundColor3",theme.bg)
        regtheme("BorderColor3",theme.ol)
    end
    if PotatoTab[1]:FindFirstChild("MenuFrame") then
        local Background = newdefault(PotatoTab,"MenuFrame.Background")
        if Background then
            regprop("BackgroundTransparency",0)
            regprop("BorderSizePixel",1)
            if Background[1]:IsA("ImageLabel") then
                regprop("ImageTransparency",1)
            end
            for _,desc in pairs(Background[1]:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("TextLabel") or desc:IsA("Frame") then
                    newdefaultself(desc)
                end                               
            end
        end
    end
else
    handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs! (this is not good)")
end



if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local function render(state)
    for k,v in pairs(instanceList) do
        local set, message    
        set, message = pcall(function() -- pcall as to not stop after error if can't set property
            for property,value in pairs(v[2]) do -- Static theme changes
                if state == RENDER_STATE_DEFAULT then
                    v[1][property] = value[state]
                else
                    v[1][property] = themes.current[value[state]]
                end
            end
        end)
        set, message = pcall(function() -- pcall as to not stop after error if can't set property
            for property,value in pairs(v[4]) do -- Static property changes
                v[1][property] = value[state]
            end
        end)
        if not set then
            if state ~= RENDER_STATE_DEFAULT then
                render(RENDER_STATE_DEFAULT)
                handleError("Error during render stage.\n"..message)
            end
        end
        set, message = pcall(function() -- pcall as to not stop after error
            for _,entry in pairs(v[3]) do -- Dynamic properties
                if state == RENDER_STATE_DEFAULT then
                    entry[2](v[1],entry) -- Disconnect
                else
                    entry[2](v[1],entry) -- Disconnect
                    entry[1](v[1],entry) -- Connect
                end
            end
        end)
        if not set then
            if state ~= RENDER_STATE_DEFAULT then
                render(RENDER_STATE_DEFAULT)
                handleError("Error during hook stage.\n"..message)
            end
        end
        
    end
end

local enabled = false

local function disablePotatoMod()
    render(RENDER_STATE_DEFAULT)
    SetSettings:FireServer(Settings)
    PotatoTab.Visible = false
    enabled = false
    warn("PotatoMod2 disabled.")
end

local function enablePotatoMod()
    enabled = true
    if Settings.toggles.enableTheme then
        render(RENDER_STATE_POTATO)
    end
    PotatoTab.Visible = true
    warn("PotatoMod2 loaded.")
end

if script then -- Real PotatoMod, do startup stuffs
    local EnableBind = Instance.new("BindableEvent")
    EnableBind.Parent = script
    EnableBind.Event:Connect(function()
        if enabled then
            warn("PotatoMod2 is already loaded.")
        else
            enablePotatoMod()
        end
    end)
end

if Settings.toggles.autoLaunch or maindebug then
    enablePotatoMod()
    if maindebug then
        task.wait(5)
        disablePotatoMod()
    end
end