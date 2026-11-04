--!nocheck
--// SyzenHub v3.9 - Complete Undetected UI Engine
--// Fixes: Clean Borderless Squircle Icon (No Colored Edge, No Corner Notches), Fixed Dropdown & Full Config System

local cloneref = cloneref or function(o) return o end

local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local FontBold = Font.fromEnum(Enum.Font.BuilderSansBold)
local FontMedium = Font.fromEnum(Enum.Font.BuilderSansMedium)

local Env = {
	Connections = {},
	PagesList = {},
	Banner = {
		['Genral']   = 129151530039254,
		['General']  = 129151530039254,
		['Auto']     = 129302321798602,
		['Setting']  = 103463784774845,
		['Misc']     = 103493630998019,
		['Items']    = 121735458882028,
		['Shop']     = 82134370671226,
		['Teleport'] = 133351841364966,
		['Visual']   = 117787399637458,
		['Combat']   = 98110438690781,
		['Update']   = 137729932889241,
	},
	Icons = {
		["home"] = "rbxassetid://10723407389",
		["settings"] = "rbxassetid://10734950309",
		["user"] = "rbxassetid://10747373176",
		["player"] = "rbxassetid://10747373176",
		["shield"] = "rbxassetid://10734951847",
		["sword"] = "rbxassetid://10734975486",
		["sparkles"] = "rbxassetid://10734966248",
		["zap"] = "rbxassetid://10747384394",
		["eye"] = "rbxassetid://10723346959",
		["visuals"] = "rbxassetid://10723346959",
		["search"] = "rbxassetid://10734943674",
		["check"] = "rbxassetid://10709790644",
		["bell"] = "rbxassetid://10709775704",
		["heart"] = "rbxassetid://10723406885",
		["star"] = "rbxassetid://10734966248",
		["lock"] = "rbxassetid://10723434711",
		["unlock"] = "rbxassetid://10747366027",
		["trash"] = "rbxassetid://10747362393",
		["copy"] = "rbxassetid://10709812159",
		["discord"] = "rbxassetid://94937742565147",
		["arrow_right"] = "rbxassetid://108028847031522",
		["dropdown"] = "rbxassetid://129573215183311",
		["code"] = "rbxassetid://10709810463",
		["sliders"] = "rbxassetid://10734963400",
		["globe"] = "rbxassetid://10723404337",
		["cpu"] = "rbxassetid://10709813383"
	}
}

--// Stealth Helpers
local function RandomName()
	local ok, id = pcall(function()
		return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 10)
	end)
	return (ok and id) or tostring(math.random(100000, 999999))
end

local function GetSafeGuiParent()
	if RunService:IsStudio() then
		return LocalPlayer:WaitForChild("PlayerGui")
	end
	if gethui then
		return gethui()
	elseif syn and syn.protect_gui then
		local folder = Instance.new("Folder")
		syn.protect_gui(folder)
		folder.Name = RandomName()
		folder.Parent = CoreGui
		return folder
	end
	return CoreGui
end

local function TrackConn(conn)
	table.insert(Env.Connections, conn)
	return conn
end

local function ParseKeyCode(k)
	if typeof(k) == "EnumItem" then
		return k
	elseif type(k) == "string" then
		local clean = k:gsub("Enum.KeyCode.", "")
		local ok, code = pcall(function() return Enum.KeyCode[clean] end)
		if ok and code then return code end
	end
	return Enum.KeyCode.F2
end

local function GetIcon(i)
	if not i then return "" end
	if type(i) == "string" then
		for k, id in pairs(Env.Banner) do
			if string.lower(k) == string.lower(i) then
				return string.format("rbxthumb://type=Asset&id=%s&w=420&h=420", tostring(id))
			end
		end
		local lower = string.lower(i)
		if Env.Icons[lower] then
			return Env.Icons[lower]
		end
		if i:find("^rbxthumb://") then
			return i
		end
		local numStr = i:match("%d+")
		if numStr then
			return string.format("rbxthumb://type=Asset&id=%s&w=420&h=420", numStr)
		end
		return i
	elseif type(i) == "number" then
		return string.format("rbxthumb://type=Asset&id=%s&w=420&h=420", tostring(i))
	end
	return tostring(i)
end

local function IsMobilePlatform()
	local isMobile = false
	pcall(function()
		local platform = UserInputService:GetPlatform()
		if platform == Enum.Platform.IOS or platform == Enum.Platform.Android then
			isMobile = true
		end
	end)
	if isMobile then return true end

	local pgui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pgui and pgui:FindFirstChild("TouchGui") then
		return true
	end

	local cam = workspace.CurrentCamera
	if UserInputService.TouchEnabled and (not UserInputService.MouseEnabled or (cam and cam.ViewportSize.Y <= 650)) then
		return true
	end
	return false
end

local function tw(info)
	local style = Enum.EasingStyle[info.s or "Quart"] or Enum.EasingStyle.Quart
	local dir = Enum.EasingDirection[info.d or "Out"] or Enum.EasingDirection.Out
	return TweenService:Create(info.v, TweenInfo.new(info.t or 0.25, style, dir), info.g)
end

local function ApplyThemeGradient(parent, rot)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
		ColorSequenceKeypoint.new(0.483, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
	}
	if rot then grad.Rotation = rot end
	grad.Parent = parent
	return grad
end

local function lak(a)
	local Dragging = false
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil
	local HasDragged = false

	local function Update(input)
		local Delta = input.Position - DragStart
		if Delta.Magnitude > 5 then
			HasDragged = true
		end
		local pos = UDim2.new(
			StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
		)
		tw({v = a, t = 0.12, s = "Quart", d = "Out", g = {Position = pos}}):Play()
	end

	TrackConn(a.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			HasDragged = false
			DragStart = input.Position
			StartPosition = a.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end))

	TrackConn(a.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end))

	TrackConn(UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end))

	return function()
		return HasDragged
	end
end

local function click(p, zOffset)
	local Click = Instance.new("TextButton")
	Click.Name = RandomName()
	Click.Parent = p
	Click.BackgroundTransparency = 1
	Click.BorderSizePixel = 0
	Click.Size = UDim2.new(1, 0, 1, 0)
	Click.FontFace = FontMedium
	Click.Text = ""
	Click.AutoButtonColor = false
	if zOffset then
		Click.ZIndex = p.ZIndex + zOffset
	end
	return Click
end

local function AddHoverEffect(frame, defaultTrans)
	defaultTrans = defaultTrans or 0.5
	TrackConn(frame.MouseEnter:Connect(function()
		tw({v = frame, t = 0.2, s = "Quart", d = "Out", g = {BackgroundTransparency = math.clamp(defaultTrans - 0.15, 0, 1)}}):Play()
	end))
	TrackConn(frame.MouseLeave:Connect(function()
		tw({v = frame, t = 0.2, s = "Quart", d = "Out", g = {BackgroundTransparency = defaultTrans}}):Play()
	end))
end

local function EffectClick(c, p, useGradient)
	local relativeX = Mouse.X - c.AbsolutePosition.X
	local relativeY = Mouse.Y - c.AbsolutePosition.Y
	if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then return end

	local Circle = Instance.new("Frame")
	Circle.Name = RandomName()
	Circle.Parent = p
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Circle.BackgroundTransparency = 0.55
	Circle.BorderSizePixel = 0
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)
	Circle.Position = UDim2.new(0, relativeX, 0, relativeY)
	Circle.Size = UDim2.new(0, 0, 0, 0)
	Circle.ZIndex = p.ZIndex + 5

	if useGradient then ApplyThemeGradient(Circle, 48) end

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Circle

	local expandTween = tw({
		v = Circle,
		t = 0.6,
		s = "Quart",
		d = "Out",
		g = {
			Size = UDim2.new(0, c.AbsoluteSize.X * 1.6, 0, c.AbsoluteSize.X * 1.6),
			BackgroundTransparency = 1
		}
	})
	expandTween.Completed:Connect(function() Circle:Destroy() end)
	expandTween:Play()
end

if getgenv and getgenv()._SyzenCleanup then
	pcall(getgenv()._SyzenCleanup)
end

local Khaw = Instance.new("ScreenGui")
Khaw.Name = RandomName()
Khaw.Parent = GetSafeGuiParent()
Khaw.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Khaw.ResetOnSpawn = false
Khaw.IgnoreGuiInset = true

if getgenv then
	getgenv()._SyzenCleanup = function()
		for _, c in ipairs(Env.Connections) do pcall(function() c:Disconnect() end) end
		table.clear(Env.Connections)
		if Khaw then pcall(function() Khaw:Destroy() end) end
	end
end

function Env:Destroy()
	if getgenv and getgenv()._SyzenCleanup then
		getgenv()._SyzenCleanup()
	end
end

function Env:Window(meta)
	meta = meta or {}
	local Title = meta.Title or "SyzenHub"
	local Desc = meta.Desc or "v3.9 • Undetected"
	local OpenButtonLogo = meta.OpenLogo or meta.Logo or 139585880965481

	--// ==========================================
	--// PROFESSIONAL MULTI-PROFILE CONFIG ENGINE
	--// ==========================================
	local RootFolder = meta.ConfigFolder or "SyzenHub"
	local ProfilesFolder = RootFolder .. "/Configs"
	local AutoloadFile = RootFolder .. "/autoload.txt"
	local CurrentConfigName = meta.Config or "Default"
	local AutoSaveEnabled = true
	local Flags = {}
	local FlagElements = {}

	local function EnsureFolders()
		if makefolder and isfolder then
			pcall(function()
				if not isfolder(RootFolder) then makefolder(RootFolder) end
				if not isfolder(ProfilesFolder) then makefolder(ProfilesFolder) end
			end)
		end
	end
	EnsureFolders()

	local function GetConfigPath(name)
		return ProfilesFolder .. "/" .. tostring(name) .. ".json"
	end

	if isfile and readfile then
		pcall(function()
			if isfile(AutoloadFile) then
				local autoName = readfile(AutoloadFile):gsub("%s+", "")
				if #autoName > 0 and isfile(GetConfigPath(autoName)) then
					CurrentConfigName = autoName
				end
			end
		end)
	end

	if isfile and readfile then
		pcall(function()
			local path = GetConfigPath(CurrentConfigName)
			if isfile(path) then
				local decoded = HttpService:JSONDecode(readfile(path))
				if type(decoded) == "table" then
					Flags = decoded
				end
			end
		end)
	end

	if Flags["_AutoSave"] ~= nil then
		AutoSaveEnabled = Flags["_AutoSave"]
	end

	local function WriteConfigFile(profileName)
		if not writefile then return false end
		EnsureFolders()
		local ok = pcall(function()
			writefile(GetConfigPath(profileName or CurrentConfigName), HttpService:JSONEncode(Flags))
		end)
		return ok
	end

	local function SaveFlag(flag, val)
		if not flag then return end
		Flags[flag] = val
		if AutoSaveEnabled then
			WriteConfigFile(CurrentConfigName)
		end
	end

	local ToggleKey = ParseKeyCode(Flags["_MenuToggleKey"] or meta.Bind or meta.ToggleKey or Enum.KeyCode.F2)

	--// Main Window Frame
	local Background_1 = Instance.new("Frame")
	local DropShadow_1 = Instance.new("ImageLabel")
	local UICorner_1 = Instance.new("UICorner")
	local Header_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local Line_1 = Instance.new("Frame")
	local Desc_1 = Instance.new("TextLabel")
	local Effect_1 = Instance.new("ImageLabel")

	Background_1.Name = RandomName()
	Background_1.Parent = Khaw
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	Background_1.BackgroundTransparency = 0.22
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	Background_1.Size = UDim2.new(0, 0, 0, 0)

	lak(Background_1)
	tw({v = Background_1, t = 0.55, s = "Back", d = "Out", g = {Size = UDim2.new(0, 574, 0, 365)}}):Play()

	DropShadow_1.Name = RandomName()
	DropShadow_1.Parent = Background_1
	DropShadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_1.BackgroundTransparency = 1
	DropShadow_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow_1.Size = UDim2.new(1, 120, 1, 120)
	DropShadow_1.ZIndex = 0
	DropShadow_1.Image = "rbxassetid://8992230677"
	DropShadow_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow_1.ImageTransparency = 0.3
	DropShadow_1.ScaleType = Enum.ScaleType.Slice
	DropShadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

	Effect_1.Name = RandomName()
	Effect_1.Parent = Background_1
	Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect_1.BackgroundTransparency = 1
	Effect_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	Effect_1.Size = UDim2.new(1, 0, 1, 0)
	Effect_1.Image = "rbxassetid://132687652275989"
	Effect_1.ImageColor3 = Color3.fromRGB(0, 255, 127)
	Effect_1.ImageTransparency = 0.15
	Effect_1.ScaleType = Enum.ScaleType.Crop

	UICorner_1.Parent = Background_1
	UICorner_1.CornerRadius = UDim.new(0, 18)

	Header_1.Name = RandomName()
	Header_1.Parent = Background_1
	Header_1.BackgroundTransparency = 1
	Header_1.Size = UDim2.new(1, 0, 0, 73)

	Title_1.Name = RandomName()
	Title_1.Parent = Header_1
	Title_1.BackgroundTransparency = 1
	Title_1.Position = UDim2.new(0, 0, 0.116, 0)
	Title_1.Size = UDim2.new(0, 462, 0, 24)
	Title_1.FontFace = FontBold
	Title_1.RichText = true
	Title_1.Text = Title
	Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_1.TextSize = 24
	Title_1.TextWrapped = true
	Title_1.TextXAlignment = Enum.TextXAlignment.Left

	UIListLayout_1.Parent = Header_1
	UIListLayout_1.Padding = UDim.new(0, 6)
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_1.Parent = Header_1
	UIPadding_1.PaddingLeft = UDim.new(0, 20)
	UIPadding_1.PaddingTop = UDim.new(0, 3)

	Line_1.Name = RandomName()
	Line_1.Parent = Header_1
	Line_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line_1.BorderSizePixel = 0
	Line_1.Size = UDim2.new(0, 70, 0, 2)
	ApplyThemeGradient(Line_1)

	Desc_1.Name = RandomName()
	Desc_1.Parent = Header_1
	Desc_1.BackgroundTransparency = 1
	Desc_1.Size = UDim2.new(0, 420, 0, 16)
	Desc_1.FontFace = FontBold
	Desc_1.RichText = true
	Desc_1.Text = Desc
	Desc_1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Desc_1.TextSize = 14
	Desc_1.TextTransparency = 0.45
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left

	--// Animated Notification Stack Holder
	local NotifHolder = Instance.new("Frame")
	NotifHolder.Name = RandomName()
	NotifHolder.Parent = Khaw
	NotifHolder.AnchorPoint = Vector2.new(1, 1)
	NotifHolder.Position = UDim2.new(1, -22, 1, -22)
	NotifHolder.Size = UDim2.new(0, 300, 1, -44)
	NotifHolder.BackgroundTransparency = 1
	NotifHolder.ZIndex = 100

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.Parent = NotifHolder
	NotifLayout.Padding = UDim.new(0, 10)
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder

	--// =========================================================================
	--// BORDERLESS SQUIRCLE (CIRCLE-SQUARE) ICON BUTTON (Zero Colored Edge!)
	--// =========================================================================
	local CloseUI = Instance.new("ImageButton")
	local CloseUICorner = Instance.new("UICorner")

	CloseUI.Name = RandomName()
	CloseUI.Parent = Khaw
	CloseUI.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseUI.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	CloseUI.BackgroundTransparency = 0
	CloseUI.BorderSizePixel = 0
	CloseUI.Position = UDim2.new(0.06, 0, 0.22, 0)
	CloseUI.Size = UDim2.new(0, 56, 0, 56)
	CloseUI.Image = GetIcon(OpenButtonLogo)
	CloseUI.ScaleType = Enum.ScaleType.Fit
	CloseUI.AutoButtonColor = false
	CloseUI.ZIndex = 50

	-- Directly rounds the ImageButton into a clean circle-square (squircle) with no border!
	CloseUICorner.CornerRadius = UDim.new(0, 14)
	CloseUICorner.Parent = CloseUI

	local wasButtonDragged = lak(CloseUI)

	--// Smart Mobile vs PC Detection
	local detectedMobile = IsMobilePlatform()
	local forceShowOnPC = Flags["_ShowFloatingButton"] == true
	CloseUI.Visible = detectedMobile or forceShowOnPC

	TrackConn(UserInputService.LastInputTypeChanged:Connect(function(lastType)
		if lastType == Enum.UserInputType.Touch then
			detectedMobile = true
			CloseUI.Visible = true
		end
	end))

	local ActiveDropdownClose = nil

	local isUiOpen = true
	local function closeopenui()
		isUiOpen = not isUiOpen
		if not isUiOpen and ActiveDropdownClose then
			ActiveDropdownClose()
		end
		if CloseUI.Visible then
			task.spawn(function()
				tw({v = CloseUI, t = 0.12, s = "Quart", d = "Out", g = {Size = UDim2.new(0, 46, 0, 46)}}):Play()
				task.wait(0.12)
				tw({v = CloseUI, t = 0.22, s = "Back", d = "Out", g = {Size = UDim2.new(0, 56, 0, 56)}}):Play()
			end)
		end

		if isUiOpen then
			Background_1.Visible = true
			tw({v = Background_1, t = 0.4, s = "Back", d = "Out", g = {Size = UDim2.new(0, 574, 0, 365)}}):Play()
		else
			local hideTween = tw({v = Background_1, t = 0.25, s = "Quart", d = "In", g = {Size = UDim2.new(0, 0, 0, 0)}})
			hideTween.Completed:Connect(function()
				if not isUiOpen then Background_1.Visible = false end
			end)
			hideTween:Play()
		end
	end

	TrackConn(CloseUI.MouseButton1Click:Connect(function()
		if not wasButtonDragged() then
			closeopenui()
		end
	end))

	TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == ToggleKey then
			closeopenui()
		end
	end))

	--// Window Controller Object
	local WindowObj = {
		Flags = Flags,
		Config = Flags,
		IsMobile = detectedMobile
	}

	function WindowObj:SetToggleKey(newKey)
		ToggleKey = ParseKeyCode(newKey)
		SaveFlag("_MenuToggleKey", ToggleKey.Name)
	end

	function WindowObj:GetToggleKey()
		return ToggleKey
	end

	function WindowObj:SetMobileButtonVisible(state)
		forceShowOnPC = state and true or false
		SaveFlag("_ShowFloatingButton", forceShowOnPC)
		CloseUI.Visible = detectedMobile or forceShowOnPC
	end

	function WindowObj:SetOpenLogo(newAssetId)
		CloseUI.Image = GetIcon(newAssetId)
	end

	--// Config Helper Functions
	function WindowObj:GetConfigs()
		EnsureFolders()
		local list = {}
		if listfiles then
			pcall(function()
				for _, file in ipairs(listfiles(ProfilesFolder)) do
					local name = file:match("([^/\\]+)%.json$")
					if name then
						table.insert(list, name)
					end
				end
			end)
		end
		if #list == 0 then
			table.insert(list, CurrentConfigName)
		elseif not table.find(list, CurrentConfigName) then
			table.insert(list, 1, CurrentConfigName)
		end
		return list
	end

	function WindowObj:SaveConfig(profileName)
		local target = (profileName and #tostring(profileName) > 0) and tostring(profileName) or CurrentConfigName
		CurrentConfigName = target
		local ok = WriteConfigFile(target)
		return ok, target
	end

	function WindowObj:LoadConfig(profileName)
		local target = (profileName and #tostring(profileName) > 0) and tostring(profileName) or CurrentConfigName
		local path = GetConfigPath(target)
		if not (isfile and readfile and isfile(path)) then
			return false, "Config file not found"
		end

		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if not ok or type(decoded) ~= "table" then
			return false, "Invalid JSON in config"
		end

		CurrentConfigName = target
		Flags = decoded
		WindowObj.Flags = Flags
		WindowObj.Config = Flags

		local prevAuto = AutoSaveEnabled
		AutoSaveEnabled = false
		for flagName, elementCtrl in pairs(FlagElements) do
			if Flags[flagName] ~= nil and elementCtrl and elementCtrl.Set then
				pcall(elementCtrl.Set, Flags[flagName], true)
			end
		end
		AutoSaveEnabled = prevAuto
		return true, target
	end

	function WindowObj:DeleteConfig(profileName)
		local target = tostring(profileName or "")
		local path = GetConfigPath(target)
		if isfile and delfile and isfile(path) then
			pcall(delfile, path)
			return true
		end
		return false
	end

	function WindowObj:GetAutoloadConfig()
		if isfile and readfile and isfile(AutoloadFile) then
			local ok, txt = pcall(readfile, AutoloadFile)
			if ok and txt and #txt:gsub("%s+", "") > 0 then
				return txt:gsub("%s+", "")
			end
		end
		return "None"
	end

	function WindowObj:SetAutoloadConfig(profileName)
		EnsureFolders()
		if writefile then
			pcall(writefile, AutoloadFile, tostring(profileName))
			return true
		end
		return false
	end

	function WindowObj:ClearAutoloadConfig()
		if isfile and delfile and isfile(AutoloadFile) then
			pcall(delfile, AutoloadFile)
		elseif writefile then
			pcall(writefile, AutoloadFile, "")
		end
	end

	--// Animated Toast Notification
	function WindowObj:Notify(notifMeta)
		notifMeta = notifMeta or {}
		local NTitle = notifMeta.Title or "SyzenHub"
		local NDesc = notifMeta.Desc or notifMeta.Content or ""
		local NIcon = GetIcon(notifMeta.Icon or "bell")
		local NTime = notifMeta.Duration or 4

		local Wrapper = Instance.new("Frame")
		Wrapper.Name = RandomName()
		Wrapper.Parent = NotifHolder
		Wrapper.BackgroundTransparency = 1
		Wrapper.Size = UDim2.new(0, 290, 0, 0)

		local Card = Instance.new("Frame")
		Card.Name = RandomName()
		Card.Parent = Wrapper
		Card.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
		Card.BackgroundTransparency = 0.08
		Card.BorderSizePixel = 0
		Card.Position = UDim2.new(1, 320, 0, 0)
		Card.Size = UDim2.new(1, 0, 0, 68)
		Card.ClipsDescendants = true

		local UICorner_N = Instance.new("UICorner")
		UICorner_N.CornerRadius = UDim.new(0, 10)
		UICorner_N.Parent = Card

		local UIStroke_N = Instance.new("UIStroke")
		UIStroke_N.Color = Color3.fromRGB(255, 255, 255)
		UIStroke_N.Thickness = 1.2
		UIStroke_N.Transparency = 0.4
		UIStroke_N.Parent = Card
		ApplyThemeGradient(UIStroke_N, 35)

		local BgGlow = Instance.new("ImageLabel")
		BgGlow.Parent = Card
		BgGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		BgGlow.BackgroundTransparency = 1
		BgGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
		BgGlow.Size = UDim2.new(1, 40, 1, 40)
		BgGlow.Image = "rbxassetid://72380279434385"
		BgGlow.ImageTransparency = 0.92
		BgGlow.ScaleType = Enum.ScaleType.Crop
		ApplyThemeGradient(BgGlow)

		local IconBadge = Instance.new("Frame")
		IconBadge.Parent = Card
		IconBadge.AnchorPoint = Vector2.new(0, 0.5)
		IconBadge.Position = UDim2.new(0, 12, 0.5, -2)
		IconBadge.Size = UDim2.new(0, 36, 0, 36)
		IconBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		IconBadge.BackgroundTransparency = 0.85
		ApplyThemeGradient(IconBadge, 45)

		local BadgeCorner = Instance.new("UICorner")
		BadgeCorner.CornerRadius = UDim.new(0, 8)
		BadgeCorner.Parent = IconBadge

		local IconImg = Instance.new("ImageLabel")
		IconImg.Parent = IconBadge
		IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
		IconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconImg.Size = UDim2.new(0, 0, 0, 0)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = NIcon
		IconImg.ScaleType = Enum.ScaleType.Fit

		local Title_N = Instance.new("TextLabel")
		Title_N.Parent = Card
		Title_N.BackgroundTransparency = 1
		Title_N.Position = UDim2.new(0, 58, 0, 10)
		Title_N.Size = UDim2.new(1, -68, 0, 18)
		Title_N.FontFace = FontBold
		Title_N.RichText = true
		Title_N.Text = NTitle
		Title_N.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title_N.TextSize = 14
		Title_N.TextXAlignment = Enum.TextXAlignment.Left

		local Desc_N = Instance.new("TextLabel")
		Desc_N.Parent = Card
		Desc_N.BackgroundTransparency = 1
		Desc_N.Position = UDim2.new(0, 58, 0, 29)
		Desc_N.Size = UDim2.new(1, -68, 0, 28)
		Desc_N.FontFace = FontMedium
		Desc_N.RichText = true
		Desc_N.Text = NDesc
		Desc_N.TextColor3 = Color3.fromRGB(205, 205, 220)
		Desc_N.TextSize = 12
		Desc_N.TextWrapped = true
		Desc_N.TextXAlignment = Enum.TextXAlignment.Left
		Desc_N.TextYAlignment = Enum.TextYAlignment.Top

		local BarBg = Instance.new("Frame")
		BarBg.Parent = Card
		BarBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		BarBg.BorderSizePixel = 0
		BarBg.Position = UDim2.new(0, 0, 1, -3)
		BarBg.Size = UDim2.new(1, 0, 0, 3)

		local BarFill = Instance.new("Frame")
		BarFill.Parent = BarBg
		BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BarFill.BorderSizePixel = 0
		BarFill.Size = UDim2.new(1, 0, 1, 0)
		ApplyThemeGradient(BarFill)

		local DismissBtn = click(Card, 2)

		tw({v = Wrapper, t = 0.3, s = "Quart", d = "Out", g = {Size = UDim2.new(0, 290, 0, 68)}}):Play()
		tw({v = Card, t = 0.4, s = "Back", d = "Out", g = {Position = UDim2.new(0, 0, 0, 0)}}):Play()
		task.delay(0.1, function()
			tw({v = IconImg, t = 0.3, s = "Back", d = "Out", g = {Size = UDim2.new(0, 20, 0, 20)}}):Play()
		end)
		tw({v = BarFill, t = NTime, s = "Linear", d = "Out", g = {Size = UDim2.new(0, 0, 1, 0)}}):Play()

		local closed = false
		local function CloseNotif()
			if closed then return end
			closed = true
			tw({v = Card, t = 0.3, s = "Back", d = "In", g = {Position = UDim2.new(1, 320, 0, 0)}}):Play()
			task.wait(0.22)
			local collapse = tw({v = Wrapper, t = 0.2, s = "Quart", d = "Out", g = {Size = UDim2.new(0, 290, 0, 0)}})
			collapse.Completed:Connect(function() Wrapper:Destroy() end)
			collapse:Play()
		end

		DismissBtn.MouseButton1Click:Connect(CloseNotif)
		task.delay(NTime, CloseNotif)
	end

	--// Horizontal Tab Banner Carousel
	local Tab_1 = Instance.new("Frame")
	local ScrollingFrame_1 = Instance.new("ScrollingFrame")
	local UIListLayout_2 = Instance.new("UIListLayout")

	Tab_1.Name = RandomName()
	Tab_1.Parent = Background_1
	Tab_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Tab_1.BackgroundTransparency = 1
	Tab_1.Position = UDim2.new(0.5, 0, 0.6, 0)
	Tab_1.Size = UDim2.new(1, 0, 0.8, 0)

	ScrollingFrame_1.Name = RandomName()
	ScrollingFrame_1.Parent = Tab_1
	ScrollingFrame_1.Active = true
	ScrollingFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
	ScrollingFrame_1.BackgroundTransparency = 1
	ScrollingFrame_1.BorderSizePixel = 0
	ScrollingFrame_1.Position = UDim2.new(0.5, 0, 0.474, 0)
	ScrollingFrame_1.Size = UDim2.new(0.95, 0, 0.96, 0)
	ScrollingFrame_1.ClipsDescendants = true
	ScrollingFrame_1.CanvasSize = UDim2.new(0, 20, 0, 0)
	ScrollingFrame_1.ScrollBarThickness = 0
	ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.X

	UIListLayout_2.Parent = ScrollingFrame_1
	UIListLayout_2.Padding = UDim.new(0, 10)
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

	TrackConn(UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame_1.CanvasSize = UDim2.new(0, UIListLayout_2.AbsoluteContentSize.X + 20, 0, 0)
	end))

	local Return = Instance.new("Frame")
	local UICorner_Ret = Instance.new("UICorner")
	local UIGradient_Ret = Instance.new("UIGradient")
	local UIStroke_1z = Instance.new("UIStroke")
	local ImageLabel_1z = Instance.new("ImageLabel")
	local TextLabel_1z = Instance.new("TextLabel")

	Return.Name = RandomName()
	Return.Parent = Background_1
	Return.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Return.BorderSizePixel = 0
	Return.Position = UDim2.new(0.77, 0, 0.049, 0)
	Return.Size = UDim2.new(0, 110, 0, 29)
	Return.ClipsDescendants = true
	Return.Visible = false

	UICorner_Ret.Parent = Return
	UICorner_Ret.CornerRadius = UDim.new(0, 6)

	UIGradient_Ret.Parent = Return
	UIGradient_Ret.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 89, 89)),
		ColorSequenceKeypoint.new(0.483, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 0))
	}

	UIStroke_1z.Parent = Return
	UIStroke_1z.Color = Color3.fromRGB(255, 85, 127)
	UIStroke_1z.Thickness = 1.5

	ImageLabel_1z.Name = RandomName()
	ImageLabel_1z.Parent = Return
	ImageLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_1z.BackgroundTransparency = 1
	ImageLabel_1z.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel_1z.Size = UDim2.new(1, 50, 1, 0)
	ImageLabel_1z.Image = "rbxassetid://87782680483863"
	ImageLabel_1z.ImageTransparency = 0.84
	ImageLabel_1z.ScaleType = Enum.ScaleType.Crop

	TextLabel_1z.Name = RandomName()
	TextLabel_1z.Parent = Return
	TextLabel_1z.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel_1z.BackgroundTransparency = 1
	TextLabel_1z.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextLabel_1z.Size = UDim2.new(1, 0, 1, 0)
	TextLabel_1z.FontFace = FontBold
	TextLabel_1z.Text = "Back"
	TextLabel_1z.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_1z.TextSize = 14

	local ClickReturn = click(Return, 2)
	TrackConn(ClickReturn.MouseButton1Click:Connect(function()
		if ActiveDropdownClose then
			ActiveDropdownClose()
		end
		Header_1.Position = UDim2.new(0, -30, 0, 0)
		tw({v = Header_1, t = 0.3, s = "Back", d = "Out", g = {Position = UDim2.new(0, 0, 0, 0)}}):Play()
		tw({v = Title_1, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 1}}):Play()
		tw({v = Desc_1, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 1}}):Play()
		tw({v = Line_1, t = 0.2, s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()

		Desc_1.Text = Desc
		Title_1.Text = Title

		task.delay(0.15, function()
			tw({v = Title_1, t = 0.35, s = "Back", d = "Out", g = {TextTransparency = 0}}):Play()
			tw({v = Desc_1, t = 0.35, s = "Back", d = "Out", g = {TextTransparency = 0.45}}):Play()
			tw({v = Line_1, t = 0.35, s = "Back", d = "Out", g = {BackgroundTransparency = 0}}):Play()
		end)

		for _, pageFrame in ipairs(Env.PagesList) do pageFrame.Visible = false end

		Tab_1.Visible = true
		Tab_1.Size = UDim2.new(1, 0, 0, 0)
		tw({v = Tab_1, t = 0.35, s = "Back", d = "Out", g = {Size = UDim2.new(1, 0, 0.8, 0)}}):Play()

		tw({v = Return, t = 0.25, s = "Quart", d = "Out", g = {Position = UDim2.new(0.9, 0, 0.049, 0), BackgroundTransparency = 1}}):Play()
		UIStroke_1z.Enabled = false
		tw({v = ImageLabel_1z, t = 0.25, s = "Quart", d = "Out", g = {ImageTransparency = 1}}):Play()
		tw({v = TextLabel_1z, t = 0.25, s = "Quart", d = "Out", g = {TextTransparency = 1}}):Play()
		task.wait(0.2)
		Return.Visible = false
	end))

	--// Create Tab Method
	function WindowObj:Add(tabMeta)
		tabMeta = tabMeta or {}
		local TabTitle = tabMeta.Title or "Tab"
		local TabDesc = tabMeta.Desc or ""
		local Banner = tabMeta.Banner or Env.Banner.Genral

		local Addtab_1 = Instance.new("Frame")
		local Banner_1 = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local ClickTab = click(Addtab_1, 2)

		Addtab_1.Name = RandomName()
		Addtab_1.Parent = ScrollingFrame_1
		Addtab_1.BackgroundTransparency = 1
		Addtab_1.Size = UDim2.new(0, 100, 1, 0)

		Banner_1.Name = RandomName()
		Banner_1.Parent = Addtab_1
		Banner_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Banner_1.Position = UDim2.new(0.5, 0, 0.5, 0)
		Banner_1.Size = UDim2.new(1, 0, 1, 0)
		Banner_1.BackgroundTransparency = 1
		Banner_1.Image = GetIcon(Banner)
		Banner_1.ScaleType = Enum.ScaleType.Crop

		UICorner_2.Parent = Banner_1
		UICorner_2.CornerRadius = UDim.new(0, 10)

		TrackConn(ClickTab.MouseEnter:Connect(function()
			tw({v = Banner_1, t = 0.2, s = "Back", d = "Out", g = {Size = UDim2.new(1, 6, 1, -6)}}):Play()
		end))
		TrackConn(ClickTab.MouseLeave:Connect(function()
			tw({v = Banner_1, t = 0.2, s = "Quart", d = "Out", g = {Size = UDim2.new(1, 0, 1, 0)}}):Play()
		end))

		local Pages_1 = Instance.new("Frame")
		local UIListLayout_5 = Instance.new("UIListLayout")

		Pages_1.Name = RandomName()
		Pages_1.Parent = Background_1
		Pages_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Pages_1.BackgroundTransparency = 1
		Pages_1.Position = UDim2.new(0.5, 0, 0.588, 0)
		Pages_1.Size = UDim2.new(0.965, 0, 0.767, 0)
		Pages_1.Visible = false
		table.insert(Env.PagesList, Pages_1)

		UIListLayout_5.Parent = Pages_1
		UIListLayout_5.Padding = UDim.new(0, 6)
		UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center

		local Left_1 = Instance.new("ScrollingFrame")
		local UIListLayout_3 = Instance.new("UIListLayout")

		Left_1.Name = RandomName()
		Left_1.Parent = Pages_1
		Left_1.Active = true
		Left_1.BackgroundTransparency = 1
		Left_1.BorderSizePixel = 0
		Left_1.Size = UDim2.new(0, 275, 1, 0)
		Left_1.ClipsDescendants = true
		Left_1.ScrollBarThickness = 0
		Left_1.ScrollingDirection = Enum.ScrollingDirection.Y

		UIListLayout_3.Parent = Left_1
		UIListLayout_3.Padding = UDim.new(0, 7)
		UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

		local Right_1 = Instance.new("ScrollingFrame")
		local UIListLayout_6 = Instance.new("UIListLayout")

		Right_1.Name = RandomName()
		Right_1.Parent = Pages_1
		Right_1.Active = true
		Right_1.BackgroundTransparency = 1
		Right_1.BorderSizePixel = 0
		Right_1.Size = UDim2.new(0, 275, 1, 0)
		Right_1.ClipsDescendants = true
		Right_1.ScrollBarThickness = 0
		Right_1.ScrollingDirection = Enum.ScrollingDirection.Y

		UIListLayout_6.Parent = Right_1
		UIListLayout_6.Padding = UDim.new(0, 7)
		UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder

		TrackConn(UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Left_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 20)
		end))
		TrackConn(UIListLayout_6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Right_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_6.AbsoluteContentSize.Y + 20)
		end))

		TrackConn(ClickTab.MouseButton1Click:Connect(function()
			if ActiveDropdownClose then
				ActiveDropdownClose()
			end
			Header_1.Position = UDim2.new(0, -30, 0, 0)
			tw({v = Header_1, t = 0.3, s = "Back", d = "Out", g = {Position = UDim2.new(0, 0, 0, 0)}}):Play()
			tw({v = Title_1, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 1}}):Play()
			tw({v = Desc_1, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 1}}):Play()
			tw({v = Line_1, t = 0.2, s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()

			Desc_1.Text = TabDesc
			Title_1.Text = TabTitle

			task.delay(0.15, function()
				tw({v = Title_1, t = 0.35, s = "Back", d = "Out", g = {TextTransparency = 0}}):Play()
				tw({v = Desc_1, t = 0.35, s = "Back", d = "Out", g = {TextTransparency = 0.45}}):Play()
				tw({v = Line_1, t = 0.35, s = "Back", d = "Out", g = {BackgroundTransparency = 0}}):Play()
			end)

			Return.Visible = true
			UIStroke_1z.Enabled = true
			Return.Position = UDim2.new(0.9, 0, 0.049, 0)
			tw({v = Return, t = 0.3, s = "Back", d = "Out", g = {Position = UDim2.new(0.77, 0, 0.049, 0), BackgroundTransparency = 0}}):Play()
			tw({v = UIStroke_1z, t = 0.3, s = "Back", d = "Out", g = {Transparency = 0}}):Play()
			tw({v = ImageLabel_1z, t = 0.3, s = "Back", d = "Out", g = {ImageTransparency = 0.84}}):Play()
			tw({v = TextLabel_1z, t = 0.3, s = "Back", d = "Out", g = {TextTransparency = 0}}):Play()

			Tab_1.Visible = false
			for _, p in ipairs(Env.PagesList) do p.Visible = false end
			Pages_1.Size = UDim2.new(0.965, 0, 0, 0)
			Pages_1.Visible = true
			tw({v = Pages_1, t = 0.3, s = "Back", d = "Out", g = {Size = UDim2.new(0.965, 0, 0.767, 0)}}):Play()
		end))

		local function GetSide(side)
			if not side then return Left_1 end
			local sideLower = string.lower(tostring(side))
			if sideLower == "r" or sideLower == "right" or side == 2 then
				return Right_1
			end
			return Left_1
		end

		local SectionBuilder = {}

		function SectionBuilder:Section(secMeta)
			secMeta = secMeta or {}
			local SecTitle = secMeta.Title or "Section"
			local Side = secMeta.Side or "l"

			local Section_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIListLayout_4 = Instance.new("UIListLayout")
			local Title_2 = Instance.new("TextLabel")
			local UIPadding_2 = Instance.new("UIPadding")
			local Line_2 = Instance.new("Frame")

			Section_1.Name = RandomName()
			Section_1.Parent = GetSide(Side)
			Section_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Section_1.BackgroundTransparency = 0.55
			Section_1.BorderSizePixel = 0
			Section_1.Size = UDim2.new(1, 0, 0, 100)

			UICorner_3.Parent = Section_1
			UICorner_3.CornerRadius = UDim.new(0, 6)

			UIListLayout_4.Parent = Section_1
			UIListLayout_4.Padding = UDim.new(0, 6)
			UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

			Title_2.Name = RandomName()
			Title_2.Parent = Section_1
			Title_2.BackgroundTransparency = 1
			Title_2.LayoutOrder = -3
			Title_2.Size = UDim2.new(0.9, 0, 0, 20)
			Title_2.FontFace = FontBold
			Title_2.RichText = true
			Title_2.Text = SecTitle
			Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title_2.TextSize = 15

			UIPadding_2.Parent = Section_1
			UIPadding_2.PaddingTop = UDim.new(0, 7)

			Line_2.Name = RandomName()
			Line_2.Parent = Section_1
			Line_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Line_2.BorderSizePixel = 0
			Line_2.BackgroundTransparency = 0.25
			Line_2.LayoutOrder = -2
			Line_2.Size = UDim2.new(1, 0, 0, 1)
			ApplyThemeGradient(Line_2)

			TrackConn(UIListLayout_4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section_1.Size = UDim2.new(1, 0, 0, UIListLayout_4.AbsoluteContentSize.Y + 15)
			end))

			local ClassObj = {}

			--// BUTTON
			function ClassObj:Button(btnMeta)
				btnMeta = btnMeta or {}
				local BTitle = btnMeta.Title or "Button"
				local BDesc = btnMeta.Desc or nil
				local Callback = btnMeta.Callback or function() end
				local BIcon = btnMeta.Icon or nil

				if not BIcon and not BDesc then
					local Button = Instance.new("Frame")
					local Title_B = Instance.new("TextLabel")
					local UICorner_B = Instance.new("UICorner")
					local ImageLabel_B = Instance.new("ImageLabel")
					local Clickbutton = click(Button, 2)

					Button.Name = RandomName()
					Button.Parent = Section_1
					Button.AnchorPoint = Vector2.new(0.5, 0.5)
					Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Button.BorderSizePixel = 0
					Button.Size = UDim2.new(0.97, 0, 0, 32)
					Button.ClipsDescendants = true
					ApplyThemeGradient(Button)

					Title_B.Name = RandomName()
					Title_B.Parent = Button
					Title_B.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_B.BackgroundTransparency = 1
					Title_B.Position = UDim2.new(0.5, 0, 0.5, 0)
					Title_B.Size = UDim2.new(1, 0, 1, 0)
					Title_B.FontFace = FontBold
					Title_B.RichText = true
					Title_B.Text = BTitle
					Title_B.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title_B.TextSize = 14

					UICorner_B.Parent = Button
					UICorner_B.CornerRadius = UDim.new(0, 6)

					ImageLabel_B.Name = RandomName()
					ImageLabel_B.Parent = Button
					ImageLabel_B.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_B.BackgroundTransparency = 1
					ImageLabel_B.Position = UDim2.new(0.5, 0, 0.5, 0)
					ImageLabel_B.Size = UDim2.new(1, 50, 1, 0)
					ImageLabel_B.Image = "rbxassetid://72380279434385"
					ImageLabel_B.ImageTransparency = 0.8
					ImageLabel_B.ScaleType = Enum.ScaleType.Crop

					TrackConn(Clickbutton.MouseButton1Click:Connect(function()
						task.spawn(Callback)
						tw({v = Button, t = 0.12, s = "Quart", d = "Out", g = {Size = UDim2.new(0.91, 0, 0, 30)}}):Play()
						task.delay(0.1, function()
							tw({v = Button, t = 0.2, s = "Back", d = "Out", g = {Size = UDim2.new(0.97, 0, 0, 32)}}):Play()
						end)
						EffectClick(Clickbutton, Button, false)
					end))

					local Index = {}
					function Index:Fire() task.spawn(Callback) end
					function Index:Title(v) Title_B.Text = tostring(v) end
					function Index:UpdateTitle(v) Title_B.Text = tostring(v) end
					function Index:Visible(v) Button.Visible = v end
					return Index
				else
					local ButtonImage = Instance.new("Frame")
					local Title_B = Instance.new("TextLabel")
					local UICorner_B = Instance.new("UICorner")
					local ImageLabel_B = Instance.new("ImageLabel")
					local icon_1 = Instance.new("ImageLabel")
					local Desc_B = Instance.new("TextLabel")
					local next_1 = Instance.new("ImageLabel")
					local ClickButton = click(ButtonImage, 2)

					ButtonImage.Name = RandomName()
					ButtonImage.Parent = Section_1
					ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
					ButtonImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					ButtonImage.BackgroundTransparency = 0.5
					ButtonImage.BorderSizePixel = 0
					ButtonImage.Size = UDim2.new(0.97, 0, 0, 50)
					ButtonImage.ClipsDescendants = true
					AddHoverEffect(ButtonImage, 0.5)

					Title_B.Name = RandomName()
					Title_B.Parent = ButtonImage
					Title_B.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_B.BackgroundTransparency = 1
					Title_B.Position = UDim2.new(0.576, 0, 0.368, 0)
					Title_B.Size = UDim2.new(0.776, 0, 0.07, 20)
					Title_B.FontFace = FontBold
					Title_B.RichText = true
					Title_B.Text = BTitle
					Title_B.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title_B.TextSize = 14
					Title_B.TextXAlignment = Enum.TextXAlignment.Left

					UICorner_B.Parent = ButtonImage
					UICorner_B.CornerRadius = UDim.new(0, 6)

					ImageLabel_B.Name = RandomName()
					ImageLabel_B.Parent = ButtonImage
					ImageLabel_B.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel_B.BackgroundTransparency = 1
					ImageLabel_B.Position = UDim2.new(0.5, 0, 0.5, 0)
					ImageLabel_B.Size = UDim2.new(1, 50, 1, 0)
					ImageLabel_B.Image = "rbxassetid://72380279434385"
					ImageLabel_B.ImageTransparency = 0.9
					ImageLabel_B.ScaleType = Enum.ScaleType.Crop
					ApplyThemeGradient(ImageLabel_B)

					icon_1.Name = RandomName()
					icon_1.Parent = ButtonImage
					icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
					icon_1.BackgroundTransparency = 1
					icon_1.Position = UDim2.new(0, 25, 0.5, 0)
					icon_1.Size = UDim2.new(0, 32, 0, 32)
					icon_1.Image = GetIcon(BIcon or "sparkles")
					icon_1.ScaleType = Enum.ScaleType.Fit

					Desc_B.Name = RandomName()
					Desc_B.Parent = ButtonImage
					Desc_B.AnchorPoint = Vector2.new(0.5, 0.5)
					Desc_B.BackgroundTransparency = 1
					Desc_B.Position = UDim2.new(0.576, 0, 0.665, 0)
					Desc_B.Size = UDim2.new(0.776, 0, -0.036, 20)
					Desc_B.FontFace = FontMedium
					Desc_B.RichText = true
					Desc_B.Text = BDesc or ""
					Desc_B.TextColor3 = Color3.fromRGB(255, 255, 255)
					Desc_B.TextSize = 11
					Desc_B.TextTransparency = 0.45
					Desc_B.TextXAlignment = Enum.TextXAlignment.Left

					next_1.Name = RandomName()
					next_1.Parent = ButtonImage
					next_1.AnchorPoint = Vector2.new(0.5, 0.5)
					next_1.BackgroundTransparency = 1
					next_1.Position = UDim2.new(0, 245, 0.5, 0)
					next_1.Size = UDim2.new(0, 20, 0, 20)
					next_1.Image = GetIcon("arrow_right")
					next_1.ScaleType = Enum.ScaleType.Fit

					TrackConn(ClickButton.MouseButton1Click:Connect(function()
						task.spawn(Callback)
						tw({v = next_1, t = 0.14, s = "Back", d = "Out", g = {Position = UDim2.new(0, 253, 0.5, 0)}}):Play()
						task.delay(0.1, function()
							tw({v = next_1, t = 0.18, s = "Back", d = "Out", g = {Position = UDim2.new(0, 245, 0.5, 0)}}):Play()
						end)
						EffectClick(ClickButton, ButtonImage, true)
					end))

					local Index = {}
					function Index:Fire() task.spawn(Callback) end
					function Index:Title(v) Title_B.Text = tostring(v) end
					function Index:UpdateTitle(v) Title_B.Text = tostring(v) end
					function Index:Desc(v) Desc_B.Text = tostring(v) end
					function Index:Icon(v) icon_1.Image = GetIcon(v) end
					function Index:Visible(v) ButtonImage.Visible = v end
					return Index
				end
			end

			--// THUMBNAIL IMAGE
			function ClassObj:ThumnailsImage(imgMeta)
				imgMeta = imgMeta or {}
				local Banner = imgMeta.Banner
				local Y = imgMeta.SizeY or 150

				local Image = Instance.new("ImageLabel")
				Image.Name = RandomName()
				Image.Parent = Section_1
				Image.BackgroundTransparency = 1
				Image.BorderSizePixel = 0
				Image.Size = UDim2.new(0.97, 0, 0, Y)
				Image.Image = GetIcon(Banner)
				Image.ScaleType = Enum.ScaleType.Crop

				local UICorner_I = Instance.new("UICorner")
				UICorner_I.Parent = Image
				UICorner_I.CornerRadius = UDim.new(0, 6)

				local Index = {}
				function Index:Image(v) Image.Image = GetIcon(v) end
				function Index:Y(v) Image.Size = UDim2.new(0.97, 0, 0, v) end
				function Index:Visible(v) Image.Visible = v end
				return Index
			end

			local function GetAlig(v)
				if v == "l" then return Enum.TextXAlignment.Left
				elseif v == "r" then return Enum.TextXAlignment.Right
				else return Enum.TextXAlignment.Center end
			end

			--// LABEL
			function ClassObj:Label(lblMeta)
				lblMeta = type(lblMeta) == "table" and lblMeta or {Title = tostring(lblMeta), Side = "l"}
				local LTitle = lblMeta.Title or "Label"
				local LSide = lblMeta.Side

				local Label = Instance.new("TextLabel")
				Label.Name = RandomName()
				Label.Parent = Section_1
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(0.9, 0, 0, 20)
				Label.FontFace = FontBold
				Label.RichText = true
				Label.Text = LTitle
				Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				Label.TextSize = 14
				Label.TextXAlignment = GetAlig(LSide)

				local Index = {}
				function Index:Title(v) Label.Text = tostring(v) end
				function Index:Set(v) Label.Text = tostring(v) end
				function Index:Visible(v) Label.Visible = v end
				return Index
			end

			--// LINE
			function ClassObj:Line()
				local Line_Sub = Instance.new("Frame")
				Line_Sub.Name = RandomName()
				Line_Sub.Parent = Section_1
				Line_Sub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Line_Sub.BorderSizePixel = 0
				Line_Sub.BackgroundTransparency = 0.25
				Line_Sub.Size = UDim2.new(1, 0, 0, 1)
				ApplyThemeGradient(Line_Sub)

				local Index = {}
				function Index:Visible(v) Line_Sub.Visible = v end
				return Index
			end

			--// DISCORD
			function ClassObj:Discord(Link)
				local Discord = Instance.new("Frame")
				local Title_D = Instance.new("TextLabel")
				local UICorner_D = Instance.new("UICorner")
				local ImageLabel_D = Instance.new("ImageLabel")
				local UIGradient_D = Instance.new("UIGradient")
				local icon_D = Instance.new("ImageLabel")
				local Desc_D = Instance.new("TextLabel")
				local ClickDiscord = click(Discord, 2)

				Discord.Name = RandomName()
				Discord.Parent = Section_1
				Discord.AnchorPoint = Vector2.new(0.5, 0.5)
				Discord.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Discord.BorderSizePixel = 0
				Discord.Size = UDim2.new(0.97, 0, 0, 60)
				Discord.ClipsDescendants = true

				Title_D.Name = RandomName()
				Title_D.Parent = Discord
				Title_D.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_D.BackgroundTransparency = 1
				Title_D.Position = UDim2.new(0.611, 0, 0.408, 0)
				Title_D.Size = UDim2.new(0.705, 0, 0.15, 20)
				Title_D.FontFace = FontBold
				Title_D.Text = "Discord"
				Title_D.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_D.TextSize = 16
				Title_D.TextXAlignment = Enum.TextXAlignment.Left

				UICorner_D.Parent = Discord
				UICorner_D.CornerRadius = UDim.new(0, 6)

				ImageLabel_D.Name = RandomName()
				ImageLabel_D.Parent = Discord
				ImageLabel_D.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_D.BackgroundTransparency = 1
				ImageLabel_D.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_D.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_D.Image = "rbxassetid://72380279434385"
				ImageLabel_D.ImageTransparency = 0.9
				ImageLabel_D.ScaleType = Enum.ScaleType.Crop

				UIGradient_D.Parent = Discord
				UIGradient_D.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 130, 255))
				}

				icon_D.Name = RandomName()
				icon_D.Parent = Discord
				icon_D.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_D.BackgroundTransparency = 1
				icon_D.Position = UDim2.new(0, 35, 0.5, 0)
				icon_D.Size = UDim2.new(0, 40, 0, 40)
				icon_D.Image = GetIcon("discord")
				icon_D.ScaleType = Enum.ScaleType.Crop

				Desc_D.Name = RandomName()
				Desc_D.Parent = Discord
				Desc_D.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_D.BackgroundTransparency = 1
				Desc_D.Position = UDim2.new(0.611, 0, 0.675, 0)
				Desc_D.Size = UDim2.new(0.705, 0, -0.016, 20)
				Desc_D.FontFace = FontMedium
				Desc_D.Text = tostring(Link)
				Desc_D.TextColor3 = Color3.fromRGB(255, 255, 255)
				Desc_D.TextSize = 13
				Desc_D.TextTransparency = 0.45
				Desc_D.TextXAlignment = Enum.TextXAlignment.Left

				TrackConn(ClickDiscord.MouseButton1Click:Connect(function()
					if setclipboard then pcall(setclipboard, tostring(Link)) end
					EffectClick(ClickDiscord, Discord, false)
					WindowObj:Notify({
						Title = "Discord Copied",
						Desc = "Invite link copied to clipboard!",
						Icon = "discord",
						Duration = 2.5
					})
				end))
			end

			--// ICON INFO CARD
			function ClassObj:Icon(icMeta)
				icMeta = icMeta or {}
				local IIcon = icMeta.Icon or "sparkles"
				local ITitle = icMeta.Title or "Info"
				local IDesc = icMeta.Desc or ""

				local ToggleImage = Instance.new("Frame")
				local Title_I = Instance.new("TextLabel")
				local UICorner_I = Instance.new("UICorner")
				local ImageLabel_I = Instance.new("ImageLabel")
				local icon_1 = Instance.new("ImageLabel")
				local Desc_I = Instance.new("TextLabel")

				ToggleImage.Name = RandomName()
				ToggleImage.Parent = Section_1
				ToggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
				ToggleImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				ToggleImage.BackgroundTransparency = 0.5
				ToggleImage.BorderSizePixel = 0
				ToggleImage.Size = UDim2.new(0.97, 0, 0, 50)
				ToggleImage.ClipsDescendants = true

				Title_I.Name = RandomName()
				Title_I.Parent = ToggleImage
				Title_I.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_I.BackgroundTransparency = 1
				Title_I.Position = UDim2.new(0.576, 0, 0.368, 0)
				Title_I.Size = UDim2.new(0.776, 0, 0.07, 20)
				Title_I.FontFace = FontBold
				Title_I.RichText = true
				Title_I.Text = ITitle
				Title_I.TextColor3 = Color3.fromRGB(0, 170, 255)
				Title_I.TextSize = 14
				Title_I.TextXAlignment = Enum.TextXAlignment.Left

				UICorner_I.Parent = ToggleImage
				UICorner_I.CornerRadius = UDim.new(0, 6)

				ImageLabel_I.Name = RandomName()
				ImageLabel_I.Parent = ToggleImage
				ImageLabel_I.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_I.BackgroundTransparency = 1
				ImageLabel_I.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_I.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_I.Image = "rbxassetid://72380279434385"
				ImageLabel_I.ImageTransparency = 0.9
				ImageLabel_I.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_I)

				icon_1.Name = RandomName()
				icon_1.Parent = ToggleImage
				icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_1.BackgroundTransparency = 1
				icon_1.Position = UDim2.new(0, 25, 0.5, 0)
				icon_1.Size = UDim2.new(0, 32, 0, 32)
				icon_1.Image = GetIcon(IIcon)
				icon_1.ScaleType = Enum.ScaleType.Fit

				Desc_I.Name = RandomName()
				Desc_I.Parent = ToggleImage
				Desc_I.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_I.BackgroundTransparency = 1
				Desc_I.Position = UDim2.new(0.576, 0, 0.665, 0)
				Desc_I.Size = UDim2.new(0.776, 0, -0.036, 20)
				Desc_I.FontFace = FontMedium
				Desc_I.RichText = true
				Desc_I.Text = IDesc
				Desc_I.TextColor3 = Color3.fromRGB(255, 255, 255)
				Desc_I.TextSize = 11
				Desc_I.TextTransparency = 0.45
				Desc_I.TextXAlignment = Enum.TextXAlignment.Left
			end

			--// TOGGLE
			function ClassObj:Toggle(togMeta)
				togMeta = togMeta or {}
				local TTitle = togMeta.Title or "Toggle"
				local TDesc = togMeta.Desc or ""
				local TIcon = togMeta.Icon or nil
				local Flag = togMeta.Flag or TTitle
				local DefaultVal = Flags[Flag] ~= nil and Flags[Flag] or (togMeta.Value or false)
				local Callback = togMeta.Callback or function() end

				local ToggleFrame = Instance.new("Frame")
				local Title_T = Instance.new("TextLabel")
				local UICorner_T = Instance.new("UICorner")
				local ImageLabel_T = Instance.new("ImageLabel")
				local Desc_T = Instance.new("TextLabel")
				local Check_1 = Instance.new("Frame")
				local ColorFrame_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local ImageLabel_2 = Instance.new("ImageLabel")
				local UICorner_3 = Instance.new("UICorner")
				local ClickToggle = click(ToggleFrame, 2)

				ToggleFrame.Name = RandomName()
				ToggleFrame.Parent = Section_1
				ToggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				ToggleFrame.BackgroundTransparency = 0.5
				ToggleFrame.BorderSizePixel = 0
				ToggleFrame.Size = UDim2.new(0.97, 0, 0, 50)
				ToggleFrame.ClipsDescendants = true
				AddHoverEffect(ToggleFrame, 0.5)

				local textPosX = TIcon and 0.576 or 0.5
				local textSizeX = TIcon and 0.776 or 0.928

				Title_T.Name = RandomName()
				Title_T.Parent = ToggleFrame
				Title_T.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_T.BackgroundTransparency = 1
				Title_T.Position = UDim2.new(textPosX, 0, 0.368, 0)
				Title_T.Size = UDim2.new(textSizeX, 0, 0.07, 20)
				Title_T.FontFace = FontBold
				Title_T.RichText = true
				Title_T.Text = TTitle
				Title_T.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_T.TextSize = 14
				Title_T.TextXAlignment = Enum.TextXAlignment.Left
				Title_T.TextTransparency = 0.5

				UICorner_T.Parent = ToggleFrame
				UICorner_T.CornerRadius = UDim.new(0, 6)

				ImageLabel_T.Name = RandomName()
				ImageLabel_T.Parent = ToggleFrame
				ImageLabel_T.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_T.BackgroundTransparency = 1
				ImageLabel_T.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_T.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_T.Image = "rbxassetid://72380279434385"
				ImageLabel_T.ImageTransparency = 0.9
				ImageLabel_T.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_T)

				local icon_1
				if TIcon then
					icon_1 = Instance.new("ImageLabel")
					icon_1.Name = RandomName()
					icon_1.Parent = ToggleFrame
					icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
					icon_1.BackgroundTransparency = 1
					icon_1.Position = UDim2.new(0, 25, 0.5, 0)
					icon_1.Size = UDim2.new(0, 32, 0, 32)
					icon_1.Image = GetIcon(TIcon)
					icon_1.ScaleType = Enum.ScaleType.Fit
				end

				Desc_T.Name = RandomName()
				Desc_T.Parent = ToggleFrame
				Desc_T.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_T.BackgroundTransparency = 1
				Desc_T.Position = UDim2.new(textPosX, 0, 0.665, 0)
				Desc_T.Size = UDim2.new(textSizeX, 0, -0.036, 20)
				Desc_T.FontFace = FontMedium
				Desc_T.RichText = true
				Desc_T.Text = TDesc
				Desc_T.TextColor3 = Color3.fromRGB(255, 255, 255)
				Desc_T.TextSize = 11
				Desc_T.TextTransparency = 0.45
				Desc_T.TextXAlignment = Enum.TextXAlignment.Left

				Check_1.Name = RandomName()
				Check_1.Parent = ToggleFrame
				Check_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Check_1.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				Check_1.BorderSizePixel = 0
				Check_1.Position = UDim2.new(0.9, 0, 0.5, 0)
				Check_1.Size = UDim2.new(0, 25, 0, 25)
				Check_1.ClipsDescendants = true

				ColorFrame_1.Name = RandomName()
				ColorFrame_1.Parent = Check_1
				ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ColorFrame_1.BorderSizePixel = 0
				ColorFrame_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				ColorFrame_1.Size = UDim2.new(1, 0, 1, 0)
				ApplyThemeGradient(ColorFrame_1, 48)

				UICorner_2.Parent = ColorFrame_1
				UICorner_3.Parent = Check_1

				ImageLabel_2.Name = RandomName()
				ImageLabel_2.Parent = ColorFrame_1
				ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_2.BackgroundTransparency = 1
				ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_2.Size = UDim2.new(0, 13, 0, 13)
				ImageLabel_2.Image = GetIcon("check")
				ImageLabel_2.ScaleType = Enum.ScaleType.Fit

				local function SetToggle(newVal, noSave)
					DefaultVal = newVal and true or false
					if not noSave then SaveFlag(Flag, DefaultVal) else Flags[Flag] = DefaultVal end
					task.spawn(Callback, DefaultVal)
					if not DefaultVal then
						tw({v = ColorFrame_1, t = 0.25, s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
						tw({v = ImageLabel_2, t = 0.2, s = "Back", d = "In", g = {Size = UDim2.new(0, 0, 0, 0)}}):Play()
						tw({v = Title_T, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 0.5}}):Play()
					else
						tw({v = ColorFrame_1, t = 0.25, s = "Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
						tw({v = Title_T, t = 0.2, s = "Quart", d = "Out", g = {TextTransparency = 0}}):Play()
						tw({v = ImageLabel_2, t = 0.14, s = "Back", d = "Out", g = {Size = UDim2.new(0, 19, 0, 19)}}):Play()
						task.delay(0.1, function()
							tw({v = ImageLabel_2, t = 0.18, s = "Back", d = "Out", g = {Size = UDim2.new(0, 13, 0, 13)}}):Play()
						end)
					end
				end

				TrackConn(ClickToggle.MouseButton1Click:Connect(function()
					EffectClick(ClickToggle, ToggleFrame, true)
					SetToggle(not DefaultVal)
				end))

				SetToggle(DefaultVal, true)
				FlagElements[Flag] = { Set = SetToggle }

				local Index = {}
				function Index:Title(v) Title_T.Text = tostring(v) end
				function Index:Desc(v) Desc_T.Text = tostring(v or TDesc) end
				function Index:Value(v) SetToggle(v) end
				function Index:Set(v) SetToggle(v) end
				function Index:Icon(v) if icon_1 then icon_1.Image = GetIcon(v) end end
				function Index:Visible(v) ToggleFrame.Visible = v end
				return Index
			end

			--// PARAGRAPH
			function ClassObj:Paragraph(pMeta)
				pMeta = pMeta or {}
				local PTitle = pMeta.Title or "Paragraph"
				local PDesc = pMeta.Desc or ""

				local Paragarp = Instance.new("Frame")
				local UICorner_P = Instance.new("UICorner")
				local ImageLabel_P = Instance.new("ImageLabel")
				local Inside_1 = Instance.new("Frame")
				local UIListLayout_P = Instance.new("UIListLayout")
				local Title_P = Instance.new("TextLabel")
				local Desc_P = Instance.new("TextLabel")
				local UIPadding_P = Instance.new("UIPadding")

				Paragarp.Name = RandomName()
				Paragarp.Parent = Section_1
				Paragarp.AnchorPoint = Vector2.new(0.5, 0.5)
				Paragarp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Paragarp.BackgroundTransparency = 0.5
				Paragarp.BorderSizePixel = 0
				Paragarp.Size = UDim2.new(0.97, 0, 0, 70)
				Paragarp.ClipsDescendants = true

				UICorner_P.Parent = Paragarp
				UICorner_P.CornerRadius = UDim.new(0, 6)

				ImageLabel_P.Name = RandomName()
				ImageLabel_P.Parent = Paragarp
				ImageLabel_P.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_P.BackgroundTransparency = 1
				ImageLabel_P.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_P.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_P.Image = "rbxassetid://72380279434385"
				ImageLabel_P.ImageTransparency = 0.9
				ImageLabel_P.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_P)

				Inside_1.Name = RandomName()
				Inside_1.Parent = Paragarp
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundTransparency = 1
				Inside_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				Inside_1.Size = UDim2.new(1, 0, 1, 0)

				UIListLayout_P.Parent = Inside_1
				UIListLayout_P.Padding = UDim.new(0, 2)
				UIListLayout_P.SortOrder = Enum.SortOrder.LayoutOrder

				Title_P.Name = RandomName()
				Title_P.Parent = Inside_1
				Title_P.BackgroundTransparency = 1
				Title_P.Size = UDim2.new(0.93, 0, 0, 16)
				Title_P.FontFace = FontBold
				Title_P.RichText = true
				Title_P.Text = PTitle
				Title_P.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_P.TextSize = 14
				Title_P.TextXAlignment = Enum.TextXAlignment.Left

				Desc_P.Name = RandomName()
				Desc_P.Parent = Inside_1
				Desc_P.BackgroundTransparency = 1
				Desc_P.Size = UDim2.new(0.93, 0, 0, 0)
				Desc_P.FontFace = FontMedium
				Desc_P.RichText = true
				Desc_P.Text = PDesc
				Desc_P.TextColor3 = Color3.fromRGB(255, 255, 255)
				Desc_P.TextSize = 11
				Desc_P.TextTransparency = 0.45
				Desc_P.TextWrapped = true
				Desc_P.TextXAlignment = Enum.TextXAlignment.Left
				Desc_P.TextYAlignment = Enum.TextYAlignment.Top

				UIPadding_P.Parent = Inside_1
				UIPadding_P.PaddingLeft = UDim.new(0, 10)
				UIPadding_P.PaddingTop = UDim.new(0, 6)

				local function RefreshBounds()
					task.defer(function()
						local descHeight = Desc_P.TextBounds.Y + 6
						Desc_P.Size = UDim2.new(0.93, 0, 0, descHeight)
						Paragarp.Size = UDim2.new(0.97, 0, 0, descHeight + 30)
					end)
				end
				RefreshBounds()

				local Index = {}
				function Index:Title(v) Title_P.Text = tostring(v) end
				function Index:Desc(v) Desc_P.Text = tostring(v); RefreshBounds() end
				function Index:Visible(v) Paragarp.Visible = v end
				return Index
			end
			ClassObj.Paragarp = ClassObj.Paragraph

			--// TEXTBOX
			function ClassObj:Textbox(tbMeta)
				tbMeta = tbMeta or {}
				local Flag = tbMeta.Flag or tbMeta.PlaceHolder or "Textbox"
				local Value = Flags[Flag] ~= nil and Flags[Flag] or (tbMeta.Value or "")
				local PlaceHolder = tbMeta.PlaceHolder or "Input..."
				local ClearOnFocus = tbMeta.ClearOnFocus or false
				local Callback = tbMeta.Callback or function() end

				local Textbox = Instance.new("Frame")
				local UICorner_TB = Instance.new("UICorner")
				local ImageLabel_TB = Instance.new("ImageLabel")
				local Edit_1 = Instance.new("TextBox")
				local UICorner_2 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")

				Textbox.Name = RandomName()
				Textbox.Parent = Section_1
				Textbox.AnchorPoint = Vector2.new(0.5, 0.5)
				Textbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Textbox.BackgroundTransparency = 0.5
				Textbox.BorderSizePixel = 0
				Textbox.Size = UDim2.new(0.97, 0, 0, 40)
				Textbox.ClipsDescendants = true

				UICorner_TB.Parent = Textbox
				UICorner_TB.CornerRadius = UDim.new(0, 6)

				ImageLabel_TB.Name = RandomName()
				ImageLabel_TB.Parent = Textbox
				ImageLabel_TB.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_TB.BackgroundTransparency = 1
				ImageLabel_TB.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_TB.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_TB.Image = "rbxassetid://72380279434385"
				ImageLabel_TB.ImageTransparency = 0.9
				ImageLabel_TB.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_TB)

				Edit_1.Name = RandomName()
				Edit_1.Parent = Textbox
				Edit_1.Active = true
				Edit_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Edit_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Edit_1.BackgroundTransparency = 0.85
				Edit_1.BorderSizePixel = 0
				Edit_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				Edit_1.Size = UDim2.new(0.95, 0, 0.7, 0)
				Edit_1.FontFace = FontBold
				Edit_1.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
				Edit_1.PlaceholderText = tostring(PlaceHolder)
				Edit_1.RichText = true
				Edit_1.Text = tostring(Value)
				Edit_1.TextColor3 = Color3.fromRGB(255, 255, 255)
				Edit_1.TextSize = 14
				Edit_1.ClearTextOnFocus = ClearOnFocus
				ApplyThemeGradient(Edit_1)

				UICorner_2.Parent = Edit_1
				UICorner_2.CornerRadius = UDim.new(1, 0)

				UIStroke_1.Parent = Edit_1
				UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_1.Thickness = 1
				UIStroke_1.Transparency = 0.5
				ApplyThemeGradient(UIStroke_1)

				local function SetText(newTxt, noSave)
					Edit_1.Text = tostring(newTxt)
					if not noSave then SaveFlag(Flag, Edit_1.Text) else Flags[Flag] = Edit_1.Text end
					pcall(Callback, Edit_1.Text)
				end

				TrackConn(Edit_1.FocusLost:Connect(function()
					SaveFlag(Flag, Edit_1.Text)
					pcall(Callback, Edit_1.Text)
					tw({v = UIStroke_1, t = 0.25, s = "Quart", d = "Out", g = {Transparency = 0.5}}):Play()
				end))

				TrackConn(Edit_1.Focused:Connect(function()
					tw({v = UIStroke_1, t = 0.25, s = "Quart", d = "Out", g = {Transparency = 0}}):Play()
				end))

				Flags[Flag] = tostring(Value)
				FlagElements[Flag] = { Set = SetText }

				local Index = {}
				function Index:Value(v) SetText(v) end
				function Index:Set(v) SetText(v) end
				function Index:GetText() return Edit_1.Text end
				function Index:Visible(v) Textbox.Visible = v end
				return Index
			end

			--// SLIDER
			function ClassObj:Slider(info)
				info = info or {}
				local STitle = info.Title or "Slider"
				local Min = info.Min or 0
				local Max = info.Max or 100
				local Rounding = info.Rounding or 0
				local Flag = info.Flag or STitle
				local Value = Flags[Flag] ~= nil and tonumber(Flags[Flag]) or (info.Value or Min)
				local Callback = info.Callback or info.CallBack or function() end

				local Slider = Instance.new("Frame")
				local UICorner_S = Instance.new("UICorner")
				local ImageLabel_S = Instance.new("ImageLabel")
				local Title_S = Instance.new("TextLabel")
				local Bar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local BarValue_1 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local ValueBox_1 = Instance.new("TextBox")
				local UICorner_4 = Instance.new("UICorner")
				local Slide = click(Bar_1, 2)

				Slider.Name = RandomName()
				Slider.Parent = Section_1
				Slider.AnchorPoint = Vector2.new(0.5, 0.5)
				Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Slider.BackgroundTransparency = 0.5
				Slider.BorderSizePixel = 0
				Slider.Size = UDim2.new(0.97, 0, 0, 60)
				Slider.ClipsDescendants = true
				AddHoverEffect(Slider, 0.5)

				UICorner_S.Parent = Slider
				UICorner_S.CornerRadius = UDim.new(0, 6)

				ImageLabel_S.Name = RandomName()
				ImageLabel_S.Parent = Slider
				ImageLabel_S.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_S.BackgroundTransparency = 1
				ImageLabel_S.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_S.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_S.Image = "rbxassetid://72380279434385"
				ImageLabel_S.ImageTransparency = 0.9
				ImageLabel_S.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_S)

				Title_S.Name = RandomName()
				Title_S.Parent = Slider
				Title_S.BackgroundTransparency = 1
				Title_S.Position = UDim2.new(0.036, 0, 0.085, 0)
				Title_S.Size = UDim2.new(0.928, 0, 0, 20)
				Title_S.FontFace = FontBold
				Title_S.RichText = true
				Title_S.Text = STitle
				Title_S.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_S.TextSize = 14
				Title_S.TextXAlignment = Enum.TextXAlignment.Left

				Bar_1.Name = RandomName()
				Bar_1.Parent = Slider
				Bar_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Bar_1.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				Bar_1.BorderSizePixel = 0
				Bar_1.Position = UDim2.new(0.5, 0, 0.65, 0)
				Bar_1.Size = UDim2.new(0, 253, 0, 18)
				Bar_1.ClipsDescendants = true

				UICorner_2.Parent = Bar_1
				UICorner_2.CornerRadius = UDim.new(1, 0)

				BarValue_1.Name = RandomName()
				BarValue_1.Parent = Bar_1
				BarValue_1.AnchorPoint = Vector2.new(0, 0.5)
				BarValue_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				BarValue_1.BorderSizePixel = 0
				BarValue_1.Position = UDim2.new(0, 0, 0.5, 0)
				BarValue_1.Size = UDim2.new(0, 0, 1, 0)
				ApplyThemeGradient(BarValue_1)

				UICorner_3.Parent = BarValue_1
				UICorner_3.CornerRadius = UDim.new(1, 0)

				ValueBox_1.Name = RandomName()
				ValueBox_1.Parent = Slider
				ValueBox_1.Active = true
				ValueBox_1.AnchorPoint = Vector2.new(1, 0.5)
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.Position = UDim2.new(0.95, 0, 0.25, 0)
				ValueBox_1.Size = UDim2.new(0, 32, 0, 16)
				ValueBox_1.FontFace = FontBold
				ValueBox_1.PlaceholderText = tostring(Value)
				ValueBox_1.Text = tostring(Value)
				ValueBox_1.TextColor3 = Color3.fromRGB(255, 255, 255)
				ValueBox_1.TextSize = 10
				ValueBox_1.TextTransparency = 0.25

				UICorner_4.Parent = ValueBox_1
				UICorner_4.CornerRadius = UDim.new(1, 0)

				local function roundToDecimal(val, decimals)
					local factor = 10 ^ decimals
					return math.floor(val * factor + 0.5) / factor
				end

				local function updateSlider(val, noSave)
					val = tonumber(val) or Min
					val = math.clamp(val, Min, Max)
					val = roundToDecimal(val, Rounding)
					Value = val
					if not noSave then SaveFlag(Flag, Value) else Flags[Flag] = Value end

					local ratio = (Max - Min) > 0 and ((val - Min) / (Max - Min)) or 0
					tw({
						v = BarValue_1,
						t = 0.1,
						s = "Quart",
						d = "Out",
						g = {Size = UDim2.new(ratio, 0, 1, 0)}
					}):Play()

					ValueBox_1.Text = tostring(val)
					ValueBox_1.Size = UDim2.new(0, math.max(28, ValueBox_1.TextBounds.X + 16), 0, 16)

					task.spawn(Callback, val)
				end

				updateSlider(Value, true)
				FlagElements[Flag] = { Set = updateSlider }

				TrackConn(ValueBox_1.FocusLost:Connect(function()
					local val = tonumber(ValueBox_1.Text) or Min
					updateSlider(val)
				end))

				local function move(input)
					local relativeX = math.clamp((input.Position.X - Bar_1.AbsolutePosition.X) / Bar_1.AbsoluteSize.X, 0, 1)
					local val = relativeX * (Max - Min) + Min
					updateSlider(val)
				end

				local dragging = false
				TrackConn(Slide.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						move(input)
					end
				end))

				TrackConn(Slide.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end))

				TrackConn(UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end))

				local NewValue = {}
				function NewValue:SetValue(a) updateSlider(a) end
				function NewValue:Value(a) updateSlider(a) end
				function NewValue:Set(a) updateSlider(a) end
				function NewValue:SetVisible(a) Slider.Visible = a end
				function NewValue:Visible(a) Slider.Visible = a end
				function NewValue:SetTitle(b) Title_S.Text = tostring(b) end
				function NewValue:Title(b) Title_S.Text = tostring(b) end
				return NewValue
			end

			--// DROPDOWN
			function ClassObj:Dropdown(info)
				info = info or {}
				local DTitle = info.Title or "Dropdown"
				local List = info.List or {}
				local Flag = info.Flag or DTitle
				local Value = Flags[Flag] ~= nil and Flags[Flag] or info.Value
				local Multi = info.Multi or false
				local Callback = info.Callback or function() end

				local Dropdownz = Instance.new("Frame")
				local UICorner_D = Instance.new("UICorner")
				local ImageLabel_D = Instance.new("ImageLabel")
				local Title_D = Instance.new("TextLabel")
				local Desc_D = Instance.new("TextLabel")
				local icon_D = Instance.new("ImageLabel")
				local ClickDropdown = click(Dropdownz, 2)

				Dropdownz.Name = RandomName()
				Dropdownz.Parent = Section_1
				Dropdownz.AnchorPoint = Vector2.new(0.5, 0.5)
				Dropdownz.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Dropdownz.BackgroundTransparency = 0.5
				Dropdownz.BorderSizePixel = 0
				Dropdownz.Size = UDim2.new(0.97, 0, 0, 45)
				Dropdownz.ClipsDescendants = true
				AddHoverEffect(Dropdownz, 0.5)

				UICorner_D.Parent = Dropdownz
				UICorner_D.CornerRadius = UDim.new(0, 6)

				ImageLabel_D.Name = RandomName()
				ImageLabel_D.Parent = Dropdownz
				ImageLabel_D.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_D.BackgroundTransparency = 1
				ImageLabel_D.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_D.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_D.Image = "rbxassetid://72380279434385"
				ImageLabel_D.ImageTransparency = 0.9
				ImageLabel_D.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_D)

				Title_D.Name = RandomName()
				Title_D.Parent = Dropdownz
				Title_D.BackgroundTransparency = 1
				Title_D.Position = UDim2.new(0.036, 0, 0.085, 0)
				Title_D.Size = UDim2.new(0.82, 0, 0, 20)
				Title_D.FontFace = FontBold
				Title_D.RichText = true
				Title_D.Text = DTitle
				Title_D.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_D.TextSize = 14
				Title_D.TextXAlignment = Enum.TextXAlignment.Left

				Desc_D.Name = RandomName()
				Desc_D.Parent = Dropdownz
				Desc_D.BackgroundTransparency = 1
				Desc_D.Position = UDim2.new(0.036, 0, 0.46, 0)
				Desc_D.Size = UDim2.new(0.82, 0, 0, 18)
				Desc_D.FontFace = FontBold
				Desc_D.Text = type(Value) == "table" and table.concat(Value, ", ") or tostring(Value or "None")
				Desc_D.TextColor3 = Color3.fromRGB(255, 255, 255)
				Desc_D.TextSize = 12
				Desc_D.TextTruncate = Enum.TextTruncate.AtEnd
				Desc_D.TextXAlignment = Enum.TextXAlignment.Left
				ApplyThemeGradient(Desc_D, 90)

				icon_D.Name = RandomName()
				icon_D.Parent = Dropdownz
				icon_D.AnchorPoint = Vector2.new(0.5, 0.5)
				icon_D.BackgroundTransparency = 1
				icon_D.Position = UDim2.new(0.91, 0, 0.5, 0)
				icon_D.Size = UDim2.new(0, 24, 0, 24)
				icon_D.Image = GetIcon("dropdown")
				icon_D.ScaleType = Enum.ScaleType.Fit
				ApplyThemeGradient(icon_D)

				local Dropdown = Instance.new("Frame")
				local UICorner_Panel = Instance.new("UICorner")
				local PanelStroke = Instance.new("UIStroke")
				local Effect_P = Instance.new("ImageLabel")
				local Head_1 = Instance.new("Frame")
				local Title_P = Instance.new("TextLabel")
				local CloseDrawerBtn = Instance.new("TextButton")
				local Line_P = Instance.new("Frame")
				local Body_1 = Instance.new("Frame")
				local Search_1 = Instance.new("TextBox")
				local UICorner_S = Instance.new("UICorner")
				local UIStroke_S = Instance.new("UIStroke")
				local UIListLayout_B = Instance.new("UIListLayout")
				local ScrollingFrame_D = Instance.new("ScrollingFrame")
				local UIListLayout_List = Instance.new("UIListLayout")

				Dropdown.Name = RandomName()
				Dropdown.Parent = Background_1
				Dropdown.Active = true
				Dropdown.AnchorPoint = Vector2.new(1, 0.5)
				Dropdown.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
				Dropdown.BackgroundTransparency = 0.04
				Dropdown.BorderSizePixel = 0
				Dropdown.Position = UDim2.new(1, 0, 0.5, 0)
				Dropdown.Size = UDim2.new(0, 0, 1, 0)
				Dropdown.ClipsDescendants = true
				Dropdown.Visible = false
				Dropdown.ZIndex = 30

				UICorner_Panel.Parent = Dropdown
				UICorner_Panel.CornerRadius = UDim.new(0, 16)

				PanelStroke.Parent = Dropdown
				PanelStroke.Color = Color3.fromRGB(255, 255, 255)
				PanelStroke.Thickness = 1.2
				PanelStroke.Transparency = 0.5
				PanelStroke.Enabled = false
				ApplyThemeGradient(PanelStroke, 90)

				Effect_P.Name = RandomName()
				Effect_P.Parent = Dropdown
				Effect_P.AnchorPoint = Vector2.new(0.5, 0.5)
				Effect_P.BackgroundTransparency = 1
				Effect_P.Position = UDim2.new(0.5, 0, 0.5, 0)
				Effect_P.Size = UDim2.new(1, 0, 1, 0)
				Effect_P.Image = "rbxassetid://132687652275989"
				Effect_P.ImageColor3 = Color3.fromRGB(0, 255, 127)
				Effect_P.ImageTransparency = 0.65
				Effect_P.ScaleType = Enum.ScaleType.Crop
				Effect_P.ZIndex = 30

				Head_1.Name = RandomName()
				Head_1.Parent = Dropdown
				Head_1.BackgroundTransparency = 1
				Head_1.Size = UDim2.new(1, 0, 0, 54)
				Head_1.ZIndex = 31

				Title_P.Name = RandomName()
				Title_P.Parent = Head_1
				Title_P.BackgroundTransparency = 1
				Title_P.Position = UDim2.new(0, 16, 0, 10)
				Title_P.Size = UDim2.new(1, -55, 0, 24)
				Title_P.FontFace = FontBold
				Title_P.Text = DTitle
				Title_P.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_P.TextSize = 17
				Title_P.TextTruncate = Enum.TextTruncate.AtEnd
				Title_P.TextXAlignment = Enum.TextXAlignment.Left
				Title_P.ZIndex = 32

				CloseDrawerBtn.Name = RandomName()
				CloseDrawerBtn.Parent = Head_1
				CloseDrawerBtn.AnchorPoint = Vector2.new(1, 0)
				CloseDrawerBtn.Position = UDim2.new(1, -12, 0, 10)
				CloseDrawerBtn.Size = UDim2.new(0, 24, 0, 24)
				CloseDrawerBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 90)
				CloseDrawerBtn.BackgroundTransparency = 0.2
				CloseDrawerBtn.FontFace = FontBold
				CloseDrawerBtn.Text = "X"
				CloseDrawerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				CloseDrawerBtn.TextSize = 12
				CloseDrawerBtn.AutoButtonColor = false
				CloseDrawerBtn.ZIndex = 33
				local CloseCorner = Instance.new("UICorner")
				CloseCorner.CornerRadius = UDim.new(0, 6)
				CloseCorner.Parent = CloseDrawerBtn

				Line_P.Name = RandomName()
				Line_P.Parent = Head_1
				Line_P.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Line_P.BorderSizePixel = 0
				Line_P.Position = UDim2.new(0, 16, 0, 38)
				Line_P.Size = UDim2.new(0, 70, 0, 2)
				Line_P.ZIndex = 32
				ApplyThemeGradient(Line_P)

				Body_1.Name = RandomName()
				Body_1.Parent = Dropdown
				Body_1.BackgroundTransparency = 1
				Body_1.Position = UDim2.new(0, 0, 0, 54)
				Body_1.Size = UDim2.new(1, 0, 1, -62)
				Body_1.ZIndex = 31

				Search_1.Name = RandomName()
				Search_1.Parent = Body_1
				Search_1.Active = true
				Search_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Search_1.BackgroundTransparency = 0.9
				Search_1.BorderSizePixel = 0
				Search_1.Size = UDim2.new(0.88, 0, 0, 28)
				Search_1.FontFace = FontBold
				Search_1.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
				Search_1.PlaceholderText = "Search..."
				Search_1.Text = ""
				Search_1.TextColor3 = Color3.fromRGB(255, 255, 255)
				Search_1.TextSize = 13
				Search_1.ZIndex = 32
				ApplyThemeGradient(Search_1)

				UICorner_S.Parent = Search_1
				UICorner_S.CornerRadius = UDim.new(1, 0)

				UIStroke_S.Parent = Search_1
				UIStroke_S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke_S.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_S.Thickness = 1
				ApplyThemeGradient(UIStroke_S)

				UIListLayout_B.Parent = Body_1
				UIListLayout_B.Padding = UDim.new(0, 8)
				UIListLayout_B.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_B.SortOrder = Enum.SortOrder.LayoutOrder

				ScrollingFrame_D.Name = RandomName()
				ScrollingFrame_D.Parent = Body_1
				ScrollingFrame_D.Active = true
				ScrollingFrame_D.BackgroundTransparency = 1
				ScrollingFrame_D.BorderSizePixel = 0
				ScrollingFrame_D.Size = UDim2.new(0.88, 0, 1, -38)
				ScrollingFrame_D.ClipsDescendants = true
				ScrollingFrame_D.ScrollBarThickness = 2
				ScrollingFrame_D.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
				ScrollingFrame_D.ScrollingDirection = Enum.ScrollingDirection.Y
				ScrollingFrame_D.ZIndex = 32

				UIListLayout_List.Parent = ScrollingFrame_D
				UIListLayout_List.Padding = UDim.new(0, 5)
				UIListLayout_List.SortOrder = Enum.SortOrder.LayoutOrder

				local isOpen = false
				local function CloseDrawer()
					if not isOpen then return end
					isOpen = false
					PanelStroke.Enabled = false
					tw({v = icon_D, t = 0.2, s = "Quart", d = "Out", g = {Rotation = 0}}):Play()
					local closeTw = tw({v = Dropdown, t = 0.25, s = "Quart", d = "Out", g = {Size = UDim2.new(0, 0, 1, 0)}})
					closeTw.Completed:Connect(function()
						if not isOpen then Dropdown.Visible = false end
					end)
					closeTw:Play()
					if ActiveDropdownClose == CloseDrawer then
						ActiveDropdownClose = nil
					end
				end

				local function OpenDrawer()
					if ActiveDropdownClose and ActiveDropdownClose ~= CloseDrawer then
						ActiveDropdownClose()
					end
					isOpen = true
					ActiveDropdownClose = CloseDrawer
					Dropdown.Visible = true
					PanelStroke.Enabled = true
					tw({v = icon_D, t = 0.2, s = "Quart", d = "Out", g = {Rotation = 180}}):Play()
					tw({v = Dropdown, t = 0.3, s = "Back", d = "Out", g = {Size = UDim2.new(0, 225, 1, 0)}}):Play()
				end

				TrackConn(CloseDrawerBtn.MouseButton1Click:Connect(CloseDrawer))

				TrackConn(ClickDropdown.MouseButton1Click:Connect(function()
					if isOpen then
						CloseDrawer()
					else
						OpenDrawer()
					end
					EffectClick(ClickDropdown, Dropdownz, true)
				end))

				local ItemRecords = {}
				TrackConn(Search_1:GetPropertyChangedSignal("Text"):Connect(function()
					local SearchT = string.lower(Search_1.Text)
					for _, rec in ipairs(ItemRecords) do
						if rec.Frame and rec.Frame.Parent then
							local match = string.find(string.lower(rec.Text), SearchT, 1, true) ~= nil
							rec.Frame.Visible = match
						end
					end
				end))

				local itemslist = {}
				local selectedValues = {}

				local function isValueInTable(val, tbl)
					if type(tbl) ~= "table" then return false end
					for _, v in pairs(tbl) do if tostring(v) == tostring(val) then return true end end
					return false
				end

				local function SetDropdownValue(newVal, noSave)
					if Multi then
						table.clear(selectedValues)
						local tbl = type(newVal) == "table" and newVal or {tostring(newVal)}
						for _, r in ipairs(ItemRecords) do
							if isValueInTable(r.Text, tbl) then
								selectedValues[r.Text] = true
								tw({v = r.Title, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = 0}}):Play()
								tw({v = r.Line, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
							else
								tw({v = r.Title, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = 0.5}}):Play()
								tw({v = r.Line, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
							end
						end
						local selectedList = {}
						for k in pairs(selectedValues) do table.insert(selectedList, k) end
						Value = selectedList
						Desc_D.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "None"
						if not noSave then SaveFlag(Flag, selectedList) else Flags[Flag] = selectedList end
						pcall(Callback, selectedList)
					else
						local targetStr = tostring(newVal or "")
						Value = targetStr
						Desc_D.Text = #targetStr > 0 and targetStr or "None"
						for _, r in ipairs(ItemRecords) do
							local isMatch = (r.Text == targetStr)
							tw({v = r.Title, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = isMatch and 0 or 0.5}}):Play()
							tw({v = r.Line, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = isMatch and 0 or 1}}):Play()
						end
						if not noSave then SaveFlag(Flag, targetStr) else Flags[Flag] = targetStr end
						pcall(Callback, targetStr)
					end
				end

				function itemslist:Clear(a)
					for i = #ItemRecords, 1, -1 do
						local rec = ItemRecords[i]
						local shouldRemove = (a == nil)
							or (type(a) == "string" and rec.Text == a)
							or (type(a) == "table" and table.find(a, rec.Text) ~= nil)
						if shouldRemove then
							selectedValues[rec.Text] = nil
							if rec.Frame then rec.Frame:Destroy() end
							table.remove(ItemRecords, i)
						end
					end
					if a == nil then
						Desc_D.Text = "None"
					end
				end

				function itemslist:AddList(text)
					text = tostring(text)
					local Items = Instance.new("Frame")
					local Real_1 = Instance.new("Frame")
					local Title_Item = Instance.new("TextLabel")
					local Line_Item = Instance.new("Frame")
					local UICorner_I = Instance.new("UICorner")
					local ItemCorner = Instance.new("UICorner")
					local ClickList = click(Items, 3)

					Items.Name = RandomName()
					Items.Parent = ScrollingFrame_D
					Items.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Items.BackgroundTransparency = 0.9
					Items.BorderSizePixel = 0
					Items.Size = UDim2.new(1, 0, 0, 32)
					Items.ZIndex = 33
					ApplyThemeGradient(Items)

					ItemCorner.CornerRadius = UDim.new(0, 6)
					ItemCorner.Parent = Items

					Real_1.Name = RandomName()
					Real_1.Parent = Items
					Real_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Real_1.BackgroundTransparency = 1
					Real_1.Position = UDim2.new(0.5, 0, 0.5, 0)
					Real_1.Size = UDim2.new(1, 0, 1, 0)
					Real_1.ZIndex = 34

					Title_Item.Name = RandomName()
					Title_Item.Parent = Real_1
					Title_Item.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_Item.BackgroundTransparency = 1
					Title_Item.Position = UDim2.new(0.54, 0, 0.5, 0)
					Title_Item.Size = UDim2.new(0.88, 0, 1, 0)
					Title_Item.FontFace = FontBold
					Title_Item.Text = text
					Title_Item.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title_Item.TextSize = 13
					Title_Item.TextTruncate = Enum.TextTruncate.AtEnd
					Title_Item.TextXAlignment = Enum.TextXAlignment.Left
					Title_Item.TextTransparency = 0.5
					Title_Item.ZIndex = 35

					Line_Item.Name = RandomName()
					Line_Item.Parent = Real_1
					Line_Item.AnchorPoint = Vector2.new(0, 0.5)
					Line_Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Line_Item.BorderSizePixel = 0
					Line_Item.Position = UDim2.new(0, 0, 0.5, 0)
					Line_Item.Size = UDim2.new(0, 4, 0, 22)
					Line_Item.BackgroundTransparency = 1
					Line_Item.ZIndex = 35
					ApplyThemeGradient(Line_Item, 90)

					UICorner_I.Parent = Line_Item
					UICorner_I.CornerRadius = UDim.new(1, 0)

					table.insert(ItemRecords, {Frame = Items, Title = Title_Item, Line = Line_Item, Text = text})

					TrackConn(ClickList.MouseButton1Click:Connect(function()
						if Multi then
							if selectedValues[text] then
								selectedValues[text] = nil
								tw({v = Title_Item, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = 0.5}}):Play()
								tw({v = Line_Item, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = 1}}):Play()
							else
								selectedValues[text] = true
								tw({v = Title_Item, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = 0}}):Play()
								tw({v = Line_Item, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = 0}}):Play()
							end
							local selectedList = {}
							for k in pairs(selectedValues) do table.insert(selectedList, k) end
							Value = selectedList
							Desc_D.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "None"
							SaveFlag(Flag, selectedList)
							pcall(Callback, selectedList)
						else
							SetDropdownValue(text, false)
							CloseDrawer()
						end
					end))
				end

				function itemslist:Refresh(newList, newDefault)
					itemslist:Clear()
					for _, v in ipairs(newList or {}) do
						itemslist:AddList(v)
					end
					if newDefault ~= nil then
						SetDropdownValue(newDefault, true)
					elseif Value ~= nil then
						SetDropdownValue(Value, true)
					end
				end

				function itemslist:Set(val)
					SetDropdownValue(val, false)
				end

				function itemslist:GetValue()
					return Value
				end

				for _, v in ipairs(List) do
					itemslist:AddList(v)
				end

				task.defer(function()
					if Value ~= nil then
						SetDropdownValue(Value, true)
					end
				end)

				FlagElements[Flag] = { Set = SetDropdownValue }

				TrackConn(UIListLayout_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					ScrollingFrame_D.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_List.AbsoluteContentSize.Y + 8)
				end))

				return itemslist
			end

			--// KEYBIND
			function ClassObj:Keybind(info)
				info = info or {}
				local KTitle = info.Title or "Keybind"
				local Flag = info.Flag or KTitle
				local Key = ParseKeyCode(Flags[Flag] or info.Key or Enum.KeyCode.Q)
				local Value = info.Value or false
				local Callback = info.Callback or function() end

				local Keybind = Instance.new("Frame")
				local UICorner_K = Instance.new("UICorner")
				local ImageLabel_K = Instance.new("ImageLabel")
				local Title_K = Instance.new("TextLabel")
				local Bin_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TextLabel_1 = Instance.new("TextLabel")
				local ClickChange = click(Keybind, 2)

				Keybind.Name = RandomName()
				Keybind.Parent = Section_1
				Keybind.AnchorPoint = Vector2.new(0.5, 0.5)
				Keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Keybind.BackgroundTransparency = 0.5
				Keybind.BorderSizePixel = 0
				Keybind.Size = UDim2.new(0.97, 0, 0, 45)
				Keybind.ClipsDescendants = true
				AddHoverEffect(Keybind, 0.5)

				UICorner_K.Parent = Keybind
				UICorner_K.CornerRadius = UDim.new(0, 6)

				ImageLabel_K.Name = RandomName()
				ImageLabel_K.Parent = Keybind
				ImageLabel_K.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_K.BackgroundTransparency = 1
				ImageLabel_K.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel_K.Size = UDim2.new(1, 50, 1, 0)
				ImageLabel_K.Image = "rbxassetid://72380279434385"
				ImageLabel_K.ImageTransparency = 0.9
				ImageLabel_K.ScaleType = Enum.ScaleType.Crop
				ApplyThemeGradient(ImageLabel_K)

				Title_K.Name = RandomName()
				Title_K.Parent = Keybind
				Title_K.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_K.BackgroundTransparency = 1
				Title_K.Position = UDim2.new(0.5, 0, 0.5, 0)
				Title_K.Size = UDim2.new(0.928, 0, 0, 20)
				Title_K.FontFace = FontBold
				Title_K.Text = KTitle
				Title_K.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title_K.TextSize = 14
				Title_K.TextTransparency = Value and 0 or 0.5
				Title_K.TextXAlignment = Enum.TextXAlignment.Left

				Bin_1.Name = RandomName()
				Bin_1.Parent = Keybind
				Bin_1.AnchorPoint = Vector2.new(1, 0.5)
				Bin_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Bin_1.BackgroundTransparency = Value and 0 or 0.5
				Bin_1.BorderSizePixel = 0
				Bin_1.Position = UDim2.new(0.97, 0, 0.5, 0)
				Bin_1.Size = UDim2.new(0, 30, 0, 25)
				ApplyThemeGradient(Bin_1, 144)

				UICorner_2.Parent = Bin_1
				UICorner_2.CornerRadius = UDim.new(0, 6)

				TextLabel_1.Name = RandomName()
				TextLabel_1.Parent = Bin_1
				TextLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel_1.BackgroundTransparency = 1
				TextLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextLabel_1.Size = UDim2.new(1, 0, 1, 0)
				TextLabel_1.FontFace = FontBold
				TextLabel_1.Text = Key.Name
				TextLabel_1.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_1.TextSize = 13

				local function adjustBoxBindSize()
					local textSize = TextService:GetTextSize(TextLabel_1.Text, TextLabel_1.TextSize, Enum.Font.GothamBold, Vector2.new(1000, 1000))
					Bin_1.Size = UDim2.new(0, math.max(32, textSize.X + 18), 0, 25)
				end
				adjustBoxBindSize()

				local function SetKeybind(newK, noSave)
					Key = ParseKeyCode(newK)
					TextLabel_1.Text = Key.Name
					adjustBoxBindSize()
					if not noSave then SaveFlag(Flag, Key.Name) else Flags[Flag] = Key.Name end
					task.spawn(Callback, Key, Value, true)
				end

				local binding = false
				local function changeKey()
					if binding then return end
					binding = true
					TextLabel_1.Text = "..."
					adjustBoxBindSize()
					tw({v = Title_K, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = 0}}):Play()

					local inputConnection
					inputConnection = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
							inputConnection:Disconnect()
							task.delay(0.05, function() binding = false end)
							tw({v = Title_K, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = Value and 0 or 0.5}}):Play()
							SetKeybind(input.KeyCode, false)
						end
					end)
				end

				TrackConn(UserInputService.InputEnded:Connect(function(input, gameProcessed)
					if not gameProcessed and not binding and input.KeyCode == Key then
						Value = not Value
						tw({v = Title_K, t = 0.15, s = "Quart", d = "Out", g = {TextTransparency = Value and 0 or 0.5}}):Play()
						tw({v = Bin_1, t = 0.15, s = "Quart", d = "Out", g = {BackgroundTransparency = Value and 0 or 0.5}}):Play()
						task.spawn(Callback, Key, Value, false)
					end
				end))

				TrackConn(ClickChange.MouseButton1Click:Connect(function()
					changeKey()
					EffectClick(ClickChange, Keybind, true)
				end))

				Flags[Flag] = Key.Name
				FlagElements[Flag] = { Set = SetKeybind }

				local Index = {}
				function Index:SetKey(newK) SetKeybind(newK, false) end
				return Index
			end

			return ClassObj
		end

		return SectionBuilder
	end

	--// BUILT-IN COMPLETE CONFIG MANAGER BUILDER
	function WindowObj:BuildConfigTab(targetTab)
		local ConfigLeft = targetTab:Section({
			Title = "Config Manager • 配置管理",
			Side = "l"
		})

		local ConfigRight = targetTab:Section({
			Title = "Autoload & Menu • 自动加载与设置",
			Side = "r"
		})

		local newConfigInput = ""
		local selectedProfile = CurrentConfigName
		local ConfigDrop

		local StatusLabel = ConfigRight:Label({
			Title = 'Active Profile: <font color="rgb(0, 255, 127)">' .. CurrentConfigName .. '</font>',
			Side = "l"
		})

		local AutoloadLabel = ConfigRight:Label({
			Title = 'Autoload: <font color="rgb(0, 170, 255)">' .. WindowObj:GetAutoloadConfig() .. '</font>',
			Side = "l"
		})

		ConfigRight:Line()

		local NameBox = ConfigLeft:Textbox({
			Flag = "_NewConfigNameInput",
			Value = "",
			PlaceHolder = "Enter New Config Name...",
			ClearOnFocus = false,
			Callback = function(txt)
				newConfigInput = txt
			end
		})

		ConfigLeft:Button({
			Title = "Create Config • 创建新配置",
			Desc = "Creates & saves a new config file",
			Icon = "sparkles",
			Callback = function()
				local nameToCreate = (#newConfigInput > 0 and newConfigInput) or NameBox:GetText()
				nameToCreate = nameToCreate:gsub("[^%w_%-]", "")
				if #nameToCreate == 0 then
					WindowObj:Notify({
						Title = "Config Error",
						Desc = "Please type a valid config name first!",
						Icon = "bell",
						Duration = 3
					})
					return
				end
				WindowObj:SaveConfig(nameToCreate)
				selectedProfile = nameToCreate
				ConfigDrop:Refresh(WindowObj:GetConfigs(), nameToCreate)
				StatusLabel:Set('Active Profile: <font color="rgb(0, 255, 127)">' .. nameToCreate .. '</font>')
				WindowObj:Notify({
					Title = "Config Created • 创建成功",
					Desc = "Created and saved profile: " .. nameToCreate,
					Icon = "check",
					Duration = 3
				})
			end
		})

		ConfigLeft:Line()

		ConfigDrop = ConfigLeft:Dropdown({
			Title = "Select Config • 选择配置",
			Flag = "_SelectedConfigDropdown",
			Multi = false,
			List = WindowObj:GetConfigs(),
			Value = CurrentConfigName,
			Callback = function(val)
				selectedProfile = val
			end
		})

		ConfigLeft:Button({
			Title = "Load Config • 加载选中配置",
			Desc = "Applies all settings from selected profile",
			Icon = "zap",
			Callback = function()
				local ok, msg = WindowObj:LoadConfig(selectedProfile)
				if ok then
					StatusLabel:Set('Active Profile: <font color="rgb(0, 255, 127)">' .. selectedProfile .. '</font>')
					WindowObj:Notify({
						Title = "Config Loaded • 加载成功",
						Desc = "Loaded all settings from: " .. selectedProfile,
						Icon = "check",
						Duration = 3
					})
				else
					WindowObj:Notify({
						Title = "Load Failed",
						Desc = tostring(msg),
						Icon = "bell",
						Duration = 3
					})
				end
			end
		})

		ConfigLeft:Button({
			Title = "Overwrite Config • 覆盖保存配置",
			Desc = "Overwrites selected config with current settings",
			Icon = "copy",
			Callback = function()
				local ok, savedName = WindowObj:SaveConfig(selectedProfile)
				if ok then
					StatusLabel:Set('Active Profile: <font color="rgb(0, 255, 127)">' .. savedName .. '</font>')
					WindowObj:Notify({
						Title = "Config Overwritten • 已覆盖保存",
						Desc = "Saved current settings to: " .. savedName,
						Icon = "check",
						Duration = 3
					})
				end
			end
		})

		ConfigLeft:Button({
			Title = "Refresh Config List • 刷新列表",
			Desc = "Scans SyzenHub/Configs folder for files",
			Icon = "search",
			Callback = function()
				local list = WindowObj:GetConfigs()
				ConfigDrop:Refresh(list, selectedProfile)
				WindowObj:Notify({
					Title = "List Refreshed",
					Desc = "Found " .. tostring(#list) .. " config profile(s).",
					Icon = "sparkles",
					Duration = 2.5
				})
			end
		})

		ConfigLeft:Button({
			Title = "Delete Config • 删除配置",
			Desc = "Permanently deletes the selected config file",
			Icon = "trash",
			Callback = function()
				if WindowObj:DeleteConfig(selectedProfile) then
					local list = WindowObj:GetConfigs()
					selectedProfile = list[1] or "Default"
					ConfigDrop:Refresh(list, selectedProfile)
					WindowObj:Notify({
						Title = "Config Deleted • 已删除",
						Desc = "Deleted profile from disk.",
						Icon = "trash",
						Duration = 3
					})
				else
					WindowObj:Notify({
						Title = "Delete Failed",
						Desc = "File does not exist on disk yet.",
						Icon = "bell",
						Duration = 2.5
					})
				end
			end
		})

		ConfigRight:Toggle({
			Title = "Auto-Save Config • 自动保存更改",
			Desc = "Automatically saves changes to active profile",
			Icon = "sparkles",
			Flag = "_AutoSave",
			Value = AutoSaveEnabled,
			Callback = function(state)
				AutoSaveEnabled = state
				if state then
					WindowObj:SaveConfig(CurrentConfigName)
				end
			end
		})

		ConfigRight:Button({
			Title = "Set as Autoload • 设为自动加载",
			Desc = "Automatically loads selected config on execution",
			Icon = "lock",
			Callback = function()
				WindowObj:SaveConfig(selectedProfile)
				if WindowObj:SetAutoloadConfig(selectedProfile) then
					AutoloadLabel:Set('Autoload: <font color="rgb(0, 170, 255)">' .. selectedProfile .. '</font>')
					WindowObj:Notify({
						Title = "Autoload Set • 自动加载已设置",
						Desc = selectedProfile .. " will now auto-load on start!",
						Icon = "check",
						Duration = 3
					})
				end
			end
		})

		ConfigRight:Button({
			Title = "Reset Autoload • 取消自动加载",
			Desc = "Clears the startup autoload profile",
			Icon = "unlock",
			Callback = function()
				WindowObj:ClearAutoloadConfig()
				AutoloadLabel:Set('Autoload: <font color="rgb(0, 170, 255)">None</font>')
				WindowObj:Notify({
					Title = "Autoload Cleared",
					Desc = "Cleared startup autoload profile.",
					Icon = "unlock",
					Duration = 2.5
				})
			end
		})

		ConfigRight:Line()

		ConfigRight:Keybind({
			Title = "Menu Keybind • 菜单快捷键",
			Flag = "_MenuToggleKey",
			Key = WindowObj:GetToggleKey(),
			Value = true,
			Callback = function(newKey, _, wasRebound)
				WindowObj:SetToggleKey(newKey)
				if wasRebound then
					WindowObj:Notify({
						Title = "Keybind Updated",
						Desc = "Menu toggle key set to: " .. newKey.Name,
						Icon = "settings",
						Duration = 3
					})
				end
			end
		})

		ConfigRight:Toggle({
			Title = "Show Floating Logo Button on PC",
			Desc = "Force-shows the SYZEN logo button on PC",
			Icon = "eye",
			Flag = "_ShowFloatingButton",
			Value = forceShowOnPC,
			Callback = function(v)
				WindowObj:SetMobileButtonVisible(v)
			end
		})

		ConfigRight:Discord("https://discord.gg/syzenhub")
	end

	return WindowObj
end

return Env
