if CLIENT then return end

util.AddNetworkString("EFH_SyncStatus")     
util.AddNetworkString("EFH_DamageEvent")    
util.AddNetworkString("EFH_AdrenalineEffect")

local SoundHeartbeat = "player/heartbeat1.wav"

hook.Add("PlayerSpawn", "EFH_SpawnInit", function(ply)
    ply:StopSound(SoundHeartbeat)
    
    ply.EFH_Blood = EFH_Config.MaxBlood
    ply.EFH_BleedRate = 0
    
    ply.EFH_HungerStart = CurTime() + EFH_Config.HungerDelay
    ply.EFH_HungerDeath = ply.EFH_HungerStart + EFH_Config.HungerDuration
    
    ply.EFH_DmgAccumulator = 0
    ply.EFH_DmgWindowEnd = 0
    
    ply.EFH_IsContused = false 
    ply.EFH_AdrenalineEnd = 0 
    
    ply:SetDSP(0)
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(400)
    
    ply:SetHealth(ply:GetMaxHealth())
    
    EFH_Sync(ply)
end)

hook.Add("DoPlayerDeath", "EFH_StopSoundsDeath", function(ply)
    ply:StopSound(SoundHeartbeat)
end)

function EFH_Sync(ply)
    net.Start("EFH_SyncStatus")
    net.WriteFloat(ply.EFH_Blood)
    net.WriteFloat(ply.EFH_HungerStart)
    net.WriteFloat(ply.EFH_HungerDeath)
    net.Send(ply)
end

hook.Add("EntityTakeDamage", "EFH_DamageLogic", function(target, dmginfo)
    if not target:IsPlayer() or not target:Alive() then return end
    
    local dmg = dmginfo:GetDamage()
    
    local newHealth = target:Health() - dmg
    if newHealth <= 1 then newHealth = 1 end
    target:SetHealth(newHealth)
    
    local punch = math.Clamp(dmg * 0.5, 0.5, 10)
    target:ViewPunch(Angle(math.random(-punch, punch), math.random(-punch, punch), math.random(-5, 5)))
    
    if CurTime() > target.EFH_DmgWindowEnd then
        target.EFH_DmgAccumulator = 0
        target.EFH_DmgWindowEnd = CurTime() + EFH_Config.DamageWindow
    end
    
    target.EFH_DmgAccumulator = target.EFH_DmgAccumulator + dmg
    local totalDmg = target.EFH_DmgAccumulator
    
    local vignetteStr = 0
    local bleedToAdd = 0
    local doContusion = false
    
    local isAdrenaline = (CurTime() < target.EFH_AdrenalineEnd)
    
    if totalDmg >= 25 then
        vignetteStr = 255
        bleedToAdd = 250
        if not isAdrenaline then 
            doContusion = true
            target:EmitSound(SoundHeartbeat)
        end
    elseif totalDmg >= 10 then
        vignetteStr = 150
        bleedToAdd = 50
        target:EmitSound("player/pl_pain6.wav")
    elseif totalDmg >= 5 then
        vignetteStr = 80
        bleedToAdd = 20
    end
    
    local isBleedSource = dmginfo:IsBulletDamage() or dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_CLUB)
    if isBleedSource and bleedToAdd > 0 then
        if bleedToAdd > target.EFH_BleedRate then target.EFH_BleedRate = bleedToAdd end
    end
    
    if vignetteStr > 0 then
        net.Start("EFH_DamageEvent")
        net.WriteInt(vignetteStr, 9)
        net.WriteBool(doContusion)
        net.Send(target)
    end
    
    if doContusion then
        target:SetDSP(35)
        target.EFH_IsContused = true
    end
    
    return true 
end)

local nextThink = 0
hook.Add("Think", "EFH_GlobalStatus", function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end
        
        if CurTime() < ply.EFH_AdrenalineEnd then
            ply:SetRunSpeed(500)
            if ply.EFH_IsContused then 
                ply:SetDSP(0)
                ply.EFH_IsContused = false 
                ply:StopSound(SoundHeartbeat)
            end
        else
            ply:SetRunSpeed(400)
        end

        if ply.EFH_BleedRate > 0 then
            ply.EFH_Blood = ply.EFH_Blood - ply.EFH_BleedRate
            if ply.EFH_BleedRate >= 50 then util.Decal("Blood", ply:GetPos(), ply:GetPos()-Vector(0,0,50), ply) end
            
            net.Start("EFH_SyncStatus")
            net.WriteFloat(ply.EFH_Blood)
            net.WriteFloat(ply.EFH_HungerStart)
            net.WriteFloat(ply.EFH_HungerDeath)
            net.Send(ply)
        end
        
        if ply.EFH_Blood <= EFH_Config.DeathBlood then
            ply:StopSound(SoundHeartbeat)
            ply:Kill()
            ply:ChatPrint("! СМЕРТЬ ОТ ПОТЕРИ КРОВИ !")
            continue
        end
        
        if CurTime() > ply.EFH_HungerDeath then
            ply:StopSound(SoundHeartbeat)
            ply:Kill()
            ply:ChatPrint("! СМЕРТЬ ОТ ГОЛОДА !")
        end
        
        if ply.EFH_IsContused and CurTime() > ply.EFH_AdrenalineEnd then
            if math.random() < 0.02 then 
                ply:SetDSP(0)
                ply.EFH_IsContused = false
                ply:StopSound(SoundHeartbeat)
            end
        end
    end
end)