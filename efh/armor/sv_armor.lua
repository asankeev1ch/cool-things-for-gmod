if CLIENT then return end

util.AddNetworkString("EFH_UI_DropArmor")

net.Receive("EFH_UI_DropArmor", function(len, ply)
    local slot = net.ReadString()
    EFH_DropArmor(ply, slot)
end)

function EFH_EquipArmor(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    local data = ent.ArmorData
    if not data then return end
    
    local slot = data.Slot or "body"
    
    EFH_DropArmor(ply, slot)
    
    if not ply.EFH_EquipData then ply.EFH_EquipData = {} end
    ply.EFH_EquipData[slot] = { Class = ent:GetClass(), Config = data }
    
    ply:SetNWString("EFH_Armor_" .. slot, ent:GetClass())
    
    ent:Remove()
    EFH_RecalculateArmor(ply)
    ply:EmitSound("items/battery_pickup.wav")
    ply:ChatPrint("[EFH] Надето: " .. data.PrintName)
end

function EFH_DropArmor(ply, slot)
    if not slot or not ply.EFH_EquipData then return end
    local itemData = ply.EFH_EquipData[slot]
    if not itemData then return end
    
    local className = itemData.Class
    
    ply.EFH_EquipData[slot] = nil
    ply:SetNWString("EFH_Armor_" .. slot, "")

    if not className then return end
    
    local ent = ents.Create(className)
    if IsValid(ent) then
        local dropPos = ply:EyePos() + (ply:GetAimVector() * 40)
        local tr = util.TraceLine({start = ply:EyePos(), endpos = dropPos, filter = ply})
        ent:SetPos(tr.HitPos + tr.HitNormal * 5)
        ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
        ent:Spawn()
        if ent.ApplyStyle then ent:ApplyStyle() end
    end
    EFH_RecalculateArmor(ply)
end

function EFH_RecalculateArmor(ply)
    local totalArmor = 0
    if ply.EFH_EquipData then
        for slot, info in pairs(ply.EFH_EquipData) do
            if info.Config and info.Config.ArmorValue then
                totalArmor = totalArmor + info.Config.ArmorValue
            end
        end
    end
    ply:SetArmor(totalArmor)
end

hook.Add("ShouldCreatePlayerRagdoll", "EFH_BlockDefaultRagdoll_SV", function() return false end)

hook.Add("DoPlayerDeath", "EFH_CreateCustomCorpse", function(ply, attacker, dmginfo)
    ply:SetNoDraw(true)
    
    local ragdoll = ents.Create("prop_ragdoll")
    if not IsValid(ragdoll) then return end

    ragdoll:SetModel(ply:GetModel())
    ragdoll:SetPos(ply:GetPos())
    ragdoll:SetAngles(ply:GetAngles())
    
    ragdoll:SetSkin(ply:GetSkin())
    for _, v in pairs(ply:GetBodyGroups()) do
        ragdoll:SetBodygroup(v.id, ply:GetBodygroup(v.id))
    end
    
    ragdoll:Spawn()
    
    ragdoll:SetNWString("EFH_CorpseName", ply:Nick())
    
    local allSlots = {
    "sling", "back_weapon", -- lol you can delete this weapon slots
    "head", "neck", "body", "rig", "backpack", 
    "l_shoulder", "r_shoulder", "l_shoulder_back", "r_shoulder_back", 
    "groin", "face", "eyes", "visor"
}
    
    for _, slot in ipairs(allSlots) do
        local val = ply:GetNWString("EFH_Armor_" .. slot, "")
        if val ~= "" then
            ragdoll:SetNWString("EFH_RagdollArmor_" .. slot, val)
            ply:SetNWString("EFH_Armor_" .. slot, "") 
        end
    end
    
    ply.EFH_EquipData = nil
    ply:SetArmor(0)
    
    timer.Simple(0.01, function()
        if IsValid(ply) and IsValid(ragdoll) then
            ply:Spectate(OBS_MODE_CHASE)
            ply:SpectateEntity(ragdoll)
        end
    end)
end)

hook.Add("PlayerSpawn", "EFH_Armor_Clean", function(ply)
    ply:SetNoDraw(false)
    ply:UnSpectate()
    local allSlots = {
    "sling", "back_weapon", 
    "head", "neck", "body", "rig", "backpack", 
    "l_shoulder", "r_shoulder", "l_shoulder_back", "r_shoulder_back", 
    "groin", "face", "eyes", "visor"
}
    for _, slot in ipairs(allSlots) do ply:SetNWString("EFH_Armor_" .. slot, "") end
    ply.EFH_EquipData = nil
    
    ply.EFH_Bleeding = false
    ply.EFH_BrokenLegs = false
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(400)
end)