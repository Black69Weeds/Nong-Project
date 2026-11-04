--!nocheck
--// SyzenHub v3.8 Complete Example (Full ESP + Fixed Dropdown + Full Config Manager)
local Env = loadstring(game:HttpGet("https://raw.githubusercontent.com/Black69Weeds/Nong-Project/refs/heads/main/src.lua", true))()

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer

--// 1. BANNER TABLE
local Banner = {
	['Genral']   = 129151530039254,
	['Auto']     = 129302321798602,
	['Setting']  = 103463784774845,
	['Misc']     = 103493630998019,
	['Items']    = 121735458882028,
	['Shop']     = 82134370671226,
	['Teleport'] = 133351841364966,
	['Visual']   = 117787399637458,
	['Combat']   = 98110438690781,
	['Update']   = 137729932889241,
}

--// 2. SMOOTH ESP ENGINE
local ESPSettings = {
	Enabled = false,
	Chams = true,
	Names = true,
	Distance = true,
	HealthBar = true,
	TeamCheck = false,
	MaxDistance = 1500,
	FillTrans = 0.65,
	OutlineTrans = 0.1,
	AccentColor = Color3.fromRGB(0, 255, 127)
}

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = tostring(math.random(100000, 999999))
ESPContainer.Parent = (gethui and gethui()) or CoreGui

local ESPCache = {}

local function RemoveESP(plr)
	if ESPCache[plr] then
		for _, inst in pairs(ESPCache[plr]) do
			pcall(function() inst:Destroy() end)
		end
		ESPCache[plr] = nil
	end
end

local function CreateESP(plr)
	if plr == LocalPlayer or ESPCache[plr] then return end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = tostring(math.random(10000, 99999))
	Highlight.FillColor = ESPSettings.AccentColor
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	Highlight.FillTransparency = ESPSettings.FillTrans
	Highlight.OutlineTransparency = ESPSettings.OutlineTrans
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Enabled = false
	Highlight.Parent = ESPContainer

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = tostring(math.random(10000, 99999))
	Billboard.Size = UDim2.new(0, 140, 0, 42)
	Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Enabled = false
	Billboard.Parent = ESPContainer

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Parent = Billboard
	NameLabel.BackgroundTransparency = 1
	NameLabel.Size = UDim2.new(1, 0, 0, 16)
	NameLabel.FontFace = Font.fromEnum(Enum.Font.BuilderSansBold)
	NameLabel.Text = plr.DisplayName
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextStrokeTransparency = 0.35
	NameLabel.TextSize = 12

	local DistLabel = Instance.new("TextLabel")
	DistLabel.Parent = Billboard
	DistLabel.BackgroundTransparency = 1
	DistLabel.Position = UDim2.new(0, 0, 0, 15)
	DistLabel.Size = UDim2.new(1, 0, 0, 12)
	DistLabel.FontFace = Font.fromEnum(Enum.Font.BuilderSansMedium)
	DistLabel.Text = "[0m]"
	DistLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
	DistLabel.TextStrokeTransparency = 0.4
	DistLabel.TextSize = 10

	local HealthBg = Instance.new("Frame")
	HealthBg.Parent = Billboard
	HealthBg.AnchorPoint = Vector2.new(0.5, 0)
	HealthBg.Position = UDim2.new(0.5, 0, 0, 30)
	HealthBg.Size = UDim2.new(0, 76, 0, 5)
	HealthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	HealthBg.BorderSizePixel = 0

	local BgCorner = Instance.new("UICorner")
	BgCorner.CornerRadius = UDim.new(1, 0)
	BgCorner.Parent = HealthBg

	local HealthFill = Instance.new("Frame")
	HealthFill.Parent = HealthBg
	HealthFill.Size = UDim2.new(1, 0, 1, 0)
	HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HealthFill.BorderSizePixel = 0

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1, 0)
	FillCorner.Parent = HealthFill

	local FillGrad = Instance.new("UIGradient")
	FillGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
	}
	FillGrad.Parent = HealthFill

	ESPCache[plr] = {
		Highlight = Highlight,
		Billboard = Billboard,
		NameLabel = NameLabel,
		DistLabel = DistLabel,
		HealthBg = HealthBg,
		HealthFill = HealthFill
	}
end

for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for plr, data in pairs(ESPCache) do
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
		local head = char and char:FindFirstChild("Head")

		if ESPSettings.Enabled and char and hum and root and hum.Health > 0 then
			local isTeammate = ESPSettings.TeamCheck and (plr.Team ~= nil and plr.Team == LocalPlayer.Team)
			local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0

			if not isTeammate and dist <= ESPSettings.MaxDistance then
				data.Highlight.Adornee = char
				data.Highlight.FillTransparency = ESPSettings.FillTrans
				data.Highlight.OutlineTransparency = ESPSettings.OutlineTrans
				data.Highlight.Enabled = ESPSettings.Chams

				if ESPSettings.Names or ESPSettings.Distance or ESPSettings.HealthBar then
					data.Billboard.Adornee = head or root
					data.Billboard.Enabled = true
					data.NameLabel.Visible = ESPSettings.Names
					data.NameLabel.Text = plr.DisplayName
					data.DistLabel.Visible = ESPSettings.Distance
					data.DistLabel.Text = string.format("[%d studs]", dist)
					data.HealthBg.Visible = ESPSettings.HealthBar
					local hpPercent = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
					data.HealthFill.Size = UDim2.new(hpPercent, 0, 1, 0)
				else
					data.Billboard.Enabled = false
				end
			else
				data.Highlight.Enabled = false
				data.Billboard.Enabled = false
			end
		else
			data.Highlight.Enabled = false
			data.Billboard.Enabled = false
		end
	end
end)

--// 3. INITIALIZE SYZENHUB WINDOW
local Window = Env:Window({
	Title = "SyzenHub • 赛森中心",
	Desc = "Stealth Build v3.8 | 欢迎使用 SyzenHub",
	OpenLogo = 139585880965481,
	Bind = Enum.KeyCode.F2,
	ConfigFolder = "SyzenHub",
	Config = "Default"
})

Window:Notify({
	Title = "SyzenHub v3.8 Loaded",
	Desc = "Autoload Profile: " .. Window:GetAutoloadConfig(),
	Icon = "sparkles",
	Duration = 4
})

--// 4. CREATE TABS
local GeneralTab = Window:Add({
	Title = "General • 通用",
	Desc = "All UI Elements & Gameplay Controls",
	Banner = Banner.Genral
})

local VisualTab = Window:Add({
	Title = "Visuals • 透视",
	Desc = "Player ESP, Chams & World Visuals",
	Banner = Banner.Visual
})

local ConfigTab = Window:Add({
	Title = "Configs • 配置",
	Desc = "Save, Load, Overwrite & Autoload Profiles",
	Banner = Banner.Setting
})

--// TAB 1: GENERAL
local LeftSec = GeneralTab:Section({
	Title = "Main Controls",
	Side = "l"
})

local RightSec = GeneralTab:Section({
	Title = "Dropdowns & Inputs",
	Side = "r"
})

LeftSec:Button({
	Title = "Test Notification • 测试通知",
	Desc = "Spawns an animated toast alert",
	Icon = "bell",
	Callback = function()
		Window:Notify({
			Title = "SyzenHub Notification",
			Desc = "Everything is running smoothly!",
			Icon = "zap",
			Duration = 3
		})
	end
})

LeftSec:Toggle({
	Title = "Auto Action • 自动功能",
	Desc = "Automatically saves state to config",
	Icon = "shield",
	Flag = "Auto_Action",
	Value = false,
	Callback = function(v)
		print("Auto Action:", v)
	end
})

LeftSec:Slider({
	Title = "WalkSpeed • 移动速度",
	Flag = "Player_WalkSpeed",
	Min = 16,
	Max = 150,
	Value = 16,
	Rounding = 0,
	Callback = function(v)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
		end
	end
})

RightSec:Dropdown({
	Title = "Target Mode (Single)",
	Flag = "Target_Mode",
	Multi = false,
	List = {"Closest to Player", "Closest to Mouse", "Lowest HP"},
	Value = "Closest to Player",
	Callback = function(v)
		print("Target Mode:", v)
	end
})

RightSec:Dropdown({
	Title = "Allowed Weapons (Multi)",
	Flag = "Weapon_Filter",
	Multi = true,
	List = {"Katana", "Scythe", "Bow", "Greatsword"},
	Value = {"Katana", "Scythe"},
	Callback = function(v)
		print("Weapons:", table.concat(v, ", "))
	end
})

RightSec:Textbox({
	Flag = "Custom_Tag",
	Value = "SyzenUser",
	PlaceHolder = "Enter Custom Tag...",
	ClearOnFocus = false,
	Callback = function(v)
		print("Custom Tag:", v)
	end
})

--// TAB 2: VISUALS (ESP)
local ESPLeft = VisualTab:Section({
	Title = "ESP Toggles • 透视开关",
	Side = "l"
})

local ESPRight = VisualTab:Section({
	Title = "ESP Settings • 透视设置",
	Side = "r"
})

ESPLeft:Toggle({
	Title = "Enable Master ESP • 开启透视",
	Desc = "Toggles all player ESP visuals",
	Icon = "eye",
	Flag = "ESP_Enabled",
	Value = false,
	Callback = function(v)
		ESPSettings.Enabled = v
	end
})

ESPLeft:Toggle({
	Title = "Player Chams (Highlight)",
	Desc = "Glowing silhouette through walls",
	Icon = "sparkles",
	Flag = "ESP_Chams",
	Value = true,
	Callback = function(v)
		ESPSettings.Chams = v
	end
})

ESPLeft:Toggle({
	Title = "Show Names & Distance",
	Desc = "Overhead name and stud distance",
	Icon = "user",
	Flag = "ESP_Names",
	Value = true,
	Callback = function(v)
		ESPSettings.Names = v
		ESPSettings.Distance = v
	end
})

ESPRight:Toggle({
	Title = "Gradient Health Bar",
	Desc = "Animated health bar under player name",
	Icon = "heart",
	Flag = "ESP_Health",
	Value = true,
	Callback = function(v)
		ESPSettings.HealthBar = v
	end
})

ESPRight:Toggle({
	Title = "Team Check",
	Desc = "Hides ESP on teammates",
	Icon = "shield",
	Flag = "ESP_TeamCheck",
	Value = false,
	Callback = function(v)
		ESPSettings.TeamCheck = v
	end
})

ESPRight:Slider({
	Title = "Max Render Distance",
	Flag = "ESP_MaxDist",
	Min = 100,
	Max = 5000,
	Value = 1500,
	Rounding = 0,
	Callback = function(v)
		ESPSettings.MaxDistance = v
	end
})

--// TAB 3: COMPLETE CONFIG MANAGER (1-Line Built-in Builder!)
Window:BuildConfigTab(ConfigTab)
