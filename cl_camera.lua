if SERVER then return end

local cfg = {
    headBone = "ValveBiped.Bip01_Head1",
    eyesAttach = "eyes"
}

local function ManageHead(ent, scale)
    if not IsValid(ent) then return end
    local bone = ent:LookupBone(cfg.headBone)
    if bone then
        ent:ManipulateBoneScale(bone, Vector(scale, scale, scale))
    end
end

hook.Add("CalcView", "EFH_RealisticCamera_Fixed", function(ply, pos, angles, fov)
    if not IsValid(ply) or not ply:Alive() or ply:InVehicle() or ply:GetViewEntity() ~= ply then 
        return 
    end

    local view = {}
    view.origin = pos
    view.angles = angles
    view.fov = fov
    view.drawviewer = true 

    local attachID = ply:LookupAttachment(cfg.eyesAttach)
    if attachID > 0 then
        local attach = ply:GetAttachment(attachID)
        if attach then
            view.origin = attach.Pos
        end
    else
        local boneID = ply:LookupBone(cfg.headBone)
        if boneID then
            local bonePos, boneAng = ply:GetBonePosition(boneID)
            view.origin = bonePos + (boneAng:Up() * 2) + (boneAng:Forward() * 2) 
        end
    end

    if EFH_ClientStatus and EFH_ClientStatus.Limbs then
        local limbs = EFH_ClientStatus.Limbs
        
        local l_leg = (limbs[HITGROUP_LEFTLEG] or 100) <= 0
        local r_leg = (limbs[HITGROUP_RIGHTLEG] or 100) <= 0
        local l_arm = (limbs[HITGROUP_LEFTARM] or 100) <= 0
        local r_arm = (limbs[HITGROUP_RIGHTARM] or 100) <= 0

        if (l_leg or r_leg) and ply:GetVelocity():Length() > 10 then
            local speed = RealTime() * 8
            local intense = (l_leg and r_leg) and 2.5 or 1.0
            
            view.angles.p = view.angles.p + math.sin(speed) * intense
            view.angles.r = view.angles.r + math.cos(speed) * intense
        end

        if (l_arm or r_arm) then
            local shake = (l_arm and r_arm) and 0.5 or 0.2
            view.angles.p = view.angles.p + math.Rand(-shake, shake)
            view.angles.y = view.angles.y + math.Rand(-shake, shake)
        end
    end

    if ply.GetHunger then
        local hunger = ply:GetHunger() or 100
        if hunger < 20 then
            local intensity = (20 - hunger) / 20
            local time = CurTime() * 0.5
            view.angles.roll = view.angles.roll + math.sin(time) * (3 * intensity)
            view.angles.pitch = view.angles.pitch + math.cos(time * 1.5) * (1 * intensity)
        end
    end
    
    return view
end)

hook.Add("PrePlayerDraw", "EFH_HideHead_Pre", function(ply)
    if ply == LocalPlayer() and ply:Alive() and ply:GetViewEntity() == ply then
        ManageHead(ply, 0.001) -- Сжимаем голову в ноль
    end
end)

hook.Add("PostPlayerDraw", "EFH_HideHead_Post", function(ply)
    if ply == LocalPlayer() then
        ManageHead(ply, 1)
    end
end)

hook.Add("EntityRemoved", "EFH_ResetHead_Remove", function(ent)
    if ent == LocalPlayer() then
        ManageHead(ent, 1)
    end
end)