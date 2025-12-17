if SERVER then return end

hook.Add("ShouldCreatePlayerRagdoll", "EFH_BlockDefaultRagdoll_CL", function() return false end)

local VisualModels = {}
local ArmorSlots = {
    "sling", "back_weapon", 
    "head", "neck", "body", "rig", "backpack", 
    "l_shoulder", "r_shoulder", "l_shoulder_back", "r_shoulder_back", 
    "groin", "face", "eyes", "visor"
}

local function CleanupEntity(ent)
    if VisualModels[ent] then
        for slot, modelEnt in pairs(VisualModels[ent]) do
            if IsValid(modelEnt) then modelEnt:Remove() end
        end
        VisualModels[ent] = nil
    end
end

local function UpdateVisuals(ent, isRagdoll)
    if not IsValid(ent) then return end
    if isRagdoll then ent:SetupBones() end
    if not VisualModels[ent] then VisualModels[ent] = {} end
    
    local prefix = isRagdoll and "EFH_RagdollArmor_" or "EFH_Armor_"
    
    for _, slot in ipairs(ArmorSlots) do
        local className = ent:GetNWString(prefix .. slot, "")
        local currentEnt = VisualModels[ent][slot]
        
        local config = EFH_Armor.List[className]
        local modelPath = config and config.Model or ""
        
        if modelPath == "" then
            if IsValid(currentEnt) then
                currentEnt:Remove()
                VisualModels[ent][slot] = nil
            end
        else
            if not IsValid(currentEnt) or currentEnt:GetModel() ~= modelPath then
                if IsValid(currentEnt) then currentEnt:Remove() end
                
                if util.IsValidModel(modelPath) then
                    local cm = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
                    if IsValid(cm) then
                        cm:SetNoDraw(true)
                        cm:SetParent(ent)
                        cm:AddEffects(EF_BONEMERGE)
                        cm:AddEffects(EF_BONEMERGE_FASTCULL)
                        if isRagdoll then cm:AddEffects(EF_PARENT_ANIMATES) end
                        VisualModels[ent][slot] = cm
                        currentEnt = cm
                    end
                end
            end
            
            if IsValid(currentEnt) then
                EFH_Armor.ApplyStyleByClass(currentEnt, className)
                
                if config and config.AdjustOn then
                    for checkSlot, adjustBGs in pairs(config.AdjustOn) do
                        local otherItem = ent:GetNWString(prefix .. checkSlot, "")
                        if otherItem ~= "" and otherItem ~= "BLOCK" then
                            for bgID, bgVal in pairs(adjustBGs) do
                                currentEnt:SetBodygroup(bgID, bgVal)
                            end
                        end
                    end
                end
            end
        end
    end
end

hook.Add("PostPlayerDraw", "EFH_DrawArmor_Player", function(ply)
    if not IsValid(ply) or not ply:Alive() then CleanupEntity(ply) return end
    UpdateVisuals(ply, false)
    if VisualModels[ply] then
        for _, cm in pairs(VisualModels[ply]) do
            if IsValid(cm) then 
                if cm:GetParent() ~= ply then cm:SetParent(ply) end
                cm:DrawModel() 
            end
        end
    end
end)

local NextCheck = 0
hook.Add("Think", "EFH_ManageCorpses", function()
    if CurTime() < NextCheck then return end
    NextCheck = CurTime() + 0.1
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        UpdateVisuals(ent, true)
    end
end)

hook.Add("PostDrawOpaqueRenderables", "EFH_DrawArmor_Corpses", function()
    for ent, slots in pairs(VisualModels) do
        if IsValid(ent) then
            if ent:GetClass() == "prop_ragdoll" then
                ent:SetupBones()
                for _, cm in pairs(slots) do
                    if IsValid(cm) then
                        if cm:GetParent() ~= ent then cm:SetParent(ent) end
                        cm:DrawModel()
                    end
                end
            end
        else
            CleanupEntity(ent)
        end
    end
end)

hook.Add("EntityRemoved", "EFH_Armor_Cleanup", function(ent) CleanupEntity(ent) end)
hook.Add("PostCleanupMap", "EFH_Armor_MapClean", function()
    for ent, _ in pairs(VisualModels) do CleanupEntity(ent) end
    VisualModels = {}
end)