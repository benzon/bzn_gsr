local GsrData = {}

lib.callback.register('bzn_gsr:server:set:gsr', function(source)
    local _source = source
    GsrData[_source] = os.time(os.date("!*t")) + (Config.GsrTime * 1000 * 60)
    Player(_source).state:set('gsr', true, true)
end)

lib.callback.register('bzn_gsr:server:remove:gsr', function(source)
    local _source = source
    
    if GsrData[_source] then
        GsrData = nil
        Player(_source).state:set('gsr', false, true)
        return true
    end
    
    return false
end)

RemoveGSR = function()
    for k, v in pairs(GsrData) do
        if v <= os.time(os.date("!*t")) then
            GsrData[k] = nil
            Player(_source).state:set('gsr', false, true)
        end
    end
    
    SetTimeout(Config.GsrAutoRemoveCheck * 1000 * 60, RemoveGSR)
end

SetTimeout(Config.GsrAutoRemoveCheck * 1000 * 60, RemoveGSR)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    if GsrData then
        for k, v in pairs(GsrData) do
            GsrData[k] = nil
            Player(k).state:set('gsr', false, true)
        end
    end
end)
