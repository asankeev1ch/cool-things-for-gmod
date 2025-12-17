local cv_debug = CreateClientConVar("efh_armor_debug", "0", true, false, "Показывать хитбоксы брони") -- hitbox debug

EFH_Armor = {}
EFH_Armor.List = {
    ["efh_helmet_6b47_cover3"] = {
        PrintName = "6Б47 в чехле 3",
        Model = "models/eft_modular/gear/helmets/6b47_cover.mdl",
        Slot = "head",
        ArmorValue = 40,
        Weight = 2,
        Hitgroups = { [HITGROUP_HEAD] = true },
        VisualPos = Vector(0, 0, -70), 
        Skin = 2, 
        Bodygroups = {}, 
     -- Occupies = { "slot", ...} if i didnt delete function on sv or cl parts
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },
    ["efh_mask_coldgear"] = {
        PrintName = "Mask Coldgear",
        Model = "models/eft_modular/gear/facecover/mask_coldgear.mdl",
        Slot = "face",
        ArmorValue = 0,
        Weight = 0.1,
        Hitgroups = {},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = {}, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },
    ["efh_glasses_6b34"] = {
        PrintName = "Очки 6Б34",
        Model = "models/eft_modular/gear/eyewear/6b34.mdl",
        Slot = "eyes",
        ArmorValue = 5,
        Weight = 0.2,
        Hitgroups = {},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = {}, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },

    ["efh_armor_6b43"] = {
        PrintName = "6Б43",
        Model = "models/eft_modular/gear/armor/6b43.mdl",
        Slot = "body",
        ArmorValue = 100,
        Weight = 12,
        Hitgroups = { [HITGROUP_CHEST] = true, [HITGROUP_STOMACH] = true },
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 0, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1 }, 
        BoxMins = Vector(-10, -10, 0), 
        BoxMaxs = Vector(10, 10, 20),   
    },
    ["efh_lshoulder_6b43"] = {
        PrintName = "6Б43 левое плечо",
        Model = "models/eft_modular/gear/armor/6b43.mdl",
        Slot = "l_shoulder",
        ArmorValue = 20,
        Weight = 2,
        Hitgroups = { [HITGROUP_LEFTARM] = true},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 1, [1] = 1, [2] = 1, [3] = 0, [4] = 1 }, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },
    ["efh_rshoulder_6b43"] = {
        PrintName = "6Б43 правое плечо",
        Model = "models/eft_modular/gear/armor/6b43.mdl",
        Slot = "r_shoulder",
        ArmorValue = 20,
        Weight = 2,
        Hitgroups = { [HITGROUP_RIGHTARM] = true},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 0 }, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },
    ["efh_neck_6b43"] = {
        PrintName = "6Б43 шейная броня",
        Model = "models/eft_modular/gear/armor/6b43.mdl",
        Slot = "neck",
        ArmorValue = 15,
        Weight = 1,
        Hitgroups = { [HITGROUP_HEAD] = true},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 1, [1] = 0, [2] = 1, [3] = 1, [4] = 1 }, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },
    ["efh_groin_6b43"] = {
        PrintName = "6Б43 паховая броня",
        Model = "models/eft_modular/gear/armor/6b43.mdl",
        Slot = "groin",
        ArmorValue = 20,
        Weight = 1,
        Hitgroups = { [HITGROUP_STOMACH] = true},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 1, [1] = 1, [2] = 0, [3] = 1, [4] = 1 }, 
        BoxMins = Vector(-5, -5, -5), 
        BoxMaxs = Vector(5, 5, 5),   
    },

    ["efh_rig_alpha"] = {
        PrintName = "Разгрузка Альфа",
        Model = "models/eft_modular/gear/rigs/alpha.mdl",
        Slot = "rig",
        ArmorValue = 0,
        Weight = 3,
        Hitgroups = {},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 0 }, -- 0 = узкая
        BoxMins = Vector(-8, -8, 0), 
        BoxMaxs = Vector(8, 8, 20),   
        AdjustOn = {
            ["body"] = { [0] = 1 } 
        }
    },

    ["efh_backpack_6sh118"] = {
        PrintName = "Рюкзак 6Ш118",
        Model = "models/eft_modular/gear/backpacks/6sh118.mdl",
        Slot = "backpack",
        ArmorValue = 0,
        Weight = 4,
        Hitgroups = {},
        VisualPos = Vector(0, 0, -70), 
        Skin = 0, 
        Bodygroups = { [0] = 0 }, -- По умолчанию
        BoxMins = Vector(-10, -10, 0), 
        BoxMaxs = Vector(10, 12, 25),   
        AdjustOn = {
            ["body"] = { [0] = 1 },      -- Есть броня -> БГ 1
            ["rig"]  = { [0] = 2 },      -- Есть разгруз -> БГ 2
            
            ["body&rig"] = { [0] = 3 },  -- Есть И броня И разгруз -> БГ 3
        }
    },
}

function EFH_Armor.ApplyStyleByClass(ent, className)
    if not IsValid(ent) or not className or className == "" then return end
    local config = EFH_Armor.List[className]
    if config then
        if config.Skin then
            local sNum = tonumber(config.Skin) or 0
            if ent:GetSkin() ~= sNum then ent:SetSkin(sNum) end
        end
        if config.Bodygroups then
            for id, val in pairs(config.Bodygroups) do
                if ent:GetBodygroup(id) ~= val then ent:SetBodygroup(id, val) end
            end
        end
    end
end

function EFH_Armor.GetConfigByModel(modelPath) return nil end
function EFH_Armor.GetClassByModel(modelPath) return nil end

for className, info in pairs(EFH_Armor.List) do
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_gmodentity"
    ENT.PrintName = info.PrintName
    ENT.Author = "EFH"
    ENT.Category = "EFH Armor"
    ENT.Spawnable = true
    ENT.ArmorData = info 

    function ENT:PhysgunPickup(ply) return true end

    function ENT:SetupModelOffset()
        if self:GetBoneCount() > 0 then
            self:ManipulateBonePosition(0, info.VisualPos or Vector(0,0,0))
        end
    end
    
    function ENT:ApplyStyle()
        EFH_Armor.ApplyStyleByClass(self, self:GetClass())
    end

    if SERVER then
        function ENT:Initialize()
            self:SetModel(info.Model)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            
            local phys = self:GetPhysicsObject()
            if (not IsValid(phys)) or (info.BoxMins and info.BoxMaxs) then
                local mins = info.BoxMins or Vector(-5,-5,-5)
                local maxs = info.BoxMaxs or Vector(5,5,5)
                self:PhysicsInitBox(mins, maxs)
                self:SetCollisionBounds(mins, maxs)
                phys = self:GetPhysicsObject()
            end
            
            self:SetUseType(SIMPLE_USE)
            if IsValid(phys) then
                phys:SetMass(info.Weight or 10)
                phys:Wake()
            end
            self:SetupModelOffset()
            self:ApplyStyle()
        end
        
        function ENT:Use(activator, caller)
            if not IsValid(activator) or not activator:IsPlayer() then return end
            if self.NextUse and CurTime() < self.NextUse then return end
            self.NextUse = CurTime() + 0.5
            if EFH_EquipArmor then EFH_EquipArmor(activator, self) end
        end
    end

    if CLIENT then
        function ENT:Initialize()
            self:SetupModelOffset()
            self:ApplyStyle()
        end
        function ENT:Draw()
            self:SetupModelOffset() 
            self:DrawModel()
            if cv_debug:GetBool() then
                local mins, maxs = self:GetCollisionBounds()
                render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs, Color(255, 0, 0), true)
                local c = self:GetPos()
                render.DrawLine(c+Vector(-2,0,0), c+Vector(2,0,0), Color(0,0,255), true)
                render.DrawLine(c+Vector(0,-2,0), c+Vector(0,2,0), Color(0,0,255), true)
                render.DrawLine(c+Vector(0,0,-2), c+Vector(0,0,2), Color(0,0,255), true)
            end
        end
    end
    scripted_ents.Register(ENT, className)
end