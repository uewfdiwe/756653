local GunFunctions = {}

function GunFunctions.grappleHook()
    local GrappleHook = require(game:GetService("ReplicatedStorage").Tools.GrappleHook)

    local grappleTask = GrappleHook.Tasks[2]
    if not grappleTask then error("GrappleHook task not found") end

    local shootMethod = grappleTask.Functions[1]
        and grappleTask.Functions[1].Activations[1]
        and grappleTask.Functions[1].Activations[1].Methods[1]
    if not shootMethod then error("Shoot method not found") end

    if shootMethod.Info then
        shootMethod.Info.Speed = 10000
        shootMethod.Info.Lifetime = 10.0
        shootMethod.Info.Gravity = Vector3.new(0, 0, 0)
        shootMethod.Info.SpreadIncrease = 0
        shootMethod.Info.Cooldown = 0.1
    end

    if grappleTask.MethodReferences
        and grappleTask.MethodReferences.Projectile
        and grappleTask.MethodReferences.Projectile.Info
        and grappleTask.MethodReferences.Projectile.Info.SpreadInfo then
        grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
        grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
        grappleTask.MethodReferences.Projectile.Info.SpreadInfo.ReductionRate = 100
    end

    if grappleTask.ResourceInfo then
        grappleTask.ResourceInfo.Cap = 999999
    end

    if GrappleHook.Adjustments then
        GrappleHook.Adjustments.ToolViewbob = false
    end

    if GrappleHook.Actions then
        if GrappleHook.Actions.LookBack then
            GrappleHook.Actions.LookBack.Enabled = true
        end
        if GrappleHook.Actions.ADS then
            GrappleHook.Actions.ADS.Enabled = true
        end
    end

    if shootMethod.Info then
        shootMethod.Info.Cooldown = 0.05
    end

    return true
end

function GunFunctions.breacher()
    local Breacher = require(game:GetService("ReplicatedStorage").Tools.Breacher)

    local portalTask
    for _, task in ipairs(Breacher.Tasks) do
        if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
            portalTask = task
            break
        end
    end
    if not portalTask then
        portalTask = Breacher.Tasks[2]
    end
    if not portalTask then error("Portal task not found") end

    if portalTask.ResourceInfo then
        portalTask.ResourceInfo.Cap = 999999
    end

    local blueShoot = portalTask.Functions[1]
        and portalTask.Functions[1].Activations[1]
        and portalTask.Functions[1].Activations[1].Methods[1]

    local yellowShoot = portalTask.Functions[2]
        and portalTask.Functions[2].Activations[1]
        and portalTask.Functions[2].Activations[1].Methods[1]

    if blueShoot and blueShoot.Info then
        blueShoot.Info.Range = 999999
        blueShoot.Info.SpreadIncrease = 0
        blueShoot.Info.Cooldown = 0.05
        blueShoot.GlobalPriority = 500
        blueShoot.Priority = 1
        blueShoot.ResourceAboveZero = false
    end

    if yellowShoot and yellowShoot.Info then
        yellowShoot.Info.Range = 999999
        yellowShoot.Info.SpreadIncrease = 0
        yellowShoot.Info.Cooldown = 0.05
        yellowShoot.GlobalPriority = 500
        yellowShoot.Priority = 1
        yellowShoot.ResourceAboveZero = false
    end

    if portalTask.MethodReferences
        and portalTask.MethodReferences.Portal
        and portalTask.MethodReferences.Portal.Info
        and portalTask.MethodReferences.Portal.Info.SpreadInfo then
        portalTask.MethodReferences.Portal.Info.SpreadInfo.MaxSpread = 0
        portalTask.MethodReferences.Portal.Info.SpreadInfo.MinSpread = 0
        portalTask.MethodReferences.Portal.Info.SpreadInfo.ReductionRate = 100
    end

    if portalTask.Functions[1] and portalTask.Functions[1].Activations[1] then
        portalTask.Functions[1].Activations[1].CanHoldDown = true
    end
    if portalTask.Functions[2] and portalTask.Functions[2].Activations[1] then
        portalTask.Functions[2].Activations[1].CanHoldDown = true
    end

    if Breacher.Actions and Breacher.Actions.ADS then
        Breacher.Actions.ADS.Enabled = false
    end

    local baseTask = Breacher.Tasks[1]
    if baseTask and baseTask.AutomaticFunctions then
        if baseTask.AutomaticFunctions[1]
            and baseTask.AutomaticFunctions[1].Methods[1]
            and baseTask.AutomaticFunctions[1].Methods[1].Info then
            baseTask.AutomaticFunctions[1].Methods[1].Info.Cooldown = 0.1
        end
        if baseTask.AutomaticFunctions[2]
            and baseTask.AutomaticFunctions[2].Methods[1]
            and baseTask.AutomaticFunctions[2].Methods[1].Info then
            baseTask.AutomaticFunctions[2].Methods[1].Info.Cooldown = 0.1
        end
    end

    if Breacher.Actions and Breacher.Actions.LookBack then
        Breacher.Actions.LookBack.Enabled = true
    end

    if Breacher.Adjustments then
        Breacher.Adjustments.ToolViewbob = true
        Breacher.Adjustments.AnimationRootStraight = true
        Breacher.Adjustments.TurnWaist = true
    end

    if Breacher.HUD then
        Breacher.HUD.CrosshairType = "Accurate"
        Breacher.HUD.Colored = true
    end

    return true
end

return GunFunctions
