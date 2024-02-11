local remoteEvent = game.Workspace.RemoteEvent

local function fireRemoteEvent(param1, param2, param3, param4, param5)
    remoteEvent:FireServer(param1, param2, param3, param4, param5)
end

print("firing")
fireRemoteEvent("This is just a string","","","","")