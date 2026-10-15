--[[ SxHub - FINAL BUILD v1.4 (Black Hole Suction) ]]
local P=game:GetService("Players")local CG=game:GetService("CoreGui")local U=game:GetService("UserInputService")local T=game:GetService("TweenService")local R=game:GetService("RunService")local LP=P.LocalPlayer
local C={bg=Color3.fromRGB(15,8,25),pn=Color3.fromRGB(22,12,38),pl=Color3.fromRGB(35,20,60),ac=Color3.fromRGB(160,60,255),gl=Color3.fromRGB(200,120,255),ad=Color3.fromRGB(90,30,160),tx=Color3.fromRGB(230,220,255),td=Color3.fromRGB(140,120,180),st=Color3.fromRGB(80,40,140),dg=Color3.fromRGB(255,70,130),sc=Color3.fromRGB(80,255,180)}
local ES,ED=Enum.EasingStyle,Enum.EasingDirection
local conns={}
local function Con(sig,fn)local c=sig:Connect(fn)table.insert(conns,c)return c end
local function N(c,p)local o=Instance.new(c)for k,v in pairs(p or{})do o[k]=v end return o end
local function Cn(p,r)return N("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})end
local function Sk(p,c,t,tr)return N("UIStroke",{Color=c or C.st,Thickness=t or 1,Transparency=tr or .3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p})end
local function Tw(o,t,p,s,d)local a=T:Create(o,TweenInfo.new(t or .3,s or ES.Quint,d or ED.Out),p)a:Play()return a end
local function Loop(o,t,p,s)T:Create(o,TweenInfo.new(t,s or ES.Sine,ED.InOut,-1,true),p):Play()end
local U2=function(x,y)return UDim2.new(0,x,0,y)end
local GLOW="rbxassetid://5028857084"
local SLICE=Rect.new(24,24,276,276)
local G0=workspace.Gravity
local F0=workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70

local g=N("ScreenGui",{Name="SxHub",ResetOnSpawn=false,IgnoreGuiInset=true})
local ok=pcall(function()g.Parent=CG end)if not ok then g.Parent=LP:WaitForChild("PlayerGui")end

local state="busy"

-- ===== MAIN WINDOW =====
local M=N("Frame",{Size=U2(560,400),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false,Parent=g})
local MS=N("UIScale",{Scale=0,Parent=M})
Cn(M,12)
local Mstk=Sk(M,Color3.new(1,1,1),1.5,.15)
local Mgrad=N("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.ac),ColorSequenceKeypoint.new(.5,C.gl),ColorSequenceKeypoint.new(1,C.ac)}),Parent=Mstk})

-- ===== FLOATING ICON (BLACK HOLE) =====
local IS=60
local WARM=Color3.fromRGB(255,170,80)
local HOT=Color3.fromRGB(255,235,200)
local WHITE=Color3.new(1,1,1)
-- ===== UNIVERSE BG (dibuat duluan biar di belakang UI) =====
local BGL=N("Frame",{Name="Space",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=1,Parent=M})
Cn(BGL,12)
local stars={}
for k=1,45 do
local s=math.random(2,3)
local f=N("Frame",{Size=U2(s,s),Position=UDim2.fromScale(math.random(),math.random()),BackgroundColor3=(k%4==0)and C.gl or WHITE,BackgroundTransparency=.3,BorderSizePixel=0,ZIndex=1,Parent=BGL})
Cn(f,3)
stars[k]={f=f,sp=.6+math.random()*1.6,ph=math.random()*6.28}
end
local SH={}
for k=1,3 do
local f=N("Frame",{AnchorPoint=Vector2.new(1,.5),Size=U2(80,2),BackgroundColor3=WHITE,BorderSizePixel=0,Rotation=30,Visible=false,ZIndex=1,Parent=BGL})
N("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Parent=f})
SH[k]={f=f,d=0,t0=0,x=0,y=0,nx=os.clock()+k*1.2}
end
local I=N("Frame",{Size=U2(IS,IS),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,50,.5,0),BackgroundTransparency=1,Visible=false,Parent=g})
local ISc=N("UIScale",{Scale=0,Parent=I})

-- halo statis tipis (gak berdenyut)
local Halo=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(78,78),BackgroundColor3=C.ad,BackgroundTransparency=.82,BorderSizePixel=0,ZIndex=1,Parent=I})
Cn(Halo,200)

-- cincin busur muter (ukuran tetap, searah partikel)
local RN=4
local RD={86,72,58,46}
local rings={}
for k=1,RN do
local r=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(RD[k],RD[k]),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1,Parent=I})
Cn(r,200)
local s=N("UIStroke",{Color=(k%2==0)and C.gl or C.ac,Thickness=1+k*.4,Transparency=.2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=r})
local gr=N("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(.5,1),NumberSequenceKeypoint.new(1,1)}),Parent=s})
rings[k]={f=r,s=s,g=gr}
end

-- helper: satu lapis disk (pil, pinggir kiri-kanan fade halus)
local FADE=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.25,0),NumberSequenceKeypoint.new(.75,0),NumberSequenceKeypoint.new(1,1)})
local function Layer(par,w,h,col,tr,cy)
local e=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,cy,0),Size=U2(w,h),BackgroundColor3=col,BackgroundTransparency=tr,BorderSizePixel=0,Parent=par})
Cn(e,100)
N("UIGradient",{Transparency=FADE,Parent=e})
return e end
local function Streak(par,cy)
local e=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,cy,0),Size=U2(64,9),BackgroundColor3=WHITE,BackgroundTransparency=.1,BorderSizePixel=0,Parent=par})
Cn(e,100)
return N("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.38,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(.62,1),NumberSequenceKeypoint.new(1,1)}),Parent=e})
end
local function BuildDisk(par,cy)
Layer(par,80,30,C.ac,.45,cy)
Layer(par,74,22,C.gl,.35,cy)
Layer(par,62,16,WARM,.22,cy)
Layer(par,50,9,HOT,.1,cy)
return Streak(par,cy)
end

-- disk belakang
local DiskB=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(90,40),BackgroundTransparency=1,ZIndex=2,Parent=I})
local StreakB=BuildDisk(DiskB,.5)

-- lubang hitam + cincin foton
local Hole=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(32,32),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=3,Parent=I})
Cn(Hole,100)
local Pstk=N("UIStroke",{Color=Color3.fromRGB(255,235,215),Thickness=1.5,Transparency=.15,Parent=Hole})
Loop(Pstk,1.3,{Thickness=2.6,Transparency=.4})

-- busur lensa gravitasi
local Arc=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(40,40),BackgroundTransparency=1,ZIndex=4,Parent=I})
Cn(Arc,100)
local Astk=N("UIStroke",{Color=WARM,Thickness=3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Arc})
N("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(.35,.45),NumberSequenceKeypoint.new(.5,1),NumberSequenceKeypoint.new(1,1)}),Parent=Astk})
Loop(Astk,1.8,{Thickness=1.6})

-- disk depan
local DiskF=N("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.5),Size=U2(90,17),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=5,Parent=I})
local StreakF=BuildDisk(DiskF,0)

-- partikel kesedot spiral
local PN=12
local parts={}
for k=1,PN do
local d=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=U2(3,3),BackgroundColor3=(k%3==0)and WARM or((k%2==0)and C.gl or WHITE),BorderSizePixel=0,ZIndex=6,Parent=I})
Cn(d,2)
parts[k]=d
end

-- tombol hit
local IB=N("TextButton",{Size=UDim2.fromScale(1,1),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundTransparency=1,Text="",AutoButtonColor=false,BorderSizePixel=0,ZIndex=10,Parent=I})

-- animasi (berbasis os.clock, wrap mulus)
Con(R.Heartbeat,function()
local t=os.clock()
if I.Visible then
local o=((t*.55)%1)*2-1
StreakB.Offset=Vector2.new(o,0)
StreakF.Offset=Vector2.new(o,0)
for k,r in ipairs(rings)do
r.g.Rotation=(t*(70+k*45)+k*90)%360
end
for k,d in ipairs(parts)do
local p=(t*.3+k/PN)%1
local r=8+34*(1-p)^1.3
local a=k*2.4+p*math.pi*3.2
d.Position=UDim2.new(.5,math.cos(a)*r,.5,math.sin(a)*r)
local s=math.max(1.5,4*(1-p))
d.Size=U2(s,s)
d.BackgroundTransparency=1-math.sin(p*math.pi)
end
end
if M.Visible then Mgrad.Rotation=(t*30)%360 end
end)

-- ===== TITLEBAR =====
local TB=N("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=C.pn,BorderSizePixel=0,Parent=M})
Cn(TB,12)
N("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=C.pn,BorderSizePixel=0,Parent=TB})
N("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,1,-1),BackgroundColor3=C.ac,BorderSizePixel=0,Parent=TB})
N("TextLabel",{Size=UDim2.new(1,-100,0,24),Position=UDim2.new(0,16,0,4),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="SxHub",TextColor3=C.gl,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
N("TextLabel",{Size=UDim2.new(1,-100,0,16),Position=UDim2.new(0,16,0,26),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Universal • v1.4",TextColor3=C.td,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local CB=N("TextButton",{Size=U2(28,28),Position=UDim2.new(1,-38,0,10),BackgroundColor3=C.ad,Text="×",Font=Enum.Font.GothamBold,TextSize=20,TextColor3=C.tx,AutoButtonColor=false,BorderSizePixel=0,Parent=TB})
Cn(CB,6)
local MB=N("TextButton",{Size=U2(28,28),Position=UDim2.new(1,-72,0,10),BackgroundColor3=C.ad,Text="—",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=C.tx,AutoButtonColor=false,BorderSizePixel=0,Parent=TB})
Cn(MB,6)
Con(CB.MouseEnter,function()Tw(CB,.15,{BackgroundColor3=C.dg})end)
Con(CB.MouseLeave,function()Tw(CB,.15,{BackgroundColor3=C.ad})end)
Con(MB.MouseEnter,function()Tw(MB,.15,{BackgroundColor3=C.ac})end)
Con(MB.MouseLeave,function()Tw(MB,.15,{BackgroundColor3=C.ad})end)

-- ===== DRAG WINDOW =====
do local dg,ds,sp
Con(TB.InputBegan,function(i)if state~="open"then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true ds=i.Position sp=M.Position end end)
Con(U.InputChanged,function(i)if dg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-ds M.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
Con(U.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
end

-- ===== SIDEBAR =====
local SB=N("Frame",{Size=UDim2.new(0,140,1,-60),Position=U2(10,52),BackgroundColor3=C.pn,BorderSizePixel=0,Parent=M})
Cn(SB,10)Sk(SB,C.st,1,.6)
N("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=SB})
N("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),Parent=SB})

-- ===== CONTENT =====
local CT=N("Frame",{Size=UDim2.new(1,-170,1,-60),Position=U2(160,52),BackgroundColor3=C.pn,BorderSizePixel=0,Parent=M})
Cn(CT,10)Sk(CT,C.st,1,.6)
N("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),Parent=CT})
local SC=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.ac,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=CT})
N("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=SC})

-- ===== TABS =====
local Tbs={}
local function MT(nm,ic)
local b=N("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.bg,Text="  "..ic.."  "..nm,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=C.td,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,BorderSizePixel=0,Parent=SB})
Cn(b,6)
local ind=N("Frame",{Size=UDim2.new(0,3,0,0),Position=UDim2.new(0,0,.5,0),AnchorPoint=Vector2.new(0,.5),BackgroundColor3=C.ac,BorderSizePixel=0,Parent=b})
Cn(ind,2)
local ct=N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false,Parent=SC})
N("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=ct})
local Tb={B=b,C=ct,I=ind}
Con(b.MouseButton1Click,function()
for _,x in pairs(Tbs)do x.C.Visible=false x.B.BackgroundColor3=C.bg x.B.TextColor3=C.td x.I.Size=UDim2.new(0,3,0,0)end
ct.Visible=true b.BackgroundColor3=C.pl b.TextColor3=C.gl ind.Size=UDim2.new(0,3,0,22)
end)
table.insert(Tbs,Tb)
if #Tbs==1 then task.defer(function()ct.Visible=true b.BackgroundColor3=C.pl b.TextColor3=C.gl ind.Size=UDim2.new(0,3,0,22)end)end
return Tb end

-- ===== COMPONENTS =====
local function Lbl(p,tx,color)return N("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=tx,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=color or C.gl,TextXAlignment=Enum.TextXAlignment.Left,Parent=p})end
local function Div(p)return N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.st,BackgroundTransparency=.5,BorderSizePixel=0,Parent=p})end

local function Btn(p,nm,cb)
local b=N("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.bg,Text=nm,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=C.tx,AutoButtonColor=false,BorderSizePixel=0,Parent=p})
Cn(b,8)local s=Sk(b,C.st,1,.5)
Con(b.MouseEnter,function()Tw(b,.15,{BackgroundColor3=C.pl,TextColor3=C.gl})Tw(s,.15,{Color=C.ac,Transparency=.2})end)
Con(b.MouseLeave,function()Tw(b,.15,{BackgroundColor3=C.bg,TextColor3=C.tx})Tw(s,.15,{Color=C.st,Transparency=.5})end)
Con(b.MouseButton1Click,function()Tw(b,.1,{BackgroundColor3=C.ad})task.wait(.08)Tw(b,.15,{BackgroundColor3=C.pl})if cb then cb()end end)
return b end

local function Tog(p,nm,def,cb)
local st=def or false
local f=N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=p})
Cn(f,8)Sk(f,C.st,1,.7)
N("TextLabel",{Size=UDim2.new(1,-70,1,0),Position=U2(12,0),BackgroundTransparency=1,Text=nm,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=C.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
local b=N("TextButton",{Size=U2(42,22),Position=UDim2.new(1,-54,.5,-11),BackgroundColor3=st and C.ac or C.ad,Text="",AutoButtonColor=false,BorderSizePixel=0,Parent=f})
Cn(b,11)
local k=N("Frame",{Size=U2(18,18),Position=st and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9),BackgroundColor3=C.tx,BorderSizePixel=0,Parent=b})
Cn(k,9)
local function set(v)st=v Tw(b,.2,{BackgroundColor3=v and C.ac or C.ad})Tw(k,.2,{Position=v and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)})if cb then cb(v)end end
Con(b.MouseButton1Click,function()set(not st)end)
return {Set=set,Get=function()return st end}end

local function Sl(p,nm,mn,mx,def,suf,cb)
local v=def or mn
local f=N("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=p})
Cn(f,8)Sk(f,C.st,1,.7)
N("TextLabel",{Size=UDim2.new(.7,0,0,20),Position=U2(12,4),BackgroundTransparency=1,Text=nm,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=C.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
local vl=N("TextLabel",{Size=UDim2.new(.3,-12,0,20),Position=UDim2.new(.7,0,0,4),BackgroundTransparency=1,Text=tostring(v).." "..suf,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.gl,TextXAlignment=Enum.TextXAlignment.Right,Parent=f})
local tr=N("Frame",{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),BackgroundColor3=C.pl,BorderSizePixel=0,Parent=f})
Cn(tr,3)
local fl=N("Frame",{Size=UDim2.new((v-mn)/(mx-mn),0,1,0),BackgroundColor3=C.ac,BorderSizePixel=0,Parent=tr})
Cn(fl,3)N("UIGradient",{Color=ColorSequence.new(C.ac,C.gl),Rotation=0,Parent=fl})
local hit=N("TextButton",{Size=UDim2.new(1,0,1,20),Position=U2(0,-7),BackgroundTransparency=1,Text="",Parent=tr})
local drag=false
local function up(i)local rx=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)v=math.floor(mn+(mx-mn)*rx+.5)fl.Size=UDim2.new(rx,0,1,0)vl.Text=tostring(v).." "..suf if cb then cb(v)end end
Con(hit.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true up(i)end end)
Con(U.InputChanged,function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then up(i)end end)
Con(U.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
return {Set=function(nv)nv=math.clamp(nv,mn,mx)v=nv local rx=(nv-mn)/(mx-mn)fl.Size=UDim2.new(rx,0,1,0)vl.Text=tostring(nv).." "..suf if cb then cb(nv)end end,Get=function()return v end}end

local function Tb(p,nm,ph,cb)
local f=N("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=p})
Cn(f,8)Sk(f,C.st,1,.7)
N("TextLabel",{Size=UDim2.new(1,-24,0,20),Position=U2(12,4),BackgroundTransparency=1,Text=nm,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=C.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
local b=N("TextBox",{Size=UDim2.new(1,-24,0,24),Position=U2(12,26),BackgroundColor3=C.pl,Text="",PlaceholderText=ph or "Ketik...",PlaceholderColor3=C.td,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.tx,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,BorderSizePixel=0,Parent=f})
Cn(b,6)
N("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=b})
Con(b.FocusLost,function(en)if en and b.Text~="" and cb then cb(b.Text)end end)
return b end

-- ===== BIKIN TABS =====
local PlT=MT("Player","◆")local VsT=MT("Visual","◈")local MiT=MT("Misc","✦")local CrT=MT("Info","★")

-- ====== PLAYER TAB ======
Lbl(PlT.C,"⚡ MOVEMENT")Div(PlT.C)
local wsV=16
Sl(PlT.C,"Walk Speed",16,500,16,"spd",function(v)
wsV=v local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid")if h then h.WalkSpeed=v end end
end)
Sl(PlT.C,"Jump Power",50,500,50,"jp",function(v)
local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid")if h then h.UseJumpPower=true h.JumpPower=v end end
end)
Sl(PlT.C,"Gravity",0,300,math.floor(G0),"g",function(v)workspace.Gravity=v end)
local ij=false
Tog(PlT.C,"Infinite Jump",false,function(v)ij=v end)
Con(U.JumpRequest,function()
if ij and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid")if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end
end)
local fly,flyS,flyC=false,50,nil
Tog(PlT.C,"Fly (WASD)",false,function(v)
fly=v
local c=LP.Character if not c then return end
local hrp=c:FindFirstChild("HumanoidRootPart")local h=c:FindFirstChildOfClass("Humanoid")
if not hrp or not h then return end
if v then
h.PlatformStand=true
local bv=Instance.new("BodyVelocity")bv.Name="SxFly"bv.MaxForce=Vector3.new(9e9,9e9,9e9)bv.Velocity=Vector3.zero bv.Parent=hrp
flyC=Con(R.RenderStepped,function()
if not fly or not hrp.Parent then if flyC then flyC:Disconnect()end return end
local cm=workspace.CurrentCamera local d=Vector3.zero
if U:IsKeyDown(Enum.KeyCode.W)then d=d+cm.CFrame.LookVector end
if U:IsKeyDown(Enum.KeyCode.S)then d=d-cm.CFrame.LookVector end
if U:IsKeyDown(Enum.KeyCode.A)then d=d-cm.CFrame.RightVector end
if U:IsKeyDown(Enum.KeyCode.D)then d=d+cm.CFrame.RightVector end
if U:IsKeyDown(Enum.KeyCode.Space)then d=d+Vector3.new(0,1,0)end
if U:IsKeyDown(Enum.KeyCode.LeftControl)then d=d-Vector3.new(0,1,0)end
bv.Velocity=d.Magnitude>0 and(d.Unit*flyS)or Vector3.zero
end)
else
if flyC then flyC:Disconnect()flyC=nil end
h.PlatformStand=false
local old=hrp:FindFirstChild("SxFly")if old then old:Destroy()end
end end)
Sl(PlT.C,"Fly Speed",10,300,50,"spd",function(v)flyS=v end)
Con(LP.CharacterAdded,function(ch)task.wait(1)local h=ch:WaitForChild("Humanoid",5)if h then h.WalkSpeed=wsV end end)

-- ====== VISUAL TAB ======
Lbl(VsT.C,"👁 VISUAL")Div(VsT.C)
local espOn=false
local espOn=false
local teamCheck=true                              -- ON/OFF team check
local enemyColor=Color3.fromRGB(255,60,120)       -- warna musuh
local teamColor=Color3.fromRGB(80,255,180)        -- warna teammate
local showTeammate=false                          -- tampil teammate atau nggak

local function isEnemy(pl)
    if not teamCheck then return true end
    if not pl.Team or not LP.Team then return true end
    return pl.Team ~= LP.Team
end

local function addEsp(pl)
    if pl==LP or not pl.Character then return end
    local enemy = isEnemy(pl)
    if not enemy and not showTeammate then return end
    local h=pl.Character:FindFirstChild("SxESP")
    local color = enemy and enemyColor or teamColor
    if h then
        h.FillColor=color
        h.OutlineColor=C.gl
        return
    end
    N("Highlight",{
        Name="SxESP",
        FillColor=color,
        OutlineColor=C.gl,
        FillTransparency=.5,
        OutlineTransparency=0,
        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
        Parent=pl.Character
    })
end

local function clearEsp()
    for _,pl in ipairs(P:GetPlayers())do
        if pl.Character then 
            local h=pl.Character:FindFirstChild("SxESP")
            if h then h:Destroy() end 
        end
    end 
end

local function refreshEsp()
    clearEsp()
    if espOn then
        for _,pl in ipairs(P:GetPlayers()) do
            pcall(addEsp,pl)
        end
    end
end

Tog(VsT.C,"Player ESP",false,function(v)
    espOn=v
    refreshEsp()
end)

Tog(VsT.C,"Team Check",true,function(v)
    teamCheck=v
    refreshEsp()
end)

Tog(VsT.C,"Show Teammate",false,function(v)
    showTeammate=v
    refreshEsp()
end)

Btn(VsT.C,"Warna Musuh",function()
    -- ganti warna musuh (contoh: acak)
    local list={
        Color3.fromRGB(255,60,120),
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(255,140,0),
        Color3.fromRGB(255,0,255),
        Color3.fromRGB(255,255,0),
    }
    local idx=table.find(list,enemyColor) or 0
    idx=idx%#list+1
    enemyColor=list[idx]
    print("[ESP] Warna musuh:",enemyColor)
    refreshEsp()
end)

Btn(VsT.C,"Warna Teammate",function()
    local list={
        Color3.fromRGB(80,255,180),
        Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,200,255),
        Color3.fromRGB(80,150,255),
    }

    local idx=table.find(list,teamColor) or 0
    idx=idx%#list+1
    teamColor=list[idx]

    print("[ESP] Warna teammate:",teamColor)
    refreshEsp()
end)
-- ================================================
-- ESP SYSTEM v3 — Full Customizable
-- Line • Box • Health • Distance • Skeleton
-- ================================================
local Drawing = Drawing or nil

local espOn=false
local teamCheck=true
local showTeam=false

-- Palet warna (diputar tiap klik tombol warna)
local PALETTE={
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(255,60,120),
    Color3.fromRGB(255,140,0),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(80,255,80),
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(80,150,255),
    Color3.fromRGB(160,60,255),
    Color3.fromRGB(255,0,255),
    Color3.fromRGB(80,255,180),
}
local function nextColor(c)
    local idx=table.find(PALETTE,c)
    if not idx then return PALETTE[1] end
    return PALETTE[idx%#PALETTE+1]
end

-- Config ESP
local ESP={
    line     = {on=false, color=PALETTE[1],                  thickness=1},
    box      = {on=false, color=Color3.fromRGB(160,60,255),  thickness=1},
    health   = {on=false, color=Color3.fromRGB(80,255,80),   thickness=2},
    distance = {on=false, color=PALETTE[1],                  size=14},
    skeleton = {on=false, color=Color3.fromRGB(80,255,180),  thickness=1},
}

-- Team check
local function isEnemy(plr)
    if not teamCheck then return true end
    if not plr.Team or not LP.Team then return true end
    return plr.Team ~= LP.Team
end

local function shouldShow(plr)
    if plr==LP then return false end
    local char=plr.Character
    if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return false end
    if not isEnemy(plr) and not showTeam then return false end
    return true
end

-- Drawing helpers
local function newLine()
    local l=Drawing.new("Line")
    l.Visible=false; l.Thickness=1; l.Transparency=1
    return l
end
local function newText()
    local t=Drawing.new("Text")
    t.Visible=false; t.Size=14; t.Center=true
    t.Outline=true; t.OutlineColor=Color3.new(0,0,0)
    return t
end

local espDrawings={}

local function createESP(plr)
    if espDrawings[plr] then return espDrawings[plr] end
    local o={
        line=newLine(),
        boxTop=newLine(), boxBot=newLine(), boxL=newLine(), boxR=newLine(),
        hBG=newLine(), hFill=newLine(),
        dist=newText(),
        skSpine=newLine(), skLArm=newLine(), skRArm=newLine(),
        skLLeg=newLine(), skRLeg=newLine(),
    }
    espDrawings[plr]=o
    return o
end

local function destroyESP(plr)
    local o=espDrawings[plr]
    if not o then return end
    for _,d in pairs(o) do pcall(function() d:Remove() end) end
    espDrawings[plr]=nil
end

local function clearESP()
    for plr in pairs(espDrawings) do destroyESP(plr) end
end

local function hideAll(o)
    for _,d in pairs(o) do d.Visible=false end
end

-- Update tiap frame
local function updateESP()
    if not espOn or not Drawing then return end
    local cam=workspace.CurrentCamera
    if not cam then return end
    local myHRP=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    for _,plr in ipairs(P:GetPlayers()) do
        local o=espDrawings[plr]

        -- nggak ditampilin?
        if not shouldShow(plr) then
            if o then hideAll(o) end
        else
            o=createESP(plr)
            local char=plr.Character
            local head=char:FindFirstChild("Head")
            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")

            if not (head and hrp and hum) then
                hideAll(o)
            else
                local headScreen,headOn=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
                local feetScreen,feetOn=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))

                if not headOn and not feetOn then
                    hideAll(o)
                else
                    local topY=headScreen.Y
                    local botY=feetScreen.Y
                    local height=math.abs(botY-topY)
                    local width=height*0.5
                    local cx=headScreen.X
                    local left=cx-width/2
                    local right=cx+width/2

                    -- ===== LINE =====
                    if ESP.line.on then
                        o.line.Visible=true
                        o.line.From=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        o.line.To=Vector2.new(cx, botY)
                        o.line.Color=ESP.line.color
                        o.line.Thickness=ESP.line.thickness
                        o.line.Transparency=1
                    else
                        o.line.Visible=false
                    end

                    -- ===== BOX =====
                    if ESP.box.on then
                        o.boxTop.Visible=true
                        o.boxTop.From=Vector2.new(left,topY); o.boxTop.To=Vector2.new(right,topY)
                        o.boxBot.Visible=true
                        o.boxBot.From=Vector2.new(left,botY); o.boxBot.To=Vector2.new(right,botY)
                        o.boxL.Visible=true
                        o.boxL.From=Vector2.new(left,topY); o.boxL.To=Vector2.new(left,botY)
                        o.boxR.Visible=true
                        o.boxR.From=Vector2.new(right,topY); o.boxR.To=Vector2.new(right,botY)
                        for _,d in ipairs({o.boxTop,o.boxBot,o.boxL,o.boxR}) do
                            d.Color=ESP.box.color
                            d.Thickness=ESP.box.thickness
                            d.Transparency=1
                        end
                    else
                        o.boxTop.Visible=false; o.boxBot.Visible=false
                        o.boxL.Visible=false; o.boxR.Visible=false
                    end

                    -- ===== HEALTH =====
                    if ESP.health.on then
                        local hpPct=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        local hX=right+4
                        o.hBG.Visible=true
                        o.hBG.From=Vector2.new(hX,topY); o.hBG.To=Vector2.new(hX,botY)
                        o.hBG.Color=Color3.new(0,0,0)
                        o.hBG.Thickness=ESP.health.thickness+2
                        o.hBG.Transparency=1

                        o.hFill.Visible=true
                        local fillTop=botY-height*hpPct
                        o.hFill.From=Vector2.new(hX,fillTop); o.hFill.To=Vector2.new(hX,botY)
                        o.hFill.Color=ESP.health.color
                        o.hFill.Thickness=ESP.health.thickness
                        o.hFill.Transparency=1
                    else
                        o.hBG.Visible=false; o.hFill.Visible=false
                    end

                    -- ===== DISTANCE =====
                    if ESP.distance.on then
                        local dist=0
                        if myHRP then
                            dist=math.floor((hrp.Position-myHRP.Position).Magnitude)
                        end
                        o.dist.Visible=true
                        o.dist.Text=tostring(dist).." studs"
                        o.dist.Position=Vector2.new(cx, botY+14)
                        o.dist.Color=ESP.distance.color
                        o.dist.Size=ESP.distance.size
                    else
                        o.dist.Visible=false
                    end

                    -- ===== SKELETON =====
                    if ESP.skeleton.on then
                        local lHand=char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                        local rHand=char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                        local lFoot=char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                        local rFoot=char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

                        local function scr(part)
                            if not part then return nil end
                            local p,on=cam:WorldToViewportPoint(part.Position)
                            if not on then return nil end
                            return Vector2.new(p.X,p.Y)
                        end

                        local pHead=scr(head)
                        local pHRP=scr(hrp)
                        local pLHand=scr(lHand)
                        local pRHand=scr(rHand)
                        local pLFoot=scr(lFoot)
                        local pRFoot=scr(rFoot)

                        local function setLine(l,a,b)
                            if a and b then
                                l.Visible=true
                                l.From=a; l.To=b
                                l.Color=ESP.skeleton.color
                                l.Thickness=ESP.skeleton.thickness
                                l.Transparency=1
                            else
                                l.Visible=false
                            end
                        end

                        setLine(o.skSpine, pHead, pHRP)
                        setLine(o.skLArm, pHRP, pLHand)
                        setLine(o.skRArm, pHRP, pRHand)
                        setLine(o.skLLeg, pHRP, pLFoot)
                        setLine(o.skRLeg, pHRP, pRFoot)
                    else
                        o.skSpine.Visible=false
                        o.skLArm.Visible=false; o.skRArm.Visible=false
                        o.skLLeg.Visible=false; o.skRLeg.Visible=false
                    end
                end
            end
        end
    end
end

-- ===== GUI =====
Lbl(VsT.C,"👁 ESP SETTINGS")Div(VsT.C)
Tog(VsT.C,"Player ESP",false,function(v) espOn=v; if not v then clearESP() end end)
Tog(VsT.C,"Team Check",true,function(v) teamCheck=v end)
Tog(VsT.C,"Show Teammate",false,function(v) showTeam=v end)

Lbl(VsT.C,"━━━ ESP LINE ━━━",C.td)
Tog(VsT.C,"Line",false,function(v) ESP.line.on=v end)
Btn(VsT.C,"🎨 Warna Line",function() ESP.line.color=nextColor(ESP.line.color) end)
Sl(VsT.C,"Ketebalan Line",1,10,1,"px",function(v) ESP.line.thickness=v end)

Lbl(VsT.C,"━━━ ESP BOX ━━━",C.td)
Tog(VsT.C,"Box",false,function(v) ESP.box.on=v end)
Btn(VsT.C,"🎨 Warna Box",function() ESP.box.color=nextColor(ESP.box.color) end)
Sl(VsT.C,"Ketebalan Box",1,10,1,"px",function(v) ESP.box.thickness=v end)

Lbl(VsT.C,"━━━ ESP HEALTH ━━━",C.td)
Tog(VsT.C,"Health Bar",false,function(v) ESP.health.on=v end)
Btn(VsT.C,"🎨 Warna Health",function() ESP.health.color=nextColor(ESP.health.color) end)
Sl(VsT.C,"Ketebalan Health",1,10,2,"px",function(v) ESP.health.thickness=v end)

Lbl(VsT.C,"━━━ ESP DISTANCE ━━━",C.td)
Tog(VsT.C,"Distance",false,function(v) ESP.distance.on=v end)
Btn(VsT.C,"🎨 Warna Distance",function() ESP.distance.color=nextColor(ESP.distance.color) end)
Sl(VsT.C,"Ukuran Text",10,24,14,"pt",function(v) ESP.distance.size=v end)

Lbl(VsT.C,"━━━ ESP SKELETON ━━━",C.td)
Tog(VsT.C,"Skeleton",false,function(v) ESP.skeleton.on=v end)
Btn(VsT.C,"🎨 Warna Skeleton",function() ESP.skeleton.color=nextColor(ESP.skeleton.color) end)
Sl(VsT.C,"Ketebalan Skeleton",1,10,1,"px",function(v) ESP.skeleton.thickness=v end)

-- Render loop
Con(R.RenderStepped,function() pcall(updateESP) end)

-- Cleanup kalau player keluar
Con(P.PlayerRemoving,function(plr) destroyESP(plr) end)

Sl(VsT.C,"Field of View",40,120,math.floor(F0),"fov",function(v)
    local cm=workspace.CurrentCamera if cm then cm.FieldOfView=v end
end)
local fb=false
Tog(VsT.C,"Fullbright",false,function(v)
fb=v local L=game:GetService("Lighting")
if v then L.Ambient=Color3.fromRGB(255,255,255)L.OutdoorAmbient=Color3.fromRGB(255,255,255)L.Brightness=3 L.FogEnd=1e5 L.GlobalShadows=false
else L.Ambient=Color3.fromRGB(70,70,70)L.OutdoorAmbient=Color3.fromRGB(128,128,128)L.Brightness=2 L.GlobalShadows=true end
end)

-- ====== MISC TAB ======
Lbl(MiT.C,"🛡️ UTILITY")Div(MiT.C)
local nc=false
Tog(MiT.C,"Noclip",false,function(v)nc=v end)
Con(R.Stepped,function()
if nc and LP.Character then for _,p in pairs(LP.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end
end)
local afk=true
Tog(MiT.C,"Anti AFK",true,function(v)afk=v end)
task.spawn(function()while task.wait(60)do if not g.Parent then break end if afk and LP.Parent then pcall(function()local V=game:GetService("VirtualUser")V:CaptureController()V:ClickButton1(Vector2.new(0,0))end)end end end)
local ctp=false
Tog(MiT.C,"Click TP (Ctrl + Klik)",false,function(v)ctp=v end)
Con(U.InputBegan,function(i,gp)
if gp or not ctp then return end
if i.UserInputType==Enum.UserInputType.MouseButton1 and U:IsKeyDown(Enum.KeyCode.LeftControl)then
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local m=LP:GetMouse()
if hrp and m.Hit then hrp.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0))end
end end)
Lbl(MiT.C,"🚀 TELEPORT")Div(MiT.C)
local tpT=""
Tb(MiT.C,"Player Name","Username...",function(t)tpT=t end)
Btn(MiT.C,"Teleport to Player",function()
if tpT==""then return end
local tg=P:FindFirstChild(tpT)
if tg and tg.Character and LP.Character then
local th=tg.Character:FindFirstChild("HumanoidRootPart")local mh=LP.Character:FindFirstChild("HumanoidRootPart")
if th and mh then mh.CFrame=th.CFrame*CFrame.new(0,0,3)end end
end)
Btn(MiT.C,"Rejoin Server",function()game:GetService("TeleportService"):Teleport(game.PlaceId,LP)end)
Btn(MiT.C,"Server Hop",function()
local TS=game:GetService("TeleportService")local H=game:GetService("HttpService")
local o,r=pcall(function()return H:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))end)
if o and r and r.data then for _,s in pairs(r.data)do if s.playing<s.maxPlayers and s.id~=game.JobId then TS:TeleportToPlaceInstance(game.PlaceId,s.id,LP)return end end end
end)
Btn(MiT.C,"Reset Character",function()
if LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid")if h then h.Health=0 end end
end)

-- ====== INFO TAB ======
Lbl(CrT.C,"★ SxHub")Div(CrT.C)
local fpsL=Lbl(CrT.C,"FPS: -",C.sc)
local pingL=Lbl(CrT.C,"Ping: -",C.sc)
Div(CrT.C)
Lbl(CrT.C,"Theme: Dark Purple Cyber",C.tx)
Lbl(CrT.C,"Build: v1.4",C.tx)
Lbl(CrT.C,"Hotkey: RightShift = hide/show",C.tx)
Div(CrT.C)
Lbl(CrT.C,"Features:")
Lbl(CrT.C,"• Speed / Jump / Gravity",C.tx)
Lbl(CrT.C,"• Infinite Jump, Fly, Noclip",C.tx)
Lbl(CrT.C,"• Player ESP, FOV, Fullbright",C.tx)
Lbl(CrT.C,"• Click TP, Teleport, Server Hop",C.tx)
Lbl(CrT.C,"• Anti AFK, Black Hole Icon",C.tx)
do
local frames,last=0,os.clock()
Con(R.RenderStepped,function()frames=frames+1 end)
task.spawn(function()
while g.Parent do task.wait(.5)
local now=os.clock()
fpsL.Text="FPS: "..math.floor(frames/(now-last)+.5)
frames=0 last=now
local ok2,pg=pcall(function()return LP:GetNetworkPing()*1000 end)
pingL.Text="Ping: "..(ok2 and math.floor(pg).." ms" or "-")
end end)
end

-- ===== MINIMIZE / RESTORE =====
local winPos=M.Position
local iconPos=I.Position

local function Minimize()
if state~="open"then return end state="busy"
winPos=M.Position
I.Position=iconPos
Tw(M,.35,{Position=iconPos},ES.Quint,ED.In)
Tw(MS,.35,{Scale=0},ES.Quint,ED.In)
task.delay(.25,function()ISc.Scale=0 I.Visible=true Tw(ISc,.45,{Scale=1},ES.Back,ED.Out)end)
task.delay(.35,function()M.Visible=false state="min"end)
end

local function Restore()
if state~="min"then return end state="busy"
iconPos=I.Position
M.Position=iconPos MS.Scale=0 M.Visible=true
Tw(ISc,.2,{Scale=0},ES.Quint,ED.In)
Tw(M,.45,{Position=winPos},ES.Quint,ED.Out)
Tw(MS,.45,{Scale=1},ES.Back,ED.Out)
task.delay(.2,function()I.Visible=false end)
task.delay(.45,function()state="open"end)
end

Con(MB.MouseButton1Click,Minimize)

-- hotkey RightShift
Con(U.InputBegan,function(i,gp)
if gp then return end
if i.KeyCode==Enum.KeyCode.RightShift then
if state=="open"then Minimize()elseif state=="min"then Restore()end
end end)

-- ===== ICON: drag + tap =====
do
local pr,inp,t0,sp0,ip0,moved
Con(IB.InputBegan,function(i)
if state~="min"then return end
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
pr=true inp=i t0=tick()sp0=i.Position ip0=I.Position moved=false end end)
Con(U.InputChanged,function(i)
if not pr then return end
if i.UserInputType==Enum.UserInputType.MouseMovement or i==inp then
local d=i.Position-sp0
if moved or d.Magnitude>8 then moved=true I.Position=UDim2.new(ip0.X.Scale,ip0.X.Offset+d.X,ip0.Y.Scale,ip0.Y.Offset+d.Y)end
end end)
Con(U.InputEnded,function(i)
if not pr then return end
if i.UserInputType==Enum.UserInputType.MouseButton1 or i==inp then
pr=false
if moved then iconPos=I.Position elseif tick()-t0<.4 then Restore()end
end end)
end

-- ===== CLOSE =====
Con(CB.MouseButton1Click,function()
if state=="busy"then return end
state="busy"
Tw(MS,.25,{Scale=0},ES.Quint,ED.In)
task.delay(.27,function()
espOn=false pcall(clearEsp)
workspace.Gravity=G0
local cm=workspace.CurrentCamera if cm then cm.FieldOfView=F0 end
for _,c in ipairs(conns)do c:Disconnect()end
g:Destroy()
end)
end)

-- ===== INTRO SxHub =====
local function Intro()
local ov=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,2,10),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=50,Parent=g})
Tw(ov,.45,{BackgroundTransparency=.25})
local hd=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(300,90),BackgroundTransparency=1,ZIndex=51,Parent=ov})
local ig=N("ImageLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=U2(160,70),Image=GLOW,ImageColor3=C.ac,ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=SLICE,ZIndex=51,Parent=hd})
Tw(ig,1.4,{Size=U2(440,170),ImageTransparency=.5})
local word="SxHub"local W=46
local L={}
for i=1,#word do
local x=(i-(#word+1)/2)*W
local l=N("TextLabel",{Size=U2(W,70),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,x,.5,26),BackgroundTransparency=1,Text=word:sub(i,i),Font=Enum.Font.GothamBlack,TextSize=56,TextColor3=i<=2 and C.gl or C.tx,TextTransparency=1,ZIndex=52,Parent=hd})
local s=N("UIStroke",{Color=C.ac,Thickness=2,Transparency=1,Parent=l})
local sc=N("UIScale",{Scale=.4,Parent=l})
L[i]={l=l,s=s,sc=sc,x=x}
task.delay(.3+.11*i,function()
Tw(l,.5,{Position=UDim2.new(.5,x,.5,0),TextTransparency=0})
Tw(s,.5,{Transparency=.35})
Tw(sc,.5,{Scale=1},ES.Back,ED.Out)
end)
end
task.wait(.3+.11*#word+.55)
for i,o in ipairs(L)do
task.delay(.07*i,function()
Tw(o.sc,.18,{Scale=1.2})Tw(o.l,.18,{TextColor3=Color3.new(1,1,1)})Tw(o.s,.18,{Transparency=0,Thickness=3})
task.wait(.2)
Tw(o.sc,.3,{Scale=1},ES.Back,ED.Out)Tw(o.l,.3,{TextColor3=i<=2 and C.gl or C.tx})Tw(o.s,.3,{Transparency=.35,Thickness=2})
end)
end
local ln=N("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,1,8),Size=U2(0,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=52,Parent=hd})
N("UIGradient",{Color=ColorSequence.new(C.ac,C.gl),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)}),Parent=ln})
Tw(ln,1.1,{Size=U2(280,2)},ES.Quad,ED.InOut)
local sub=N("TextLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,1,18),Size=U2(280,18),BackgroundTransparency=1,Text="Universal • Loading...",Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=C.td,TextTransparency=1,ZIndex=52,Parent=hd})
Tw(sub,.5,{TextTransparency=.1})
task.wait(1.5)
for _,o in ipairs(L)do
Tw(o.l,.45,{TextTransparency=1,Position=UDim2.new(.5,o.x,.5,-22)},ES.Quint,ED.In)
Tw(o.s,.45,{Transparency=1})Tw(o.sc,.45,{Scale=1.3},ES.Quint,ED.In)
end
Tw(ln,.3,{BackgroundTransparency=1})Tw(sub,.3,{TextTransparency=1})
Tw(ig,.6,{ImageTransparency=1,Size=U2(640,240)})
Tw(ov,.55,{BackgroundTransparency=1})
task.delay(.3,function()
M.Visible=true
Tw(MS,.6,{Scale=1},ES.Back,ED.Out)
end)
task.wait(.9)
ov:Destroy()
state="open"
end
task.spawn(Intro)

print("[SxHub] Loaded! ✓")
-- ===== UI SETTINGS =====
local D={tr=100,bgt=0,w=560,h=400,ic=100,n=45,br=85,sp=10}
local ST={}
for k,v in pairs(D) do ST[k]=v end

-- wrapper ikon biar ukurannya bisa diatur tanpa ganggu animasi minimize
local IC=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Parent=I})
local ICs=N("UIScale",{Scale=1,Parent=IC})
for _,c in ipairs(I:GetChildren()) do
if c:IsA("GuiObject") and c~=IC then c.Parent=IC end
end

local function applyTr()
local a=ST.tr/100
SB.BackgroundTransparency=a
CT.BackgroundTransparency=a
TB.BackgroundTransparency=a*.4
for _,c in ipairs(TB:GetChildren()) do
if c:IsA("Frame") and c.BackgroundColor3==C.pn then c.BackgroundTransparency=a*.4 end
end
end

local function setStars(n)
while #stars>n do
local s=table.remove(stars)
s.f:Destroy()
end
while #stars<n do
local sz=math.random(2,3)
local f=N("Frame",{Size=U2(sz,sz),Position=UDim2.fromScale(math.random(),math.random()),BackgroundColor3=(#stars%4==0)and C.gl or WHITE,BackgroundTransparency=.3,BorderSizePixel=0,ZIndex=1,Parent=BGL})
Cn(f,3)
stars[#stars+1]={f=f,sp=.6+math.random()*1.6,ph=math.random()*6.28}
end
end

-- ===== TAB SETTINGS =====
local StT=MT("Settings","◆")
Lbl(StT.C,"UI SETTINGS")Div(StT.C)
local sl={}
sl.tr=Sl(StT.C,"Transparansi Panel",0,100,D.tr,"%",function(v)ST.tr=v applyTr()end)
sl.bgt=Sl(StT.C,"Transparansi Latar",0,100,D.bgt,"%",function(v)ST.bgt=v M.BackgroundTransparency=v/100 end)
sl.w=Sl(StT.C,"Lebar Menu",400,720,D.w,"px",function(v)ST.w=v M.Size=U2(ST.w,ST.h)end)
sl.h=Sl(StT.C,"Tinggi Menu",240,420,D.h,"px",function(v)ST.h=v M.Size=U2(ST.w,ST.h)end)
sl.ic=Sl(StT.C,"Ukuran Ikon",50,200,D.ic,"%",function(v)ST.ic=v ICs.Scale=v/100 end)
sl.n=Sl(StT.C,"Jumlah Bintang",0,150,D.n,"",function(v)ST.n=v setStars(v)end)
sl.br=Sl(StT.C,"Kecerahan Bintang",10,100,D.br,"%",function(v)ST.br=v end)
sl.sp=Sl(StT.C,"Kedip (10 = normal)",1,40,D.sp,"",function(v)ST.sp=v end)
Btn(StT.C,"Reset ke Default",function()
for k,s in pairs(sl) do s.Set(D[k]) end
end)

applyTr()
setStars(ST.n)

-- ===== ANIMASI BINTANG =====
local acc=0
Con(R.Heartbeat,function(dt)
if not M.Visible then return end
local t=os.clock()
acc=acc+dt*ST.sp/10
local lo=.9*(1-ST.br/100)
local hi=lo+(1-lo)*.6
for _,s in ipairs(stars)do
s.f.BackgroundTransparency=lo+(hi-lo)*math.abs(math.sin(acc*s.sp+s.ph))
end
for _,s in ipairs(SH)do
if s.d==0 then
if t>=s.nx then
s.d=.9+math.random()*.5
s.t0=t
s.x=math.random(-20,math.floor(ST.w*.55))
s.y=math.random(-20,math.floor(ST.h*.3))
s.f.Visible=true
end
elseif (t-s.t0)>=s.d then
s.d=0
s.f.Visible=false
s.nx=t+1+math.random()*3
else
local p=(t-s.t0)/s.d
local dist=p*380
s.f.Position=U2(s.x+dist*.866,s.y+dist*.5)
s.f.BackgroundTransparency=1-math.sin(p*math.pi)
end
end
end)
-- ===== STAR v3 (bentuk bintang beneran) =====
for i=#stars,1,-1 do
if stars[i].f then stars[i].f:Destroy() end
stars[i]=nil
end
local S3={}
local PAL3={Color3.new(1,1,1),Color3.fromRGB(190,210,255),Color3.fromRGB(255,230,190),Color3.fromRGB(215,170,255)}
local function newStar()
local r=math.random()
local kind=r<.55 and 1 or(r<.88 and 2 or 3)
local col=PAL3[math.random(1,#PAL3)]
local o
if kind==1 then
local z=math.random(1,2)
o=N("Frame",{Size=U2(z,z),BackgroundColor3=col,BorderSizePixel=0,ZIndex=1})
else
local ts=kind==2 and 9 or 15
o=N("TextLabel",{Size=U2(ts,ts),BackgroundTransparency=1,Text="★",Font=Enum.Font.GothamBold,TextSize=ts,TextColor3=col,ZIndex=1})
end
o.AnchorPoint=Vector2.new(.5,.5)
o.Position=UDim2.fromScale(math.random(),math.random())
o.Parent=BGL
return {o=o,k=kind,sp=.5+math.random()*2.5,ph=math.random()*6.28,vx=kind*.003*(.7+math.random()*.6)}
end
setStars=function(n)
while #S3>n do
local s=table.remove(S3)
s.o:Destroy()
end
while #S3<n do S3[#S3+1]=newStar() end
end
setStars(ST.n)

local acc3=0
Con(R.Heartbeat,function(dt)
if not M.Visible then return end
acc3=acc3+dt*ST.sp/10
local lo=.85*(1-ST.br/100)
local hi=lo+(1-lo)*.7
for _,s in ipairs(S3)do
local k=math.sin(acc3*s.sp+s.ph)*.5+.5
local tr=lo+(hi-lo)*k*k*k
if s.k==1 then s.o.BackgroundTransparency=tr else s.o.TextTransparency=tr end
local p=s.o.Position
local x=p.X.Scale-dt*s.vx*(ST.dr or 10)/10
if x<-0.03 then
s.o.Position=UDim2.fromScale(1.03,math.random())
else
s.o.Position=UDim2.fromScale(x,p.Y.Scale)
end
end
end)
