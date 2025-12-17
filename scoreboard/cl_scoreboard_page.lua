if SERVER then return end

function EFH_CreateScoreboardPage(parent)
    local page = vgui.Create("DPanel", parent)
    page:Dock(FILL)
    page.Paint = function() end
    
    local header = vgui.Create("DLabel", page)
    header:Dock(TOP)
    header:SetHeight(80)
    header:SetText(GetHostName())
    header:SetFont("EFH_UI_Big")
    header:SetContentAlignment(5)
    header:SetColor(color_white)
    
    local scroll = vgui.Create("DScrollPanel", page)
    scroll:Dock(FILL)
    scroll:DockMargin(300, 10, 300, 10) 
    scroll:GetVBar():SetWide(0) -- Скрываем скроллбар

    for _, ply in ipairs(player.GetAll()) do
        local row = scroll:Add("DButton")
        row:Dock(TOP)
        row:SetHeight(40)
        row:DockMargin(0, 0, 0, 5)
        row:SetText("")
        
        row.Paint = function(s, w, h)
            local col = Color(20, 20, 20, 255)
            if ply == LocalPlayer() then col = Color(40, 60, 40, 255) end
            if s:IsHovered() then col = Color(50, 50, 50, 255) end
            
            draw.RoundedBox(0, 0, 0, w, h, col)
            surface.SetDrawColor(255, 255, 255, 30)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        
        local avatar = vgui.Create("AvatarImage", row)
        avatar:SetSize(32, 32)
        avatar:SetPos(4, 4)
        avatar:SetPlayer(ply, 64)
        
        local name = vgui.Create("DLabel", row)
        name:Dock(FILL)
        name:DockMargin(50, 0, 0, 0)
        name:SetText(ply:Nick())
        name:SetFont("EFH_UI_Med")
        name:SetColor(color_white)
        
        local ping = vgui.Create("DLabel", row)
        ping:Dock(RIGHT)
        ping:SetWidth(80)
        ping:SetText(ply:Ping() .. " ms")
        ping:SetFont("EFH_UI_Small")
        ping:SetContentAlignment(6)
        ping:DockMargin(0, 0, 40, 0)
        
        local mute = vgui.Create("DImageButton", row)
        mute:SetSize(20, 20)
        mute:SetPos(row:GetWide() - 25, 10)
        mute.UpdateIcon = function()
            if ply:IsMuted() then
                mute:SetImage("icon32/muted.png")
                mute:SetColor(Color(255, 100, 100))
            else
                mute:SetImage("icon32/unmuted.png")
                mute:SetColor(color_white)
            end
        end
        mute.UpdateIcon()
        mute.DoClick = function()
            if ply == LocalPlayer() then return end
            ply:SetMuted(not ply:IsMuted())
            mute.UpdateIcon()
        end
        row.PerformLayout = function(s,w,h) mute:SetPos(w-25, 10) end
        
        row.DoRightClick = function()
            local menu = EFH_OpenContextMenu()
            
            menu:AddOption("Copy Name", function() 
                SetClipboardText(ply:Nick()) 
                chat.AddText(Color(100,255,100), "[UI] ", color_white, "Ник скопирован.")
            end)
            
            menu:AddOption("Copy SteamID", function() 
                SetClipboardText(ply:SteamID()) 
                chat.AddText(Color(100,255,100), "[UI] ", color_white, "SteamID скопирован.")
            end)
            
            menu:AddOption("Copy SteamID64", function() 
                SetClipboardText(ply:SteamID64()) 
                chat.AddText(Color(100,255,100), "[UI] ", color_white, "SteamID64 скопирован.")
            end)
            
            menu:Open()
        end
    end
    
    return page
end