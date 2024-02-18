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
        text_warn = Color3.fromRGB(255, 128, 0),
        zebra_1 = Color3.fromRGB(40,40,40),
        zebra_2 = Color3.fromRGB(50, 50, 50)
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
        text_warn = Color3.fromRGB(255, 128, 0),
        zebra_1 = Color3.fromRGB(40,40,40),
        zebra_2 = Color3.fromRGB(40,40,40)
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
    text_warn = "text_warn",
    zebra_1 = "zebra_1",
    zebra_2 = "zebra_2"
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
    error("\nPotatoMod2 has crashed (oh no)!\nError: "..errorString.."\nPlease report this to NicePotato (.nicepotato)")
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

local function serialize(data)
    if typeof(data) == "Color3" then
        return {
            SerializedType = "Color3",
            r = data.r,
            g = data.g,
            b = data.b
        }
    end
    if typeof(data) == "EnumItem" then
        return data.Value
    end
    return data -- Data does not need to be serialized
end

local function deserialize(data)
    if type(data) == "table" then
        local dataType = data["SerializedType"]
        if dataType then -- Is this data serialized?
            if dataType == "Color3" then
                return Color3.new(data.r,data.g,data.b)
            end
        else
            return data -- Table is not serialized data
        end
    else
        return data -- Data is not serialized data
    end
end

local function serializeTable(inTable,recurse)
    recurse = recurse or 0
    if recurse >= 1000 then
        warn("Warning: Table serializer overflow! Data may be corrupted.")
        return
    end
    local outTable = {}
    for k,v in pairs(inTable) do
        k = serialize(k)
        v = serialize(v)
        if type(k) == "table" then
            k = serializeTable(k,recurse+1)
        end
        if type(v) == "table" then
            v = serializeTable(v,recurse+1)
        end
        outTable[k] = v
    end
    return outTable
end

local function deserializeTable(inTable,recurse)
    recurse = recurse or 0
    if recurse >= 1000 then
        warn("Warning: Table deserializer overflow! Data may be corrupted.")
        return
    end
    local outTable = {}
    for k,v in pairs(inTable) do
        k = deserialize(k) -- Key may be serialized data
        v = deserialize(v) -- Value may be serialized data
        if type(k) == "table" then
            k = deserializeTable(k,recurse+1)
        end
        if type(v) == "table" then
            v = deserializeTable(v,recurse+1)
        end
        outTable[k] = v
    end
    return outTable
end

local Settings = deserializeTable(GetSettings:InvokeServer())

local function printTable(table,depth, key)
    depth = depth or 1

    local function textBrackets()
        if typeof(table) == "Instance" then
            if #table:GetChildren() == 0 then
                return "{}"
            else
                return "{"
            end
        else
            if #table == 0 then
                return "{}"
            else
                return "{"
            end
        end
    end
    if typeof(table) == "Instance" then
        if key then
            print(string.rep("\t",depth-1).."["..tostring(key).."] = <["..table.ClassName..":"..table.Name.."]> = "..textBrackets())
        else
            print(string.rep("\t",depth-1).."<["..table.ClassName..":"..table.Name.."]> = "..textBrackets())
        end
        table = table:GetChildren()
    else
        if key then
            print(string.rep("\t",depth-1).."["..tostring(key).."] = "..textBrackets())
        else
            print(string.rep("\t",depth-1)..textBrackets())
        end
    end
    for k,v in pairs(table) do
        if type(v) == "table" or typeof(v) == "Instance" then
            printTable(v,depth+1,k)
        else
            print(string.rep("\t",depth).."["..tostring(k).."] = "..tostring(v))
        end
    end
    if #table > 0 then
        print(string.rep("\t",depth-1).."}")
    end
end

local settingsVersion = 4

local defaultSettings = {
    version = settingsVersion,
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

if not Settings["version"] or Settings["version"] < settingsVersion then
    Settings = defaultSettings
    warn("PotatoMod2:Warning: Settings have been lost due to corruption or unhandled version update.")
end


themes["current"] = themes[Settings.themedata.current]

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
        instance[3][#instance[3]+1] = {connectFunc,disconnectFunc,argtable} -- {connectFunc,disconnectFunc,args}
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
    
    entry[4] = {} -- Connections

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
    if not entry[4] then return end -- If not connected, can't disconnect
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

    entry[4] = {} -- Connections

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
    if not entry[4] then return end -- If not connected, can't disconnect
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
        regdefault() -- Register default theme properties
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

local function newheader(instance, child, debug) -- Register a new instance with default properties
    local newHeader = newreg(instance, child, debug)
    if newHeader then
        regheader() -- Register default theme properties
    end
    return newHeader
end

-- PotatoMod Gui
local PotatoTab = MenusBar:FindFirstChild("WindowButton")
if PotatoTab then
    PotatoTab.Size = UDim2.new(0,69,1,0)
    local TextLabel = PotatoTab.TextLabel
    TextLabel.Text = "PotatoMod"
    PotatoTab.MenuFrame.Visible = false
    PotatoTab.MenuFrame.Background.Visible = true
else
    handleError("Funny thing, the tab that PotatoMod embeds itself into has been removed by the devs! (this is not good)")
end

-- CodeEditorLocal

-- TitleBar


-- Toolbox
local Toolbox = newdefault(Windows,"Toolbox")
if Toolbox then
    newheader(Toolbox,"WindowHeader")
    
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
local function dynamicBasicObjectsHandlerConnect(instance, entry)
    entry[5] = {} -- ObjectName
    entry[6] = {} -- Instance Entries

    local function recolorTextLabel(TextLabel)
        if TextLabel.Parent.MouseOverHighlight.Visible then -- Hovered
            TextLabel.TextColor3 = Color3.new(0,0,0)
        elseif TextLabel.Parent.SelectionHighlight.Visible then -- Selected
            TextLabel.TextColor3 = Color3.new(1,1,1)
        else
            TextLabel.TextColor3 = themes.current["text"]
        end
    end

    local function hookTextLabel(TextLabel)
        if TextLabel:IsA("TextLabel") then
            TextLabel.Font = themes.current["font"]
            TextLabel.Parent.NoteLabel.Font = themes.current["font"]
            TextLabel.Parent.NoteLabel.TextColor3 = themes.current["text"]
            recolorTextLabel(TextLabel)
            local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local selectConnection = TextLabel.Parent.SelectionHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local hoverConnection = TextLabel.Parent.MouseOverHighlight:GetPropertyChangedSignal("Visible"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            entry[5][#entry[5]+1] = {TextLabel,textConnection,selectConnection,hoverConnection}
        end
    end

    local function recolorInstance(instance)
        if instance.BackgroundColor3 == Color3.new(1,1,1) then
            instance.BackgroundColor3 = themes.current["zebra_1"]
        elseif instance.BackgroundColor3 == Color3.fromRGB(246,246,246) then
            instance.BackgroundColor3 = themes.current["zebra_2"]
        end
    end

    local function hookInstance(instance)
        recolorInstance(instance)
        local connection = instance:GetPropertyChangedSignal("TextColor3"):Connect(function()
            recolorTextLabel(instance)
        end)
        entry[6][#entry[6]+1] = {instance,connection}
    end

    for _,child in pairs(instance:GetChildren()) do
        if child:IsA("TextButton") then
            hookInstance(child)
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end
    local connection = instance.ChildAdded:Connect(function(child)
        if child:IsA("TextButton") then
            hookInstance(child)
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end)
    entry[4] = connection
end

local function dynamicBasicObjectsHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect()
    for _,TextLabel in pairs(entry[5]) do 
        TextLabel[2]:Disconnect() -- TextColor listener
        TextLabel[3]:Disconnect() -- Selection listener
        TextLabel[4]:Disconnect() -- MouseOver listener
        TextLabel[1].Font = Enum.Font.SourceSans
        TextLabel[1].Parent.NoteLabel.Font = Enum.Font.SourceSans
        TextLabel[1].Parent.NoteLabel.TextColor3 = Color3.new(0.5,0.5,0.5)
        if TextLabel[1].Parent.MouseOverHighlight.Visible then -- Hovered
            TextLabel[1].TextColor3 = Color3.new(0,0,0)
        elseif TextLabel[1].Parent.SelectionHighlight.Visible then -- Selected
            TextLabel[1].TextColor3 = Color3.new(1,1,1)
        else
            TextLabel[1].TextColor3 = Color3.new(0,0,0)
        end
    end
    for _,InstanceEntry in pairs(entry[6]) do
        InstanceEntry[2]:Disconnect() -- Color listener
        if InstanceEntry[1].BackgroundColor3 == themes.current["zebra_1"] then
            InstanceEntry[1].BackgroundColor3 = Color3.new(1,1,1)
        elseif InstanceEntry[1].BackgroundColor3 == themes.current["zebra_2"] then
            InstanceEntry[1].BackgroundColor3 = Color3.fromRGB(246,246,246)
        end
    end
end

local BasicObjects = newdefault(Windows,"Basic Objects")
if BasicObjects then

    newheader(BasicObjects,"WindowHeader")
    local ListOutline = newdefault(BasicObjects,"ListOutline")
    if ListOutline then
        local List = newdefault(ListOutline,"List")
        if List then
            regtheme("BackgroundTransparency",0)
            regdynamic(dynamicBasicObjectsHandlerConnect,
                dynamicBasicObjectsHandlerDisconnect)
        end
    end
    local SearchBar = newreg(BasicObjects,"SearchBar")
    if SearchBar then
        regprop("ImageTransparency",1)
        regtheme("BackgroundColor3",theme.bg)
        regtheme("BorderColor3",theme.ol)
    end
    regdefault(BasicObjects,"BasicObjectsScript.ItemTemplate")
    newdefault(BasicObjects,"SelectText")
end

-- Explorer
local function dynamicExplorerHandlerConnect(instance, entry)
    entry[5] = {} -- ObjectName

    local function recolorTextLabel(TextLabel)
        if TextLabel.Parent.ImageTransparency == 1 then -- Unhovered
            TextLabel.TextColor3 = themes.current["text"]
        elseif TextLabel.Parent.Image == "rbxassetid://6381376761" then -- Hovered
            TextLabel.TextColor3 = Color3.new(0,0,0)
        elseif TextLabel.Parent.Image == "rbxassetid://6381375977" then -- Selected
            TextLabel.TextColor3 = Color3.new(1,1,1)
        end
    end

    local function hookTextLabel(TextLabel)
        if TextLabel:IsA("TextLabel") then
            TextLabel.Font = themes.current["font"]
            recolorTextLabel(TextLabel)
            local textConnection = TextLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            local imageConnection = TextLabel.Parent:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                recolorTextLabel(TextLabel)
            end)
            entry[5][#entry[5]+1] = {TextLabel,textConnection,imageConnection}
        end
    end

    for _,child in pairs(instance:GetChildren()) do
        if child:IsA("ImageLabel") then
            if child:FindFirstChild("ObjectName") then
                hookTextLabel(child.ObjectName)
            end
        end
    end
    local connection = instance.ChildAdded:Connect(function(child)
        if child:FindFirstChild("ObjectName") then
            hookTextLabel(child.ObjectName)
        end
    end)
    entry[4] = connection
end

local function dynamicExplorerHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect()
    for _,TextLabel in pairs(entry[5]) do 
        TextLabel[2]:Disconnect() -- TextColor listener
        TextLabel[3]:Disconnect() -- Selection listener
        TextLabel[1].Font = Enum.Font.SourceSans
        if TextLabel[1].Parent.ImageTransparency == 1 then -- Unhovered
            TextLabel[1].TextColor3 = Color3.new(0,0,0)
        elseif TextLabel[1].Parent.Image == "rbxassetid://6381376761" then -- Hovered
            TextLabel[1].TextColor3 = Color3.new(0,0,0)
        elseif TextLabel[1].Parent.Image == "rbxassetid://6381375977" then -- Selected
            TextLabel[1].TextColor3 = Color3.new(1,1,1)
        end
    end
end

local Explorer = newdefault(Windows,"Explorer")
if Explorer then
    newheader(Explorer,"WindowHeader")
    local ListOutline = newdefault(Explorer,"ListOutline")
    if ListOutline then
        local Explorer = newreg(ListOutline,"Explorer")
        if Explorer then
            regdynamic(dynamicExplorerHandlerConnect,
                dynamicExplorerHandlerDisconnect)
        end
    end
end


--Properties
local Properties = newdefault(Windows,"Properties")
if Properties then
    newheader(Properties,"WindowHeader")
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
                    local Background = newdefault(TextButton,"Background")
                    if Background then
                        regprop("BackgroundTransparency",0)
                        regprop("ImageTransparency",1)
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

    local PluginBar = newdefault(Topbar,"PluginBar")
    if PluginBar then
        regprop("BackgroundTransparency",0)
        regprop("ImageTransparency",1)
        for _,child in pairs(PluginBar[1]:GetChildren()) do
            if child:IsA("ImageLabel") then
                local PluginGroup = newdefaultself(child)
                if PluginGroup then
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
    entry[5] = {} -- TextBox entries
    entry[6] = {} -- Table list entries

    local function outputReplaceColors(textgui)
        for init,replace in pairs(outputColorReplace) do
            if textgui.TextColor3 == init then
                if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                    -- We can set this as bold font
                    textgui.Font = themes.current["font_bold"]
                else
                    -- We can set this as normal font
                    textgui.Font = themes.current["font"]
                end
                textgui.TextColor3 = themes.current[replace]
            end
        end
    end

    local function hookTextGui(textgui)
        outputReplaceColors(textgui)
        entry[5][#entry[5]+1] = {textgui}
    end

    local function hookOutput(Element)
        if Element:IsA("TextBox") then
            hookTextGui(Element)
        elseif Element:IsA("TextLabel") then -- Table Output
            -- retro tableClosed Image (6x6) - rbxassetid://8949637080
            -- retro tableOpened Image (6x6) - rbxassetid://8949639420
            -- mod tableClosed Image (7x7) - rbxassetid://16405593659
            -- mod tableOpened Image (7x7) - rbxassetid://16421483906
            
            hookTextGui(Element)
            
            for _,child in pairs(Element.List:GetChildren()) do
                hookOutput(child)
            end
            local listConnection = Element.List.ChildAdded:Connect(function(child)
                hookOutput(child)
            end)
            
            Element.ExpandButton.ImageLabel.ImageColor3 = themes.current["text"]
            Element.ExpandButton.Frame.BackgroundColor3 = themes.current["text"]

            local ImageLabel = Element.ExpandButton.ImageLabel
            if ImageLabel.Image == "rbxassetid://8949637080" then -- tableClosed
                    ImageLabel.Image = "rbxassetid://16405593659"
                elseif ImageLabel.Image == "rbxassetid://8949639420" then --tableOpened
                    ImageLabel.Image = "rbxassetid://16421483906"
                end
            local imageConnection = Element.ExpandButton.ImageLabel:GetPropertyChangedSignal("Image"):Connect(function()
                if ImageLabel.Image == "rbxassetid://8949637080" then -- tableClosed
                    ImageLabel.Image = "rbxassetid://16405593659"
                elseif ImageLabel.Image == "rbxassetid://8949639420" then --tableOpened
                    ImageLabel.Image = "rbxassetid://16421483906"
                end
            end)

            local newEntry = {Element,listConnection,imageConnection}
            entry[6][#entry[6]+1] = newEntry
        end
    end

    for _,TextBox in pairs(instance:GetChildren()) do
        hookOutput(TextBox)
    end

    local connection = instance.ChildAdded:Connect(function(child)
        hookOutput(child)
    end)
    entry[4] = connection
end

local function dynamicOutputHandlerDisconnect(instance, entry)
    if not entry[4] then return end -- If not connected, can't disconnect
    entry[4]:Disconnect() -- Disconnect if connected

    local function outputReplaceColors(textgui)
        for init,replace in pairs(outputColorReplace) do
            if textgui[1].TextColor3 == themes.current[replace] then
                if init == Color3.fromRGB(255,0,0) or init == Color3.fromRGB(255,128,0) then
                    -- We can set this as bold font
                    textgui[1].Font = themes.current["font_bold"]
                else
                    -- We can set this as normal font
                    textgui[1].Font = themes.current["font"]
                end
                textgui[1].TextColor3 = init
            end
        end
    end

    for _,textEntry in pairs(entry[5]) do -- Disconnect and reset all TextBoxes
        if textEntry[1] then
            outputReplaceColors(textEntry)
        end
    end

    for _,tableOutput in pairs(entry[6]) do -- Disconnect and reset all TableOutputs
        -- retro tableClosed Image (6x6) - rbxassetid://8949637080
        -- retro tableOpened Image (6x6) - rbxassetid://8949639420
        -- mod tableClosed Image (7x7) - rbxassetid://16405593659
        -- mod tableOpened Image (7x7) - rbxassetid://16421483906

        if tableOutput[1] then
            tableOutput[2]:Disconnect()
            tableOutput[3]:Disconnect()
            tableOutput[1].ExpandButton.ImageLabel.ImageColor3 = Color3.new(0,0,0)
            tableOutput[1].ExpandButton.Frame.BackgroundColor3 = Color3.new(0,0,0)
            local ImageLabel = tableOutput[1].ExpandButton.ImageLabel
            if ImageLabel.Image == "rbxassetid://16405593659" then -- tableClosed
                ImageLabel.Image = "rbxassetid://8949637080"
            elseif ImageLabel.Image == "rbxassetid://16421483906" then --tableOpened
                ImageLabel.Image = "rbxassetid://8949639420"
            end
        end
    end
end

local Output = newdefault(Windows,"Output")
if Output then
    newheader(Output,"WindowHeader")
    local ListOutline = newdefault(Output,"ListOutline")
    if ListOutline then
        local List = newreg(ListOutline,"List")
        if List then
            regdynamic(dynamicOutputHandlerConnect,
                dynamicOutputHandlerDisconnect)
        end
    end
end


if guiLayoutUnknown == true then
    warn("PotatoMod2: Studio has likely updated! Unrecognized layout. PotatoMod will try it's best, but things will probably be broken.")
end

local RENDER_STATE_DEFAULT = 1
local RENDER_STATE_POTATO = 2

local divider = "-------------------------------------"

local exceptionKeys = {}

local function render(state,previousException) 
    -- breakKey is used to not render things that caused an error
    for k,v in pairs(instanceList) do
        local set, message    
        if not exceptionKeys[k] then -- If this key didn't fire an error
            -- Step 1 (theme render)
            set, message = pcall(function() -- pcall as to not stop after error if can't set property
                for property,value in pairs(v[2]) do -- Static theme changes
                    if state == RENDER_STATE_DEFAULT then
                        v[1][property] = value[state]
                    else
                        v[1][property] = themes.current[value[state]]
                    end
                end
            end)
            if not set then
                exceptionKeys[k] = true
                local err = "Error during theme render stage.\nRender state: "..tostring(state).."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end
            -- Step 2 (property override)
            set, message = pcall(function() -- pcall as to not stop after error if can't set property
                for property,value in pairs(v[4]) do -- Static property changes
                    v[1][property] = value[state]
                end
            end)
            if not set then
                exceptionKeys[k] = true
                local err = "Error during property override stage.\nRender state: "..tostring(state).."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end
            -- Step 3 (hook/dynamic stage)
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
                exceptionKeys[k] = true
                local err = "Error during hook stage.\nRender state: "..tostring(state).."\n"..message
                if previousException then
                    err = "During the handling of the exception\n"..divider.."\n"..previousException.."\n"..divider.."\nAnother exception occured\n\n"..err
                end
                render(RENDER_STATE_DEFAULT,err)
                handleError(err)
            end 
        end
    end
end

local enabled = false

local function disablePotatoMod()
    PotatoTab.Visible = false
    SetSettings:FireServer(serializeTable(Settings))
    render(RENDER_STATE_DEFAULT)
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