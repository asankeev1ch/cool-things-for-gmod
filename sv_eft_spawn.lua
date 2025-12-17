local eftModels = {
    "models/eft/pmcs/bear_extended_pm.mdl",
    "models/eft/pmcs/usec_extended_pm.mdl",
    "models/eft/scavs/scav_extended_pm.mdl"
}

local function RandomizeAppearance(ply)
    if ply:SkinCount() > 1 then 
        ply:SetSkin(math.random(0, ply:SkinCount() - 1)) 
    end
    
    for _, bg in pairs(ply:GetBodyGroups()) do
        if bg.num > 1 then 
            ply:SetBodygroup(bg.id, math.random(0, bg.num - 1)) 
        end
    end
end

hook.Add("PlayerSpawn", "EFH_SpawnLogic", function(ply)

    timer.Simple(0, function()
        if not IsValid(ply) then return end
        
        local randomModel = table.Random(eftModels)
        ply:SetModel(randomModel)
        RandomizeAppearance(ply)
        ply:SetupHands()
    end)
end)

hook.Add("PlayerLoadout", "EFH_LoadoutLogic", function(ply)
    ply:StripWeapons()
    ply:RemoveAllAmmo()

    local weaponClass = "wep_jack_gmod_hands"
    
    if not ply:Give(weaponClass) then
        ply:Give("weapon_fists")
    end

    ply:SelectWeapon(weaponClass)
    return true 
end)

hook.Add("PlayerSetModel", "EFH_BlockModelChange", function(ply)
    return false
end)