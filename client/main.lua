local activateShootingCheck = false
local playerPed = cache.ped

local CreateThread = CreateThread
local Wait = Wait
local GetPlayerServerId = GetPlayerServerId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local IsPedShooting = IsPedShooting
local IsEntityInWater = IsEntityInWater

exports.ox_target:addGlobalPlayer({
    {
        icon = 'fa-regular fa-gun',
        label = 'GSR Test',
        groups = 'police',
        canInteract = function(entity, distance, coords, name)
            return distance < 1.5
        end,
        onSelect = function(data)
            local status = lib.callback.await('bzn_gsr:server:check:gsr', false)
            if status then
                return lib.notify({
                    title = 'Positive',
                    description = 'There where found Gunshot Residue on this person.',
                    type = 'success'
                })
            end
            
            return lib.notify({
                title = 'Negative',
                description = 'There was not found Gunshot Residue on this person.',
                type = 'error'
            })
        end
    }
})

lib.onCache('weapon', function(value)
    if value then
        if not Config.IgnoreWeapons[value] then
            activateShootingCheck = true
            return CheckForGunShots()
        end
    end
    
    activateShootingCheck = false
end)

CheckForGunShots = function()
    CreateThread(function()
        while activateShootingCheck do
            Wait(0)
            
            if IsPedShooting(playerPed) then
                lib.callback.await('bzn_gsr:server:set:gsr', false)
                
                Wait(Config.TimeBetweenShots * 1000)
            end
        end
    end)
end

WashingOff = function()
    CreateThread(function()
        if lib.progressBar({
            label = 'Washing of GSR',
            duration = Config.WashingOffTime * 1000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true
        }) then
            local status = lib.callback.await('bzn_gsr:server:remove:gsr', false)
            
            if status then
                removingGsr = false
                
                lib.notify({
                    title = 'Success',
                    description = 'You washed off all the Gunshot Residue in the water.',
                    type = 'success'
                })
            end
        end
    end)
end

if Config.WashOffGsrInWater then
    CreateThread(function()
        local WashingOffGsr = false
        local WaitTime = 5000
        
        while true do
            Wait(WaitTime)
            
            if LocalPlayer.state.gsr then
                if not WashingOffGsr and IsEntityInWater(playerPed) then
                    WashingOffGsr = true
                    WaitTime = 500
                    
                    WashingOff()
                end
                
                if WashingOffGsr and not IsEntityInWater(playerPed) then
                    WashingOffGsr = false
                    WaitTime = 5000
                    
                    lib.cancelProgress()
                    
                    lib.notify({
                        title = 'Cancelled',
                        description = 'You left the water too early and did not wash off the gunshot residue.',
                        type = 'error'
                    })
                end
            end
        end
    end)
end
