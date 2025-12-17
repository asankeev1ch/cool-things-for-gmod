if CLIENT then return end

util.AddNetworkString("EFH_Loot_OpenMenu")
util.AddNetworkString("EFH_Loot_TakeItem")

hook.Add("PlayerUse", "EFH_Loot_UseRagdoll", function(ply, ent)

    if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return end
    
    if ent:GetNWString("EFH_CorpseName", "") == "" then return end

    if ply.NextLootTime and CurTime() < ply.NextLootTime then return false end
    ply.NextLootTime = CurTime() + 0.5

    net.Start("EFH_Loot_OpenMenu")
    net.WriteEntity(ent)
    net.Send(ply)
    
    return false 
end)

net.Receive("EFH_Loot_TakeItem", function(len, ply)
    local ragdoll = net.ReadEntity()
    local slot = net.ReadString()
    
    if not IsValid(ragdoll) or ragdoll:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end
    
    local corpsePrefix = "EFH_RagdollArmor_"
    local className = ragdoll:GetNWString(corpsePrefix .. slot, "")
    
    if className == "" or className == "BLOCK" then return end
   
    local ent = ents.Create(className)
    if IsValid(ent) then
        ent:SetPos(ply:GetPos())
        ent:SetNoDraw(true) 
        ent:Spawn()
        
        if EFH_EquipArmor then
            EFH_EquipArmor(ply, ent) -- Эта функция сама снимет старое и наденет новое
        else
            ent:SetNoDraw(false)
            ent:SetPos(ply:EyePos() + ply:GetAimVector() * 40)
        end
        
        ragdoll:SetNWString(corpsePrefix .. slot, "")
        
        local config = EFH_Armor.List[className]
        if config and config.Occupies then
            for _, extraSlot in ipairs(config.Occupies) do
                ragdoll:SetNWString(corpsePrefix .. extraSlot, "")
            end
        end
        
        if ragdoll.EFH_LootData then
            ragdoll.EFH_LootData[slot] = nil
        end
    end
end)