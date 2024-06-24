local PM = {
    hooks = {},
    meta = {}
}

local hooks = PM.hooks
local meta = PM.meta

function PM.HookInstance(instance)
    local hooked = {
        ["Instance"] = instance
    }
    hooked:setmetatable()
    hooks:insert()
end
    

function meta:HookChild(child_name)

end


local function registerStudio()

end

registerStudio()