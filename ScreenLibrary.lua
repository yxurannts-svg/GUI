-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ScreenLibrary v2.0 — Complete Rewrite                                  ║
-- ║  Tab-based, mobile-first Roblox UI Library                              ║
-- ║  Font: Enum.Font.Code (replace with Font.fromId(ZIGLET_ID) if desired)  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local ScreenLibrary = {}
ScreenLibrary.__index = ScreenLibrary

-- ── Services ──────────────────────────────────────────────────────────────
local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpSvc    = game:GetService("HttpService")
local lp         = Players.LocalPlayer

-- ── Theme ─────────────────────────────────────────────────────────────────
local TH = {
    font     = Enum.Font.Code,           -- swap to Font.fromId(ZIGLET_ID) for ZIGLET
    fontBold = Enum.Font.Code,
    bg       = Color3.fromRGB(10,10,14),
    panel    = Color3.fromRGB(16,16,22),
    btn      = Color3.fromRGB(22,22,30),
    txt      = Color3.fromRGB(220,220,230),
    sub      = Color3.fromRGB(110,110,130),
    accent   = Color3.fromRGB(55,100,200),
    red      = Color3.fromRGB(200,50,50),
    green    = Color3.fromRGB(50,180,80),
}

-- ── Asset IDs ─────────────────────────────────────────────────────────────
local A = {
    Close     = "rbxassetid://102294560393348",
    Minimize  = "rbxassetid://128177999060314",
    Settings  = "rbxassetid://81674596586133",
    TabMain   = "rbxassetid://112531394951219",
    TabConfig = "rbxassetid://123691490737576",
    TabSearch = "rbxassetid://2512702201",
    Dots      = "rbxassetid://87700959705353",
    BtnBG     = "rbxassetid://119837262097522",
}

-- ── Utility ───────────────────────────────────────────────────────────────
local function corner(i,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=i; return c
end
local function stroke(i,t,col,tr)
    local s=Instance.new("UIStroke"); s.Thickness=t or 1
    s.Color=col or TH.accent; s.Transparency=tr or 0.6; s.Parent=i; return s
end
local function tw(i,t,p)
    return TweenSvc:Create(i,TweenInfo.new(t,Enum.EasingStyle.Quad),p)
end
local function frame(par,bg,sz,pos,zi)
    local f=Instance.new("Frame"); f.BackgroundColor3=bg or TH.btn
    f.Size=sz or UDim2.new(1,0,0,36); f.Position=pos or UDim2.new(0,0,0,0)
    f.BorderSizePixel=0; f.ZIndex=zi or 2; f.Parent=par; return f
end
local function lbl(par,txt,sz,pos,fs,col,font,xa,zi)
    local l=Instance.new("TextLabel"); l.Text=txt or ""
    l.Size=sz or UDim2.new(1,0,1,0); l.Position=pos or UDim2.new(0,0,0,0)
    l.TextSize=fs or 11; l.TextColor3=col or TH.txt; l.Font=font or TH.font
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.BackgroundTransparency=1; l.ZIndex=zi or 3; l.Parent=par; return l
end
local function btn(par,txt,sz,pos,bg,fs,zi)
    local b=Instance.new("TextButton"); b.Text=txt or ""
    b.Size=sz or UDim2.new(1,0,0,32); b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or TH.btn; b.TextColor3=TH.txt; b.TextSize=fs or 11
    b.Font=TH.font; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.ZIndex=zi or 3; b.Parent=par; return b
end
local function imgbtn(par,img,sz,pos,bg,zi)
    local b=Instance.new("ImageButton"); b.Image=img or ""
    b.Size=sz or UDim2.new(0,26,0,26); b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or TH.btn; b.BorderSizePixel=0
    b.AutoButtonColor=false; b.ZIndex=zi or 3; b.Parent=par; return b
end
local function listlayout(par,dir,pad,sort)
    local l=Instance.new("UIListLayout")
    l.FillDirection=dir or Enum.FillDirection.Vertical
    l.SortOrder=sort or Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0,pad or 3); l.Parent=par; return l
end
local function pad(par,t,r,b,ll)
    local p=Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,t or 0); p.PaddingRight=UDim.new(0,r or 0)
    p.PaddingBottom=UDim.new(0,b or 0); p.PaddingLeft=UDim.new(0,ll or 0)
    p.Parent=par; return p
end
local function resolveParent()
    local p; pcall(function()
        if type(gethui)=="function" then p=gethui()
        elseif type(get_hidden_gui)=="function" then p=get_hidden_gui() end
    end); return p or game:GetService("CoreGui")
end

-- ── Global component registry (for Search tab) ────────────────────────────
local _registry = {}  -- {name, tabName, sectionName, rowFrame}

-- ══════════════════════════════════════════════════════════════════════════
--  CreateWindow
-- ══════════════════════════════════════════════════════════════════════════
function ScreenLibrary:CreateWindow(opts)
    opts = opts or {}
    local Title     = opts.Title     or "ScreenLibrary"
    local W         = opts.Width     or 360
    local H         = opts.Height    or 480
    local CreatorId = opts.CreatorId or 0
    local _accentRaw = opts.Accent or nil
    local Accent
    if type(_accentRaw) == "string" and #_accentRaw >= 6 then
        local r=tonumber(_accentRaw:sub(1,2),16)/255
        local g=tonumber(_accentRaw:sub(3,4),16)/255
        local b=tonumber(_accentRaw:sub(5,6),16)/255
        Accent = Color3.new(r,g,b)
    else
        Accent = _accentRaw or TH.accent
    end
    local GuiIcon   = opts.GuiIcon   or nil

    -- ── ScreenGui ─────────────────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "SL_"..Title:gsub("%s","")
    SG.ResetOnSpawn = false
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() SG.IgnoreGuiInset = true end)
    SG.Parent = resolveParent()

    -- ── Main Frame ────────────────────────────────────────────────────
    local TBAR_H   = 44
    local TABBAR_H = 36
    local FOOTER_H = 52

    local Main = frame(SG, TH.bg, UDim2.new(0,W,0,H),
        UDim2.new(0.5,-W/2,0.5,-H/2), 2)
    Main.Name = "Main"; Main.ClipsDescendants = true
    corner(Main, 12)

    -- Accent line
    local AccLine = frame(Main, Accent,
        UDim2.new(1,0,0,2), UDim2.new(0,0,0,TBAR_H), 4)

    -- ── Title bar drag ────────────────────────────────────────────────
    local _drag, _ds, _dp = false, nil, nil
    local TBar = frame(Main, TH.panel,
        UDim2.new(1,0,0,TBAR_H), UDim2.new(0,0,0,0), 3)
    TBar.Name = "TBar"

    TBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            _drag=true; _ds=inp.Position; _dp=Main.AbsolutePosition
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if _drag then
            local d = inp.Position - _ds
            Main.Position = UDim2.new(0,_dp.X+d.X,0,_dp.Y+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or
           inp.UserInputType==Enum.UserInputType.Touch then _drag=false end
    end)

    -- Header icon + title
    local tx = 10
    if GuiIcon then
        local ico=Instance.new("ImageLabel"); ico.Image=GuiIcon
        ico.Size=UDim2.new(0,24,0,24); ico.Position=UDim2.new(0,tx,0.5,-12)
        ico.BackgroundTransparency=1; ico.ZIndex=5; ico.Parent=TBar
        tx=tx+30
    end
    lbl(TBar, Title, UDim2.new(1,-130,1,0), UDim2.new(0,tx,0,0),
        13, TH.txt, TH.fontBold, Enum.TextXAlignment.Left, 4)

    -- Control buttons
    local BtnClose = imgbtn(TBar, A.Close,
        UDim2.new(0,26,0,26), UDim2.new(1,-32,0.5,-13), TH.red, 5)
    corner(BtnClose,6)
    local BtnMin = imgbtn(TBar, A.Minimize,
        UDim2.new(0,26,0,26), UDim2.new(1,-62,0.5,-13), TH.btn, 5)
    corner(BtnMin,6)
    local BtnCfg = imgbtn(TBar, A.Settings,
        UDim2.new(0,26,0,26), UDim2.new(1,-92,0.5,-13), TH.btn, 5)
    corner(BtnCfg,6)

    BtnClose.MouseButton1Click:Connect(function() SG:Destroy() end)

    local _minimized = false
    BtnMin.MouseButton1Click:Connect(function()
        _minimized = not _minimized
        tw(Main, 0.2, {Size=UDim2.new(0,W,0,_minimized and TBAR_H+2 or H)}):Play()
    end)

    -- ── Tab bar ───────────────────────────────────────────────────────
    local CTOP = TBAR_H+2
    local TabBG = frame(Main, TH.panel,
        UDim2.new(1,0,0,TABBAR_H), UDim2.new(0,0,0,CTOP), 3)

    local TabSF = Instance.new("ScrollingFrame")
    TabSF.Size=UDim2.new(1,-4,1,-4); TabSF.Position=UDim2.new(0,2,0,2)
    TabSF.BackgroundTransparency=1; TabSF.ScrollBarThickness=0
    TabSF.ScrollingDirection=Enum.ScrollingDirection.X
    TabSF.CanvasSize=UDim2.new(0,0,0,0)
    pcall(function() TabSF.AutomaticCanvasSize=Enum.AutomaticSize.X end)
    TabSF.ZIndex=4; TabSF.Parent=TabBG
    local TabLL = listlayout(TabSF, Enum.FillDirection.Horizontal, 4)
    TabLL.VerticalAlignment=Enum.VerticalAlignment.Center

    -- ── Page area ─────────────────────────────────────────────────────
    local PAGE_TOP = CTOP+TABBAR_H
    local PAGE_H   = H - PAGE_TOP - FOOTER_H

    local PageArea = frame(Main, TH.bg,
        UDim2.new(1,0,0,PAGE_H), UDim2.new(0,0,0,PAGE_TOP), 2)
    PageArea.ClipsDescendants=true

    -- ── Footer (creator card + stats) ─────────────────────────────────
    local Footer = frame(Main, TH.panel,
        UDim2.new(1,0,0,FOOTER_H), UDim2.new(0,0,1,-FOOTER_H), 3)
    corner(Footer,0)

    local CrABG = frame(Footer, Color3.fromRGB(28,28,40),
        UDim2.new(0,34,0,34), UDim2.new(0,7,0.5,-17), 4); corner(CrABG,17)
    local CrAvatar = Instance.new("ImageLabel")
    CrAvatar.Size=UDim2.new(1,0,1,0); CrAvatar.BackgroundTransparency=1
    CrAvatar.ZIndex=5; CrAvatar.Parent=CrABG; corner(CrAvatar,17)
    local CrName = lbl(Footer,"Loading...",
        UDim2.new(1,-120,0,17),UDim2.new(0,48,0,5),
        11,TH.txt,TH.fontBold,Enum.TextXAlignment.Left,4)
    local StatsL = lbl(Footer,"Players: -- | Ping: -- ms",
        UDim2.new(1,-52,0,13),UDim2.new(0,48,0,24),
        9,TH.sub,TH.font,Enum.TextXAlignment.Left,4)
    lbl(Footer,"ScreenLibrary",
        UDim2.new(0,80,0,11),UDim2.new(1,-83,1,-13),
        8,Color3.fromRGB(40,40,55),TH.font,Enum.TextXAlignment.Right,4)

    -- Fetch creator profile
    if CreatorId ~= 0 then
        task.spawn(function()
            local ok1,nm=pcall(function()
                return Players:GetNameFromUserIdAsync(CreatorId) end)
            if ok1 then pcall(function() CrName.Text=nm end) end
            local ok2,url=pcall(function()
                return Players:GetUserThumbnailAsync(CreatorId,
                    Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
            if ok2 then pcall(function() CrAvatar.Image=url end) end
        end)
    else
        CrName.Text = "Set CreatorId in config"
    end

    -- Stats ticker
    task.spawn(function()
        local Stats; pcall(function() Stats=game:GetService("Stats") end)
        while SG.Parent do
            pcall(function()
                local pc=#Players:GetPlayers()
                local ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"].Value)
                StatsL.Text=("Players: %d | Ping: %d ms"):format(pc,ping)
            end)
            task.wait(2)
        end
    end)

    -- ── Settings side-panel ────────────────────────────────────────────
    local SPW = 190
    local SP = frame(Main, TH.panel,
        UDim2.new(0,SPW,1,-(CTOP+FOOTER_H)),
        UDim2.new(1,0,0,CTOP), 8)
    SP.Visible=false; SP.ClipsDescendants=true
    -- slide from right
    local function _toggleSettings()
        SP.Visible=true
        if SP.Position==UDim2.new(1,0,0,CTOP) then
            tw(SP,0.2,{Position=UDim2.new(1,-SPW,0,CTOP)}):Play()
        else
            tw(SP,0.2,{Position=UDim2.new(1,0,0,CTOP)}):Play()
            task.delay(0.22,function() SP.Visible=false end)
        end
    end
    BtnCfg.MouseButton1Click:Connect(_toggleSettings)

    lbl(SP,"SETTINGS",UDim2.new(1,0,0,22),UDim2.new(0,0,0,4),
        9,TH.sub,TH.fontBold,Enum.TextXAlignment.Center,9)

    local SPLL=listlayout(SP,nil,4); SPLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    pad(SP,30,6,6,6)

    -- Opacity slider factory
    local function _spSlider(label,defV,onChange)
        local r=frame(SP,TH.btn,UDim2.new(1,0,0,44),nil,9); corner(r,6)
        lbl(r,label,UDim2.new(1,-36,0,16),UDim2.new(0,4,0,2),9,TH.txt,TH.font,Enum.TextXAlignment.Left,10)
        local vl=lbl(r,defV.."%",UDim2.new(0,30,0,14),UDim2.new(1,-32,0,4),9,Accent,TH.font,Enum.TextXAlignment.Right,10)
        local tk=frame(r,Color3.fromRGB(25,25,38),UDim2.new(1,-8,0,5),UDim2.new(0,4,0,28),10); corner(tk,3)
        local fl=frame(tk,Accent,UDim2.new(defV/100,0,1,0),UDim2.new(0,0,0,0),11); corner(fl,3)
        local sl=false
        local function _upd(px)
            local rel=math.clamp((px-tk.AbsolutePosition.X)/math.max(tk.AbsoluteSize.X,1),0,1)
            fl.Size=UDim2.new(rel,0,1,0); vl.Text=math.floor(rel*100).."%"
            pcall(onChange,rel)
        end
        tk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sl=true; _upd(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if sl then _upd(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sl=false end end)
        return r
    end
    _spSlider("Global Opacity",100,function(v) Main.BackgroundTransparency=1-v end)
    _spSlider("Notif Opacity",100,function() end)

    -- ── FPS / Ping Overlay ─────────────────────────────────────────────
    local FPSOv = frame(SG,TH.panel,UDim2.new(0,140,0,36),UDim2.new(0,10,0,10),20)
    corner(FPSOv,8); stroke(FPSOv,1,Accent,0.5)
    local FPSL=lbl(FPSOv,"FPS: -- | Ping: --",
        UDim2.new(1,-8,1,0),UDim2.new(0,6,0,0),9,TH.txt,TH.font,Enum.TextXAlignment.Left,21)

    local fpsDrag,fpsDrgS,fpsDrgP=false,nil,nil
    FPSOv.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            fpsDrag=true; fpsDrgS=i.Position; fpsDrgP=FPSOv.AbsolutePosition end
    end)
    UIS.InputChanged:Connect(function(i)
        if fpsDrag then local d=i.Position-fpsDrgS
            FPSOv.Position=UDim2.new(0,fpsDrgP.X+d.X,0,fpsDrgP.Y+d.Y) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fpsDrag=false end
    end)

    local _fps=0
    RunService.RenderStepped:Connect(function() _fps=_fps+1 end)
    task.spawn(function()
        while SG.Parent do
            local f=_fps; _fps=0; local ping=0
            pcall(function() local S=game:GetService("Stats")
                ping=math.floor(S.Network.ServerStatsItem["Data Ping"].Value) end)
            pcall(function() FPSL.Text=("FPS: %d | Ping: %d ms"):format(f,ping) end)
            task.wait(1)
        end
    end)

    -- ── Tab + Section + Component system ──────────────────────────────
    local _tabs    = {}  -- name → {page,ll,pageH,tabBtn}
    local _active  = nil

    local function _setActive(name)
        for n,t in pairs(_tabs) do
            t.page.Visible=(n==name)
            t.tabBtn.BackgroundColor3=(n==name) and Accent or TH.btn
        end
        _active=name
    end

    -- ── Popup helpers ──────────────────────────────────────────────────
    local function _infoPopup(msg)
        local p=frame(SG,TH.panel,UDim2.new(0,230,0,56),UDim2.new(0.5,-115,1,-70),50)
        corner(p,8); stroke(p,1,Accent,0.4)
        lbl(p,tostring(msg),UDim2.new(1,-12,1,-8),UDim2.new(0,6,0,4),10,TH.txt,TH.font,Enum.TextXAlignment.Left,51)
        p.BackgroundTransparency=1; tw(p,0.15,{BackgroundTransparency=0}):Play()
        task.delay(3,function() tw(p,0.15,{BackgroundTransparency=1}):Play()
            task.delay(0.2,function() pcall(function() p:Destroy() end) end) end)
    end

    local function _sliderInputPopup(curVal,min,max,onConfirm)
        local p=frame(SG,TH.panel,UDim2.new(0,210,0,72),UDim2.new(0.5,-105,0.5,-36),50)
        corner(p,8); stroke(p,1,Accent,0.4)
        lbl(p,"Enter value ("..min.."-"..max.."):",
            UDim2.new(1,-10,0,18),UDim2.new(0,6,0,4),10,TH.txt,TH.font,Enum.TextXAlignment.Left,51)
        local ibg=frame(p,TH.btn,UDim2.new(1,-52,0,24),UDim2.new(0,6,0,26),51); corner(ibg,4)
        local ib=Instance.new("TextBox")
        ib.Size=UDim2.new(1,-8,1,0); ib.Position=UDim2.new(0,4,0,0)
        ib.BackgroundTransparency=1; ib.TextColor3=TH.txt
        ib.TextSize=11; ib.Font=TH.font; ib.Text=tostring(curVal)
        ib.ClearTextOnFocus=false; ib.ZIndex=52; ib.Parent=ibg
        local ob=btn(p,"OK",UDim2.new(0,38,0,24),UDim2.new(1,-44,0,26),Accent,10,51)
        corner(ob,4)
        ob.MouseButton1Click:Connect(function()
            local v=tonumber(ib.Text)
            if v then pcall(onConfirm,math.clamp(math.floor(v+0.5),min,max)) end
            p:Destroy()
        end)
        task.delay(12,function() pcall(function() p:Destroy() end) end)
    end

    -- ── Dropdown popup ─────────────────────────────────────────────────
    local _activeDrop=nil
    local function _dropPopup(rowFrame,items,onSelect)
        if _activeDrop then _activeDrop:Destroy(); _activeDrop=nil end
        local ap=rowFrame.AbsolutePosition; local as=rowFrame.AbsoluteSize
        local DH=math.min(#items,5)*30+4
        local D=frame(SG,TH.panel,UDim2.new(0,as.X-8,0,DH),
            UDim2.new(0,ap.X+4,0,ap.Y+as.Y+2),60)
        corner(D,8); stroke(D,1,Accent,0.5); _activeDrop=D
        local DSF=Instance.new("ScrollingFrame")
        DSF.Size=UDim2.new(1,0,1,0); DSF.BackgroundTransparency=1
        DSF.ScrollBarThickness=2; DSF.CanvasSize=UDim2.new(0,0,0,#items*30)
        DSF.ZIndex=61; DSF.Parent=D
        listlayout(DSF,nil,2)
        for _,item in ipairs(items) do
            local ib=btn(DSF,item,UDim2.new(1,-4,0,28),nil,TH.btn,10,62)
            ib.TextXAlignment=Enum.TextXAlignment.Left
            local pp=Instance.new("UIPadding"); pp.PaddingLeft=UDim.new(0,8); pp.Parent=ib
            corner(ib,4)
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=Color3.fromRGB(32,32,46) end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=TH.btn end)
            ib.MouseButton1Click:Connect(function()
                D:Destroy(); _activeDrop=nil
                pcall(onSelect,item)
            end)
        end
        -- dismiss on outside touch
        local c; c=UIS.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or
               i.UserInputType==Enum.UserInputType.Touch then
                task.wait(0.05)
                if _activeDrop==D then D:Destroy(); _activeDrop=nil end
                c:Disconnect()
            end
        end)
    end

    -- ══════════════════════════════════════════════════════════════════
    --  _addTab  — creates a tab button + page + returns Tab object
    -- ══════════════════════════════════════════════════════════════════
    local _tabOrder=0
    local function _addTab(name,iconId)
        _tabOrder=_tabOrder+1
        -- Tab button width: icon adds 20px
        local bw=8+(#name*6.5)+8+(iconId and 20 or 0)
        local TB=btn(TabSF,name,UDim2.new(0,math.max(bw,56),0,26),nil,TH.btn,10,5)
        TB.LayoutOrder=_tabOrder; corner(TB,6)
        TB.TextXAlignment=iconId and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center
        if iconId then
            local ic=Instance.new("ImageLabel"); ic.Image=iconId
            ic.Size=UDim2.new(0,14,0,14); ic.Position=UDim2.new(0,6,0.5,-7)
            ic.BackgroundTransparency=1; ic.ZIndex=6; ic.Parent=TB
            local tp=Instance.new("UIPadding"); tp.PaddingRight=UDim.new(0,6); tp.Parent=TB
        end

        -- Page
        local Page=Instance.new("ScrollingFrame")
        Page.Name="Page_"..name
        Page.Size=UDim2.new(1,0,1,0)
        Page.BackgroundTransparency=1
        Page.BorderSizePixel=0
        Page.ScrollBarThickness=2
        Page.ScrollBarImageColor3=Accent
        Page.CanvasSize=UDim2.new(0,0,0,0)
        pcall(function() Page.AutomaticCanvasSize=Enum.AutomaticSize.None end)
        Page.ZIndex=3; Page.Visible=false; Page.Parent=PageArea

        local PLL=listlayout(Page,nil,4)
        pad(Page,4,5,4,5)

        -- Page canvas tracker
        local _pH=4
        local function _bumpPage(h)
            _pH=_pH+h+4
            pcall(function() Page.CanvasSize=UDim2.new(0,0,0,_pH) end)
        end

        _tabs[name]={page=Page,ll=PLL,pageH=_pH,tabBtn=TB,bumpPage=_bumpPage}

        TB.MouseButton1Click:Connect(function() _setActive(name) end)

        -- ── Tab object returned to caller ─────────────────────────────
        local Tab={}

        -- ════════════════════════════════════════════════════════════
        --  AddSection
        -- ════════════════════════════════════════════════════════════
        function Tab:AddSection(secName)
            local _open=true
            local _cH=0   -- content height tracker

            -- Section outer frame
            local SC=frame(Page,TH.panel,UDim2.new(1,0,0,28),nil,3)
            SC.Name="Sec_"..(secName or "")
            SC.LayoutOrder=_tabOrder*100+(_tabs[name] and 0 or 0)
            SC.ClipsDescendants=true; corner(SC,8)
            _bumpPage(28)

            -- Section header button
            local SHdr=btn(SC,"",UDim2.new(1,0,0,28),UDim2.new(0,0,0,0),
                Color3.fromRGB(20,20,30),0,4)
            SHdr.LayoutOrder=0
            lbl(SHdr,secName or "Section",
                UDim2.new(1,-28,1,0),UDim2.new(0,10,0,0),
                11,TH.txt,TH.fontBold,Enum.TextXAlignment.Left,5)
            local SArrow=lbl(SHdr,"[v]",
                UDim2.new(0,22,1,0),UDim2.new(1,-24,0,0),
                10,Accent,TH.font,Enum.TextXAlignment.Center,5)

            -- Content frame
            local SCon=frame(SC,TH.panel,UDim2.new(1,0,0,0),UDim2.new(0,0,0,28),3)
            SCon.ClipsDescendants=false
            local SCLL=listlayout(SCon,nil,3)
            pad(SCon,3,4,3,4)

            local function _bumpSec(h)
                _cH=_cH+h+3
                SCon.Size=UDim2.new(1,0,0,_cH)
                SC.Size=UDim2.new(1,0,0,28+_cH)
                _bumpPage(h+3)
            end

            SHdr.MouseButton1Click:Connect(function()
                _open=not _open
                SArrow.Text=_open and "[v]" or "[^]"
                if _open then
                    SCon.Visible=true
                    SC.Size=UDim2.new(1,0,0,28+_cH)
                    _tabs[name]._pH=_tabs[name]._pH+_cH
                else
                    SC.Size=UDim2.new(1,0,0,28)
                    _tabs[name]._pH=_tabs[name]._pH-_cH
                    task.delay(0.01,function() SCon.Visible=false end)
                end
                pcall(function() Page.CanvasSize=UDim2.new(0,0,0,_tabs[name]._pH) end)
            end)

            -- ── Row factory ───────────────────────────────────────────
            local _rowOrd=0
            local ROW_H=36
            local function _row(desc,h)
                _rowOrd=_rowOrd+1
                local r=frame(SCon,TH.btn,UDim2.new(1,0,0,h or ROW_H),nil,4)
                r.LayoutOrder=_rowOrd; corner(r,6)
                -- Three-dots button
                local dBtn=imgbtn(r,A.Dots,UDim2.new(0,20,0,20),
                    UDim2.new(1,-22,0.5,-10),Color3.fromRGB(0,0,0),5)
                dBtn.BackgroundTransparency=1
                if desc and desc~="" then
                    dBtn.MouseButton1Click:Connect(function() _infoPopup(desc) end)
                end
                _bumpSec(h or ROW_H)
                return r
            end

            -- Hover helper
            local function _hover(r,clk)
                clk.MouseEnter:Connect(function()
                    tw(r,0.1,{BackgroundColor3=Color3.fromRGB(30,30,44)}):Play() end)
                clk.MouseLeave:Connect(function()
                    tw(r,0.1,{BackgroundColor3=TH.btn}):Play() end)
            end

            local Section={}

            -- ── AddButton ─────────────────────────────────────────────
            function Section:AddButton(o)
                o=o or {}
                local n=o.Name or "Button"; local cb=o.Callback or function()end
                local r=_row(o.Description)
                local bi=Instance.new("ImageLabel"); bi.Image=A.BtnBG
                bi.Size=UDim2.new(1,0,1,0); bi.BackgroundTransparency=1; bi.ZIndex=4; bi.Parent=r
                local nl=lbl(r,n,UDim2.new(1,-28,1,0),UDim2.new(0,10,0,0),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local clk=btn(r,"",UDim2.new(1,-24,1,0),UDim2.new(0,0,0,0),
                    Color3.fromRGB(0,0,0),0,6); clk.BackgroundTransparency=1
                clk.MouseButton1Click:Connect(function() pcall(cb) end)
                _hover(r,clk)
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {SetName=function(_,v) nl.Text=v end}
            end

            -- ── AddToggle ─────────────────────────────────────────────
            function Section:AddToggle(o)
                o=o or {}
                local n=o.Name or "Toggle"; local val=o.Default or false
                local cb=o.Callback or function()end
                local r=_row(o.Description)
                lbl(r,n,UDim2.new(1,-72,1,0),UDim2.new(0,10,0,0),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                -- Geometric (rounded-rect) toggle
                local tbg=frame(r,val and Accent or Color3.fromRGB(30,30,44),
                    UDim2.new(0,42,0,22),UDim2.new(1,-66,0.5,-11),5)
                corner(tbg,4)
                local tknob=frame(tbg,Color3.new(1,1,1),
                    UDim2.new(0,16,0,16),UDim2.new(0,val and 22 or 3,0.5,-8),6)
                corner(tknob,3)
                local on=val

                local function _set(v)
                    on=v
                    tw(tbg,0.15,{BackgroundColor3=v and Accent or Color3.fromRGB(30,30,44)}):Play()
                    tw(tknob,0.15,{Position=UDim2.new(0,v and 22 or 3,0.5,-8)}):Play()
                    pcall(cb,v)
                end

                local clk=btn(r,"",UDim2.new(1,-24,1,0),nil,Color3.fromRGB(0,0,0),0,7)
                clk.BackgroundTransparency=1
                clk.MouseButton1Click:Connect(function() _set(not on) end)
                if val then pcall(cb,val) end
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {Set=function(_,v) _set(v) end, Get=function() return on end}
            end

            -- ── AddSlider ─────────────────────────────────────────────
            function Section:AddSlider(o)
                o=o or {}
                local n=o.Name or "Slider"; local min=o.Min or 0
                local max=o.Max or 100; local def=o.Default or min
                local cb=o.Callback or function()end
                local r=_row(o.Description,50)  -- taller row
                local cv=math.clamp(def,min,max)
                lbl(r,n,UDim2.new(1,-60,0,16),UDim2.new(0,10,0,4),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local vl=lbl(r,tostring(cv),UDim2.new(0,46,0,16),
                    UDim2.new(1,-54,0,4),10,Accent,TH.font,Enum.TextXAlignment.Right,5)
                local tk=frame(r,Color3.fromRGB(24,24,36),
                    UDim2.new(1,-16,0,6),UDim2.new(0,8,0,32),5); corner(tk,3)
                local fl=frame(tk,Accent,UDim2.new((cv-min)/math.max(max-min,1),0,1,0),
                    UDim2.new(0,0,0,0),6); corner(fl,3)

                local function _upd(px)
                    local rel=math.clamp((px-tk.AbsolutePosition.X)/math.max(tk.AbsoluteSize.X,1),0,1)
                    cv=min+math.floor(rel*(max-min)+0.5)
                    fl.Size=UDim2.new(rel,0,1,0); vl.Text=tostring(cv); pcall(cb,cv)
                end

                local sl=false
                tk.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or
                       i.UserInputType==Enum.UserInputType.Touch then sl=true; _upd(i.Position.X) end
                end)
                UIS.InputChanged:Connect(function(i)
                    if sl and (i.UserInputType==Enum.UserInputType.MouseMovement or
                       i.UserInputType==Enum.UserInputType.Touch) then _upd(i.Position.X) end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or
                       i.UserInputType==Enum.UserInputType.Touch then sl=false end
                end)

                -- Three-dots → direct number input
                local dBtn=r:FindFirstChildOfClass("ImageButton")
                if dBtn then
                    dBtn.MouseButton1Click:Connect(function()
                        _sliderInputPopup(cv,min,max,function(v)
                            cv=v; local rel=(cv-min)/math.max(max-min,1)
                            fl.Size=UDim2.new(rel,0,1,0); vl.Text=tostring(cv); pcall(cb,cv)
                        end)
                    end)
                end

                pcall(cb,cv)
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {
                    Set=function(_,v)
                        cv=math.clamp(v,min,max)
                        fl.Size=UDim2.new((cv-min)/math.max(max-min,1),0,1,0)
                        vl.Text=tostring(cv)
                    end,
                    Get=function() return cv end,
                }
            end

            -- ── AddDropdown ───────────────────────────────────────────
            function Section:AddDropdown(o)
                o=o or {}
                local n=o.Name or "Dropdown"; local items=o.Items or {}
                local def=o.Default or (items[1] or ""); local cb=o.Callback or function()end
                local r=_row(o.Description)
                lbl(r,n,UDim2.new(0.48,0,1,0),UDim2.new(0,10,0,0),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local sel=def
                local sl=lbl(r,def,UDim2.new(0.38,-8,1,0),UDim2.new(0.48,4,0,0),
                    10,Accent,TH.font,Enum.TextXAlignment.Right,5)
                local clk=btn(r,"",UDim2.new(1,-24,1,0),nil,Color3.fromRGB(0,0,0),0,6)
                clk.BackgroundTransparency=1
                clk.MouseButton1Click:Connect(function()
                    _dropPopup(r,items,function(v) sel=v; sl.Text=v; pcall(cb,v) end)
                end)
                pcall(cb,def)
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {
                    Set=function(_,v) sel=v; sl.Text=v end,
                    Get=function() return sel end,
                    SetItems=function(_,ni) items=ni end,
                }
            end

            -- ── AddInput ──────────────────────────────────────────────
            function Section:AddInput(o)
                o=o or {}
                local n=o.Name or "Input"; local cb=o.Callback or function()end
                local r=_row(o.Description,50)
                lbl(r,n,UDim2.new(1,-30,0,16),UDim2.new(0,10,0,4),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local ibg=frame(r,Color3.fromRGB(14,14,20),
                    UDim2.new(1,-52,0,22),UDim2.new(0,8,0,24),5); corner(ibg,4)
                local ib=Instance.new("TextBox")
                ib.PlaceholderText=o.Placeholder or "Type here..."
                ib.Text=o.Default or ""
                ib.Size=UDim2.new(1,-8,1,0); ib.Position=UDim2.new(0,4,0,0)
                ib.BackgroundTransparency=1; ib.TextColor3=TH.txt
                ib.PlaceholderColor3=TH.sub; ib.TextSize=10; ib.Font=TH.font
                ib.TextXAlignment=Enum.TextXAlignment.Left
                ib.ClearTextOnFocus=false; ib.ZIndex=6; ib.Parent=ibg
                local ob=btn(r,"OK",UDim2.new(0,36,0,22),UDim2.new(1,-44,0,24),Accent,9,5)
                corner(ob,4)
                ob.MouseButton1Click:Connect(function() pcall(cb,ib.Text) end)
                ib.FocusLost:Connect(function(enter) if enter then pcall(cb,ib.Text) end end)
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {SetText=function(_,t) ib.Text=t end, GetText=function() return ib.Text end}
            end

            -- ── AddKeybind ────────────────────────────────────────────
            function Section:AddKeybind(o)
                o=o or {}
                local n=o.Name or "Keybind"; local cb=o.Callback or function()end
                local def=o.Default or Enum.KeyCode.Unknown; local cur=def
                local r=_row(o.Description)
                lbl(r,n,UDim2.new(1,-90,1,0),UDim2.new(0,10,0,0),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local kb=btn(r,tostring(def):gsub("Enum.KeyCode.",""),
                    UDim2.new(0,64,0,24),UDim2.new(1,-88,0.5,-12),
                    Color3.fromRGB(24,24,38),10,5); corner(kb,5)
                local listening=false
                kb.MouseButton1Click:Connect(function()
                    if listening then return end; listening=true; kb.Text="..."
                    local c; c=UIS.InputBegan:Connect(function(i,gpe)
                        if gpe then return end
                        if i.UserInputType==Enum.UserInputType.Keyboard then
                            cur=i.KeyCode; kb.Text=tostring(i.KeyCode):gsub("Enum.KeyCode.","")
                            listening=false; c:Disconnect()
                        end
                    end)
                end)
                UIS.InputBegan:Connect(function(i,gpe)
                    if gpe or listening then return end
                    if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==cur then
                        pcall(cb)
                    end
                end)
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {Get=function() return cur end,
                        Set=function(_,k) cur=k; kb.Text=tostring(k):gsub("Enum.KeyCode.","") end}
            end

            -- ── AddLabel ──────────────────────────────────────────────
            function Section:AddLabel(text)
                _rowOrd=_rowOrd+1
                local r=frame(SCon,Color3.fromRGB(17,17,25),
                    UDim2.new(1,0,0,24),nil,4); r.LayoutOrder=_rowOrd; corner(r,5)
                local L=lbl(r,tostring(text or ""),UDim2.new(1,-12,1,0),
                    UDim2.new(0,8,0,0),10,TH.sub,TH.font,Enum.TextXAlignment.Left,5)
                _bumpSec(24)
                return {SetText=function(_,t) L.Text=t end}
            end

            -- ── AddSeparator ──────────────────────────────────────────
            function Section:AddSeparator()
                _rowOrd=_rowOrd+1
                local r=frame(SCon,Color3.fromRGB(28,28,40),
                    UDim2.new(1,-12,0,1),UDim2.new(0,6,0,0),4)
                r.LayoutOrder=_rowOrd; _bumpSec(1)
            end

            -- ── AddCheckbox ───────────────────────────────────────────
            function Section:AddCheckbox(o)
                o=o or {}
                local n=o.Name or "Checkbox"; local def=o.Default or false
                local cb=o.Callback or function()end
                local r=_row(o.Description)
                lbl(r,n,UDim2.new(1,-52,1,0),UDim2.new(0,10,0,0),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local ck=def
                local bx=frame(r,ck and Accent or Color3.fromRGB(24,24,38),
                    UDim2.new(0,20,0,20),UDim2.new(1,-46,0.5,-10),5); corner(bx,4)
                local cm=lbl(bx,ck and "x" or "",UDim2.new(1,0,1,0),nil,
                    13,Color3.new(1,1,1),TH.fontBold,Enum.TextXAlignment.Center,6)
                local clk=btn(r,"",UDim2.new(1,-24,1,0),nil,Color3.fromRGB(0,0,0),0,7)
                clk.BackgroundTransparency=1
                clk.MouseButton1Click:Connect(function()
                    ck=not ck; bx.BackgroundColor3=ck and Accent or Color3.fromRGB(24,24,38)
                    cm.Text=ck and "x" or ""; pcall(cb,ck)
                end)
                if def then pcall(cb,def) end
                table.insert(_registry,{name=n,tabName=name,secName=secName,row=r})
                return {Get=function() return ck end,
                        Set=function(_,v) ck=v; bx.BackgroundColor3=v and Accent or Color3.fromRGB(24,24,38); cm.Text=v and "x" or "" end}
            end

            -- ── AddProgressBar ────────────────────────────────────────
            function Section:AddProgressBar(o)
                o=o or {}
                local n=o.Name or "Progress"; local iv=o.Value or 0
                local r=_row(o.Description,42)
                lbl(r,n,UDim2.new(1,-48,0,16),UDim2.new(0,10,0,4),
                    11,TH.txt,TH.font,Enum.TextXAlignment.Left,5)
                local pv=lbl(r,iv.."%",UDim2.new(0,38,0,16),UDim2.new(1,-44,0,4),
                    10,Accent,TH.font,Enum.TextXAlignment.Right,5)
                local pt=frame(r,Color3.fromRGB(24,24,38),UDim2.new(1,-16,0,6),
                    UDim2.new(0,8,0,30),5); corner(pt,3)
                local pf=frame(pt,Accent,UDim2.new(math.clamp(iv/100,0,1),0,1,0),
                    UDim2.new(0,0,0,0),6); corner(pf,3)
                return {
                    Set=function(_,v) v=math.clamp(v,0,100)
                        pf.Size=UDim2.new(v/100,0,1,0); pv.Text=v.."%" end,
                    Get=function() return math.floor(pf.Size.X.Scale*100) end,
                }
            end

            -- ── AddListbox ────────────────────────────────────────────
            function Section:AddListbox(o)
                o=o or {}
                local n=o.Name or "Listbox"; local items=o.Items or {}
                local cb=o.Callback or function()end
                local lbH=28+math.min(#items,4)*28
                local r=_row(o.Description,lbH)
                lbl(r,n,UDim2.new(1,-12,0,20),UDim2.new(0,8,0,4),
                    11,TH.txt,TH.fontBold,Enum.TextXAlignment.Left,5)
                local sf=Instance.new("ScrollingFrame")
                sf.Size=UDim2.new(1,-10,0,lbH-28); sf.Position=UDim2.new(0,5,0,24)
                sf.BackgroundColor3=Color3.fromRGB(13,13,19); sf.BorderSizePixel=0
                sf.ScrollBarThickness=2; sf.CanvasSize=UDim2.new(0,0,0,#items*26)
                sf.ZIndex=5; sf.Parent=r; corner(sf,4)
                listlayout(sf,nil,1)
                local sel=nil
                for _,item in ipairs(items) do
                    local ib=btn(sf,item,UDim2.new(1,0,0,24),nil,TH.btn,10,6)
                    ib.TextXAlignment=Enum.TextXAlignment.Left
                    local tp=Instance.new("UIPadding"); tp.PaddingLeft=UDim.new(0,6); tp.Parent=ib
                    ib.MouseButton1Click:Connect(function()
                        sel=item; ib.BackgroundColor3=Accent
                        task.delay(0.2,function() pcall(function() ib.BackgroundColor3=TH.btn end) end)
                        pcall(cb,item)
                    end)
                end
                return {Get=function() return sel end}
            end

            -- ── AddMultibox ───────────────────────────────────────────
            function Section:AddMultibox(o)
                o=o or {}
                local n=o.Name or "Multibox"; local items=o.Items or {}
                local cb=o.Callback or function()end
                local mbH=28+math.min(#items,4)*28
                local r=_row(o.Description,mbH)
                lbl(r,n,UDim2.new(1,-12,0,20),UDim2.new(0,8,0,4),
                    11,TH.txt,TH.fontBold,Enum.TextXAlignment.Left,5)
                local sf=Instance.new("ScrollingFrame")
                sf.Size=UDim2.new(1,-10,0,mbH-28); sf.Position=UDim2.new(0,5,0,24)
                sf.BackgroundColor3=Color3.fromRGB(13,13,19); sf.BorderSizePixel=0
                sf.ScrollBarThickness=2; sf.CanvasSize=UDim2.new(0,0,0,#items*26)
                sf.ZIndex=5; sf.Parent=r; corner(sf,4)
                listlayout(sf,nil,1)
                local sel={}
                for _,item in ipairs(items) do
                    local ib=btn(sf,"[ ] "..item,UDim2.new(1,0,0,24),nil,TH.btn,10,6)
                    ib.TextXAlignment=Enum.TextXAlignment.Left
                    local tp=Instance.new("UIPadding"); tp.PaddingLeft=UDim.new(0,4); tp.Parent=ib
                    ib.MouseButton1Click:Connect(function()
                        if sel[item] then sel[item]=nil; ib.Text="[ ] "..item
                        else sel[item]=true; ib.Text="[x] "..item end
                        local out={}; for k in pairs(sel) do table.insert(out,k) end
                        pcall(cb,out)
                    end)
                end
                return {Get=function()
                    local out={}; for k in pairs(sel) do table.insert(out,k) end; return out end}
            end

            return Section
        end  -- AddSection

        return Tab
    end  -- _addTab

    -- ══════════════════════════════════════════════════════════════════
    --  Built-in Tabs
    -- ══════════════════════════════════════════════════════════════════

    -- Main tab
    local MainTab = _addTab("Main", A.TabMain)

    -- Config tab
    local ConfigTab = _addTab("Config", A.TabConfig)
    do
        local CS = ConfigTab:AddSection("Config")
        CS:AddButton({Name="Save Config", Description="Saves config to a local file",
            Callback=function()
                pcall(function()
                    local data={}
                    if writefile then
                        writefile("SL_config.json", HttpSvc:JSONEncode(data))
                    end
                end)
            end})
        CS:AddButton({Name="Load Config", Description="Loads config from local file",
            Callback=function()
                pcall(function()
                    if readfile then
                        local _=HttpSvc:JSONDecode(readfile("SL_config.json"))
                    end
                end)
            end})
        CS:AddToggle({Name="Auto-Load Config",
            Description="Apply saved config automatically on next load",
            Default=false, Callback=function()end})
    end

    -- Search tab
    local SearchTab = _addTab("Search", A.TabSearch)
    do
        local SS = SearchTab:AddSection("Search")
        local resultSec = SearchTab:AddSection("Results")
        -- Search input
        local _lastResults = {}
        local searchCtrl = SS:AddInput({
            Name="Search Components", Placeholder="Component name...",
            Callback=function(text)
                -- Clear previous result labels
                for _,ctrl in ipairs(_lastResults) do
                    pcall(function() ctrl.row:Destroy() end)
                end
                _lastResults={}
                local q=text:lower()
                for _,entry in ipairs(_registry) do
                    if entry.name:lower():find(q,1,true) then
                        local lctrl=resultSec:AddLabel(
                            entry.name.." ["..entry.tabName.."/"..entry.secName.."]")
                        table.insert(_lastResults,{row=lctrl})
                    end
                end
            end,
        })
    end

    -- Activate Main by default
    _setActive("Main")

    -- ══════════════════════════════════════════════════════════════════
    --  Window API
    -- ══════════════════════════════════════════════════════════════════
    local Window = {}

    function Window:GetMainTab()    return MainTab    end
    function Window:GetConfigTab()  return ConfigTab  end
    function Window:GetSearchTab()  return SearchTab  end

    function Window:AddTab(name, iconId)
        local t = _addTab(name, iconId)
        return t
    end

    function Window:Notify(msg, dur)
        dur = dur or 3
        local notif=frame(SG,TH.panel,UDim2.new(0,230,0,44),
            UDim2.new(1,-238,1,-58),30)
        corner(notif,8); stroke(notif,1,Accent,0.5)
        lbl(notif,tostring(msg),UDim2.new(1,-12,1,0),
            UDim2.new(0,8,0,0),10,TH.txt,TH.font,Enum.TextXAlignment.Left,31)
        notif.BackgroundTransparency=1
        tw(notif,0.18,{BackgroundTransparency=0}):Play()
        task.delay(dur,function()
            tw(notif,0.18,{BackgroundTransparency=1}):Play()
            task.delay(0.22,function() pcall(function() notif:Destroy() end) end)
        end)
    end

    function Window:SetAccent(hex)
        local r=tonumber(hex:sub(1,2),16)/255
        local g=tonumber(hex:sub(3,4),16)/255
        local b=tonumber(hex:sub(5,6),16)/255
        Accent=Color3.new(r,g,b)
        AccLine.BackgroundColor3=Accent
    end

    function Window:SetTitle(t) lbl(TBar,t) end

    return Window
end

return ScreenLibrary
