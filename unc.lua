--[[

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author: @babyfayy333 on discord & github
Discord: https://discord.gg/4Cxn5et44e
Problems: Autorob is not complete but it will work.
Notes: Fuck you tempy, banning me after i did everything.
Usage: You may use this for knowlage, you may not skid, resell this code.

--]]

-------------------->> Farmhub Script Macros <<--------------------

if not LPH_OBFUSCATED then
	FH_DEBUG = true
	FH_DEVELOPER = true
end

-------------------->> Load Game <<--------------------

if not game:IsLoaded() then 
	if FH_DEBUG then
		print("[FarmHub (DEBUG)]: Waiting for game to load..")
	end

	game.Loaded:Wait() 
	wait(3) 
end

-------------------->> Execution Check <<--------------------

local TimeStarted = tick()
if getgenv().Farmhub then
	--return warn("// Already Executed!")
else
	if FH_DEBUG then
		print("[FarmHub (DEBUG)]: Marked Farmhub as injected.")
	end
	getgenv().Farmhub = true
end

if game.PlaceId ~= 606849621 then
	if FH_DEBUG then
		print("[FarmHub (DEBUG)]: Incorrect PlaceID, returning.")
	end
	return
end

-------------------->> Directory Functions <<--------------------

local function GetDirectory()
	local Directory = "FarmHub"
	if not isfolder(Directory) then
		makefolder(Directory)
	end
	return Directory
end

local function SaveFile(name, data)
	local success, error = pcall(function()
		writefile(GetDirectory() .. "\\" .. name, data)
	end)
	return success
end

local function LoadFile(name)
	local success, data = pcall(function()
		return readfile(GetDirectory() .. "\\" .. name)
	end)
	return success and data or nil
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Setup directory system & functions.")
end

-------------------->> Statuueses <<--------------------
--o i hate this

function SetStatus(store, stat)
	print("[" .. store .. "]: " .. stat)
end

function SetStats(time, money)
	print(time, money)
end

-------------------->> Client Services <<--------------------

local Services = setmetatable({}, {
	__index = function(self, service)
		return game:GetService(service)
	end
})

local Teams                     = Services.Teams
local Players                   = Services.Players
local CoreGui                   = Services.CoreGui
local Lighting                  = Services.Lighting
local Workspace                 = Services.Workspace
local StarterGui                = Services.StarterGui
local RunService                = Services.RunService
local GuiService                = Services.GuiService
local TextService               = Services.TextService
local HttpService               = Services.HttpService
local VirtualUser               = Services.VirtualUser
local TweenService              = Services.TweenService
local TeleportService           = Services.TeleportService
local TextChatService           = Services.TextChatService
local UserInputService          = Services.UserInputService
local CollectionService         = Services.CollectionService
local ReplicatedStorage         = Services.ReplicatedStorage
local PathfindingService        = Services.PathfindingService
local MarketplaceService        = Services.MarketplaceService

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Got local game services.")
end

-------------------->> Settings Importation <<--------------------

local Settings = {
	Enabled                     = false,
	KillAura                    = false,
	NotifyOpenings              = true,
	ChatOpenings                = false,
	AntiRagdoll                 = true,
	AntiSkydive                 = true,
	LoopTirePop                 = false,
	AutoLockVehicle             = false,
	AutoKickPlayers             = false,
	CopRange                    = 110,
	Cooldown                    = 0,
	AwaitReward                 = true,
	HyperFocus                  = false,             
	PlayerSpeed                 = 70,
	SkySpeed                    = 95,
	VehicleSpeed                = 350,
	LogHook                     = false,
	WebhookURL                  = "",
	AlertEarnings               = false,
	AlertHyper                  = false,
	ServerHop                   = false,
	RobberyDisabled             = {},
}

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded default settings.")
end

local SettingsFile = LoadFile("AutoRobSettings.json")

if SettingsFile then
	local Success, Data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(SettingsFile)
	end)

	if Success then
		for i, v in pairs(Data) do
			Settings[i] = v
		end
	end
    if FH_DEBUG then
        print("[FarmHub (DEBUG)]: Imported new settings from - workspace/Farmhub/AutoRobSettings.json")
    end
end

-------------------->> Client Player <<--------------------

local Player                    = Players.LocalPlayer
local PlayerGui                 = Player:WaitForChild("PlayerGui")
local Backpack                  = Player:WaitForChild("Folder")
local Leaderstats               = Player:WaitForChild("leaderstats")
local RobberyMoneyGui           = PlayerGui:WaitForChild("RobberyMoneyGui")
local Character                 = nil
local Humanoid                  = nil
local Root                      = nil
local Camera                    = Workspace.CurrentCamera
local BreakFunc                 = function() end
local ExitFunc                  = function() end
local BreakTime                 = 0 
local GetSpawnTime              = nil
local KillAuraPaused            = false
local NoBlockDoors              = {}
local RobberyState              = ReplicatedStorage.RobberyState
local BagLabel                  = RobberyMoneyGui.Container.Bottom.Progress.Amount
local SetIdentity               = setidentity or set_thread_identity or (syn and syn.set_thread_identity) or setcontext or setthreadcontext or set_thread_context

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Setup local player & variables.")
end

-------------------->> Anticheat Functions <<--------------------

local CheatCheck = nil
	for i, v in pairs(getgc(true)) do
		if typeof(v) == "function" then
			CheatCheck = v
			if debug.info(v, "n"):match("CheatCheck") and hookfunction then
				hookfunction(v, function() return "hook" end)
			end
			if getfenv(v).script == Player.PlayerScripts.LocalScript and getconstants then
				local con = getconstants(v)

				if table.find(con, "LastVehicleExit") and table.find(con, "tick") then
					ExitFunc = getupvalue(v, 2)
				end
			end
		elseif type(v) == "table" and type(rawget(v, "getRemainingDebounce")) == "function" then 
			GetSpawnTime = v.getRemainingDebounce
		end
	end
-- 
if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Scanned GC successfully.")
	print("[FarmHub (DEBUG)]: CheatCheck: " .. tostring(CheatCheck))
	print("[FarmHub (DEBUG)]: ExitVehicle: " .. tostring(ExitFunc))
	print("[FarmHub (DEBUG)]: GetSpawnTime: " .. tostring(GetSpawnTime))
end

-------------------->> Client Statisitcs <<--------------------

getgenv().StartingMoney         = getgenv().StartingMoney or Leaderstats:WaitForChild("Money").Value
getgenv().StartingTime          = getgenv().StartingTime or tick()

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: (Pre)Loaded client stats.")
end

-------------------->> Formatting Stuff <<--------------------

local function FormatCash(number)
	local totalnum = tostring(number):split("")

	if #totalnum == 7 then
		return totalnum[1].."."..totalnum[2].."M"
	elseif #totalnum >= 10 then
		return totalnum[1].."."..totalnum[2].."B"
	elseif #totalnum == 4 and #totalnum[2] == 0 then
		return totalnum[1].."k"
	elseif #totalnum == 4  then
		return totalnum[1].."."..totalnum[2].."k"
	elseif #totalnum == 5  then
		return totalnum[1]..totalnum[2].."."..totalnum[3].."k"
	elseif #totalnum == 6  then
		return totalnum[1]..totalnum[2]..totalnum[3].."k"
	else
		return number
	end
end

local function TickToHM(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60
	local hours = math.floor(minutes / 60)
	minutes = minutes % 60

	return hours .. "h/" .. minutes .. "m"
end

function SplitCaps(robbery)
	return (robbery:gsub("%u", " %1"))
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded formatting functions.")
end

-------------------->> Client Modules <<--------------------

local Modules                   = {
	UI                          = require(ReplicatedStorage.Module.UI),
	NPC                         = require(ReplicatedStorage.NPC.NPC),
	Maid                        = require(ReplicatedStorage.Std.Maid),
	Store                       = require(ReplicatedStorage.App.store),
	Raycast                     = require(ReplicatedStorage.Module.RayCast),
	Vehicle                     = require(ReplicatedStorage.Vehicle.VehicleUtils),
	GunItem                     = require(ReplicatedStorage.Game.Item.Gun),
	GuardNPC                    = require(ReplicatedStorage.GuardNPC.GuardNPCShared),
	TagUtils                    = require(ReplicatedStorage.Tag.TagUtils),
	GunShopUI                   = require(ReplicatedStorage.Game.GunShop.GunShopUI),
	CharUtils                   = require(ReplicatedStorage.Game.CharacterUtil),
	NpcShared                   = require(ReplicatedStorage.GuardNPC.GuardNPCShared),
	SafeConsts                  = require(ReplicatedStorage.Safes.SafesConsts),
	CartSystem                  = require(ReplicatedStorage.Game.Cart.CartSystem),
	TombSystem                  = require(ReplicatedStorage.Game.Robbery.TombRobbery.TombRobberySystem),
	ItemSystem                  = require(ReplicatedStorage.Game.ItemSystem.ItemSystem),
	BossConsts                  = require(ReplicatedStorage.MansionRobbery.BossNPCConsts),
	PuzzleFlow                  = require(ReplicatedStorage.Game.Robbery.PuzzleFlow),
	AlexChassis                 = require(ReplicatedStorage.Module.AlexChassis),
	Notification                = require(ReplicatedStorage.Game.Notification),
	MansionUtils                = require(ReplicatedStorage.MansionRobbery.MansionRobberyUtils),
	Confirmation                = require(ReplicatedStorage.Module.Confirmation),
	TeamChooseUI                = require(ReplicatedStorage.TeamSelect.TeamChooseUI),
	BulletEmitter               = require(ReplicatedStorage.Game.ItemSystem.BulletEmitter),
	DartDispenser               = require(ReplicatedStorage.Game.DartDispenser.DartDispenser),
	CharacterAnim               = require(ReplicatedStorage.Game.CharacterAnim),
	RobberyConsts               = require(ReplicatedStorage.Robbery.RobberyConsts),
	ButtonService               = require(ReplicatedStorage.App.BigButtonService),
	MilitaryTurret              = require(ReplicatedStorage.Game.MilitaryTurret.MilitaryTurret),
	DefaultActions              = require(ReplicatedStorage.Game.DefaultActions),
}

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded enviroment modules.")
end

-------------------->> Default Modules <<--------------------

local DefaultModules            = {
	IsPointInTag                = Modules.TagUtils.isPointInTag,
	OldRayIgnore                = Modules.Raycast.RayIgnoreNonCollideWithIgnoreList,
	GetSkydiveTrack             = Modules.CharacterAnim.getSkydiveTrack,
	Notification_new            = Modules.Notification.new,
	CanSeeTarget                = Modules.GuardNPC.canSeeTarget,
	NPC_new                     = Modules.NPC.new,
	NPC_GetTarget               = Modules.NPC.GetTarget,
	NPCS_GoTo                   = Modules.NpcShared.goTo,
	GuardNPC_GoTo               = Modules.GuardNPC.goTo,
}


if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Hookfunc enviroment modules success.")
end

-------------------->> Module Tables <<--------------------

local Specs                     = Modules.UI.CircleAction.Specs
local AttemptPunch              = Modules.DefaultActions.punchButton.onPressed
local Puzzle                    = getupvalue(Modules.PuzzleFlow.Init, 3)
local Event                     = getupvalue(Modules.AlexChassis.SetEvent, 1)
getgenv().RemoteEvent           = getgenv().RemoteEvent or getupvalue(getupvalue(Event.FireServer, 1), 2)

local function Notif(text, time)
	require(ReplicatedStorage.Game.Notification).SetColor(Color3.fromRGB(0, 0, 0))
	require(ReplicatedStorage.Game.Notification).new({ Text = text, Time = time })
end 

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded module tables.")
end

-------------------->> Roblox Functions <<--------------------

local wait                      = task.wait
local spawn                     = task.spawn
local RaycastParams             = RaycastParams.new()
local Tasks                     = {}
    

local function Chat(message)
	TextChatService.TextChannels.RBXGeneral:SendAsync(message, "All")
end

RunService.Stepped:Connect(function(_, dt)
	for _, task in pairs(Tasks) do
		task.time = task.time + dt
		if task.time >= task.second then
			task.time = task.time - task.second
			task.func(function()
				table.remove(Tasks, _)
			end)
		end
	end
end)

local function ForEvery(Second, Task)
	table.insert(Tasks, {
		time = Second,
		second = Second,
		func = Task
	})
end

local function WaitUntil(Func, Timeout, Interval)
    if Func() then
        return
    end

    Timeout = Timeout or 9e9
	Interval = Interval or 0.1

    local WaitStart = tick()

	repeat wait(Interval) until Func() or tick() - WaitStart > Timeout

    return tick() - WaitStart > Timeout
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Rewrote Roblox functions.")
end

-------------------->> Math Functions <<--------------------

local NewVector3                = Vector3.new
local NewCFrame                 = CFrame.new
local Sky                       = NewVector3(0, 500, 0)
local Down                      = NewVector3(0, -1000, 0)

local function DistanceXZ(pos1, pos2)
	return (NewVector3(pos1.X, 0, pos1.Z) - NewVector3(pos2.X, 0, pos2.Z)).Magnitude
end

local function DistanceXYZ(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded math functions.")
end

-------------------->> Robbery Rendering <<--------------------

local Vehicles
local VehicleSpawns
local Bank
local Bank2
local Jewelry
local Museum
local PowerPlant
local Trains
local RobberyTomb
local MansionRobbery
local Bank
-- local Casino
local OilRig

task.spawn(function() Vehicles       = workspace:WaitForChild("Vehicles", 9999) end)
task.spawn(function() VehicleSpawns  = workspace:WaitForChild("VehicleSpawns", 9999) end)
task.spawn(function() Bank           = workspace:WaitForChild("Banks", 9999):WaitForChild("Bank", 9999) end)
task.spawn(function() Bank2          = workspace:WaitForChild("Banks", 9999):WaitForChild("Bank2", 9999) end)
task.spawn(function() Jewelry        = workspace:WaitForChild("Jewelrys", 9999):GetChildren()[1] end)
task.spawn(function() Museum         = workspace:WaitForChild("Museum", 9999) end)
task.spawn(function() PowerPlant     = workspace:WaitForChild("PowerPlant", 9999) end)
task.spawn(function() Trains         = workspace:WaitForChild("Trains", 9999) end)
task.spawn(function() RobberyTomb    = workspace:WaitForChild("RobberyTomb", 9999) end)
-- task.spawn(function() Casino         = workspace:WaitForChild("Casino", 9999) end)
task.spawn(function() MansionRobbery = workspace:WaitForChild("MansionRobbery", 9999) end)
task.spawn(function() OilRig         = workspace:WaitForChild("OilRig", 9999) end)


------- backup 
local RenderLocations           = {
    ["Bank"]                    = Vector3.new(4, 18, 865),
    ["Crater Bank"]             = Vector3.new(-650, 20, -6075),
    ["Jewelry Store"]           = Vector3.new(126, 20, 1368),
    ["Museum"]                  = Vector3.new(1044, 101, 1240),
    ["Power Plant"]             = Vector3.new(96, 21, 2371),
    ["Donut Store"]             = Vector3.new(90, 20, -1511),
    ["Gas Station"]             = Vector3.new(-1526, 19, 699),
    ["Tomb"]                    = Vector3.new(620, 20, -470),
    -- ["Casino"]                  = Vector3.new(-192, 20, -4561),
    ["Mansion"]                 = Vector3.new(2925, 62, -4607),
    ["Oil Rig"]                 = Vector3.new(-2785, 134, -4066)
}

repeat task.wait() 
	pcall(function() 
		Modules.TeamChooseUI.Hide() 
	end) 
until PlayerGui:FindFirstChild("TeamSelectGui") == nil or PlayerGui:FindFirstChild("TeamSelectGui").Enabled == false or Player.TeamColor == BrickColor.new("Bright red")

Camera.CameraType = "Scriptable"

if not getgenv().Loaded then
	for _, position in pairs(RenderLocations) do
		Camera.CFrame = CFrame.new(position)
	    Player:RequestStreamAroundAsync(position, 1000)
	    task.wait()
	end
end

getgenv().Loaded = true
Camera.CameraType = "Custom"
task.wait(0.3)


if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded robbery load awaiters.")
end

-------------------->> Data Tables <<--------------------

local OnOpen = Instance.new("BindableEvent")

local WorkspacePartIgnore = {
	"Rain",
	"RainFall",
	"RainSnow",
	"Plane",
	"Items",
	"DirtRoad",
	"Vehicles",
	"VehicleSpawns",
	"Trains"
}

local CargoTrainBoxCars = {
	"BoxCar",
	"BoxCar2",
	"BoxCar3",
	"BoxCar4",
	"BoxCar5"
}

local PlaneCrates = {
    "Crate1",
    "Crate2",
    "Crate3",
    "Crate4",
    "Crate5",
}

local Robbery = setmetatable({
	Bank = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.BANK,
		Value     = 3,
		Open      = false,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(-8, 18, 865) end,
		GetModel  = function() return Bank end
	},
	CraterBank = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.BANK2,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(0, 0, 0) end,
		GetModel  = function() return Bank end
	},
	Jewelry = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.JEWELRY,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(63, 18, 1316) end,
		GetModel  = function() return Jewelry end
	},
	Museum = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.MUSEUM,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(1066, 101, 1254) end,
		GetModel  = function() return Museum end
	},
	PowerPlant = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.POWER_PLANT,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return NewVector3(68, 21, 2339) end,
		GetModel  = function() return PowerPlant end
	},
	PassengerTrain = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.TRAIN_PASSENGER,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return Root and Root.Position + NewVector3(0, 2, 0) end
	},
	CargoTrain = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.TRAIN_CARGO,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() for i,v in pairs(CargoTrainBoxCars) do if Trains:FindFirstChild(v) then return Trains:FindFirstChild(v).Model.Rob.Gold.Position end end end
	},
	CargoShip = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.CARGO_SHIP,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return Root and Root.Position + NewVector3(0, 1, 0) end,
		Callback  = function() end
	},
	CargoPlane = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.CARGO_PLANE,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return workspace:FindFirstChild("Plane") and workspace.Plane.PrimaryPart.Position end
	},
	Donut = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.STORE_DONUT,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return NewVector3(80, 33, -1596) end
	},
	Gas = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.STORE_GAS,
		Open      = false,
		Value     = 3,
		InstantTpSupported = false,
		Enabled   = true,
		GetPos    = function() return NewVector3(-1603, 18, 662) end
	},
	Tomb = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.TOMB,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(479, 20, -482) end,
		GetModel  = function() return RobberyTomb end
	},
	-- Casino = {
	-- 	ID        = Modules.RobberyConsts.ENUM_ROBBERY.CROWN_JEWEL,
	-- 	Open      = false,
	-- 	Value     = 3,
	-- 	InstantTpSupported = true,
	-- 	Enabled   = true,
	-- 	GetPos    = function() return NewVector3(46, 155, -4740) end,
	-- 	GetModel  = function() return Casino end
	-- },
	Mansion = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.MANSION,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(3032, 57, -4544) end,
		GetModel  = function() return MansionRobbery end
	},
	OilRig = {
		ID        = Modules.RobberyConsts.ENUM_ROBBERY.OIL_RIG,
		Open      = false,
		Value     = 3,
		InstantTpSupported = true,
		Enabled   = true,
		GetPos    = function() return NewVector3(0, 0, 0) end,
		GetModel  = function() return OilRig end
	},
	Airdrop = {
		Enabled = true,
		InstantTpSupported = false,
	}
}, {
	__index = {
		OnOpen = {
			Fire = function(self, ...)
				OnOpen:Fire(...)
			end,
			Connect = function(self, ...)
				OnOpen.Event:Connect(...)
			end
		}
	}
});

local BankPaths = {
	["01UpperManagement"] = {
		[1] = NewCFrame(83, 30, 918),
		[2] = NewCFrame(70, 65, 835),
		[3] = NewCFrame(30, 65, 841),
		[4] = NewCFrame(33, 65, 863),
		[5] = NewCFrame(53, 65, 860),
		[6] = NewCFrame(60, 65, 891),
		[7] = NewCFrame(38, 65, 895),
		[8] = NewCFrame(43, 65, 921),
		[9] = NewCFrame(68, 65, 922),
		[10] = NewCFrame(82, 60, 920)
	}, 
	["02Basement"] = {
		[1] = NewCFrame(-601, 10, -6009),
		[2] = NewCFrame(-583, 0, -5964), 
		[3] = NewCFrame(-606, -4, -5956),
		[4] = NewCFrame(-624, -7, -5991),
		[5] = NewCFrame(-638, -7, -5984),
		[6] = NewCFrame(-633, -7, -5967),
		[7] = NewCFrame(-676, -7, -5948)
	},
	["03Corridor"] = {
		[1] = NewCFrame(59, 20, 922),
		[2] = NewCFrame(59, -8, 922),
		[3] = NewCFrame(58, -8, 919),
		[4] = NewCFrame(109, -8, 910),
		[5] = NewCFrame(129, -8, 907),
		[6] = NewCFrame(179, -8, 902),
		[7] = NewCFrame(191, -8, 900)
	}, 
	["04Remastered"] = {
		[1] = NewCFrame(61, 22, 922),
		[2] = NewCFrame(105, 1, 914),
		[3] = NewCFrame(97, 1, 875),
		[4] = NewCFrame(33, 3, 887),
		[5] = NewCFrame(21, 2, 889)
	}, 
	["05Underwater"] = {
		[1] = NewCFrame(64, 18, 922),
		[2] = NewCFrame(103, 1, 915),
		[3] = NewCFrame(102, 1, 905),
		[4] = NewCFrame(97, -13, 880),
		[5] = NewCFrame(93, -12, 857),
		[6] = NewCFrame(136, -8, 849),
		[7] = NewCFrame(158, -8, 844)
	}, 
	["06TheBlueRoom"] = {
		[1] = NewCFrame(-629, 21, -5997), 
		[2] = NewCFrame(-629, 1, -5997),
		[3] = NewCFrame(-729, 1, -5955) 
	},
	["07TheMint"] = {
		[1] = NewCFrame(60, 19, 923),
		[2] = NewCFrame(101, 1, 915),
		[3] = NewCFrame(89, 1, 847),
		[4] = NewCFrame(77, 0, 847),
		[5] = NewCFrame(70, 0, 815),
		[6] = NewCFrame(52, 0, 816),
		[7] = NewCFrame(48, 0, 798)
	},
	["08Deductions"] = {
		[1] = NewCFrame(-626, 19, -5999), 
		[2] = NewCFrame(-586, 2, -6016), 
		[3] = NewCFrame(-564, 2, -5962), 
		[4] = NewCFrame(-588, 2, -5952), 
		[5] = NewCFrame(-595, 2, -5969),
		[6] = NewCFrame(-636, 2, -5953)
	},
	["09Presidential"] = {
		[1] = NewCFrame(-628, 20, -5997),
		[2] = NewCFrame(-628, -6, -5997), 
		[3] = NewCFrame(-603, -6, -6008), 
		[4] = NewCFrame(-573, -6, -5939), 
		[5] = NewCFrame(-612, -6, -5921), 
		[6] = NewCFrame(-630, -6, -5964) 
	}
}
local JewelryPaths = {
	["1_Classic"] = {
		[1] = NewCFrame(105, 55, 1281), 
		[2] = NewCFrame(105, 70, 1281),
		[3] = NewCFrame(125, 70, 1337), 
		[4] = NewCFrame(163, 63, 1332), 
		[5] = NewCFrame(153, 80, 1273),
		[6] = NewCFrame(124, 80, 1277), 
		[7] = NewCFrame(133, 80, 1336), 
		[8] = NewCFrame(162, 85, 1331), 
		[9] = NewCFrame(152, 102, 1273)
	},
	["2_StorageAndMeeting"] = {
		[1] = NewCFrame(137, 55, 1284), 
		[2] = NewCFrame(140, 55, 1301),
		[3] = NewCFrame(111, 55, 1310), 
		[4] = NewCFrame(118, 55, 1332),
		[5] = NewCFrame(163, 63, 1333), 
		[6] = NewCFrame(153, 80, 1274), 
		[7] = NewCFrame(126, 80, 1294), 
		[8] = NewCFrame(101, 85, 1340), 
		[9] = NewCFrame(162, 85, 1331), 
		[10] = NewCFrame(153, 103, 1273)
	}, 
	["3_ExpandedStore"] = {
		[1] = NewCFrame(96, 60, 1285),
		[2] = NewCFrame(136, 60, 1337), 
		[3] = NewCFrame(162, 63, 1332), 
		[4] = NewCFrame(153, 80, 1274), 
		[5] = NewCFrame(140, 95, 1276), 
		[6] = NewCFrame(132, 95, 1339),
		[7] = NewCFrame(163, 88, 1332), 
		[8] = NewCFrame(153, 103, 1274)
	}, 
	["4_CameraFloors"] = {
		[1] = NewCFrame(106, 55, 1282), 
		[2] = NewCFrame(106, 71, 1282), 
		[3] = NewCFrame(120, 71, 1340), 
		[4] = NewCFrame(163, 62, 1332), 
		[5] = NewCFrame(153, 80, 1273), 
		[6] = NewCFrame(134, 80, 1277), 
		[7] = NewCFrame(136, 80, 1337),
		[8] = NewCFrame(163, 85, 1333), 
		[9] = NewCFrame(153, 103, 1273)
	}, 
	["5_TheCEO"] = {
		[1] = NewCFrame(105, 55, 1281), 
		[2] = NewCFrame(105, 65, 1281), 
		[3] = NewCFrame(126, 65, 1282), 
		[4] = NewCFrame(135, 65, 1338), 
		[5] = NewCFrame(162, 63, 1333), 
		[6] = NewCFrame(153, 78, 1274), 
		[7] = NewCFrame(127, 78, 1292),
		[8] = NewCFrame(100, 78, 1295), 
		[9] = NewCFrame(132, 78, 1338), 
		[10] = NewCFrame(162, 88, 1333), 
		[11] = NewCFrame(153, 103, 1274)
	}, 
	["6_LaserRooms"] = {
		[1] = NewCFrame(117, 55, 1278), 
		[2] = NewCFrame(135, 55, 1303), 
		[3] = NewCFrame(129, 55, 1339), 
		[4] = NewCFrame(163, 62, 1332), 
		[5] = NewCFrame(152, 79, 1274), 
		[6] = NewCFrame(124, 79, 1278), 
		[7] = NewCFrame(134, 79, 1337), 
		[8] = NewCFrame(162, 86, 1332), 
		[9] = NewCFrame(152, 103, 1273)
	}
}

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded & formatted data tables.")
end

-------------------->> Robbery Status <<--------------------

for i,v in pairs(RobberyState:GetChildren()) do
	for i2,v2 in pairs(Robbery) do
		if v.Name == tostring(v2.ID) then
			v2.Value = v.Value
			if i2 == "Museum" or i2 == "Tomb" then
				v2.Open = (v.Value == 2)
			elseif i2 == "Mansion" then
				v2.Open = (v.Value == 1)
			else
				v2.Open = (v.Value ~= 3)
			end

			Robbery.OnOpen:Fire(i2, v2.Open)

			v:GetPropertyChangedSignal("Value"):Connect(function()
				v2.Value = v.Value
				if i2 == "Museum" or i2 == "Tomb" then
					v2.Open = (v.Value == 2)
				elseif i2 == "Mansion" then
					v2.Open = (v.Value == 1)
				else
					v2.Open = (v.Value ~= 3)
				end

				Robbery.OnOpen:Fire(i2, v2.Open)

				if Settings.NotifyOpenings and v.Value == 1 then
					if getgenv()._notify then
						getgenv()._notify("Robbery Alert", "The " .. (SplitCaps(i2) or i2) .. " is now open for robbery!", 8)
					end
				end
				if Settings.ChatOpenings and v.Value == 1 then
					Chat("The " .. (SplitCaps(i2) or i2) .. " is now open for robbery!")
				end
			end)
			break
		end
	end
end

RobberyState.ChildAdded:Connect(function(v)
	for i2,v2 in pairs(Robbery) do
		if v.Name == tostring(v2.ID) then
			v2.Value = v.Value
			if i2 == "Museum" or i2 == "Tomb" then
				v2.Open = (v.Value == 2)
			elseif i2 == "Mansion" then
				v2.Open = (v.Value == 1)
			else
				v2.Open = (v.Value ~= 3)
			end

			v:GetPropertyChangedSignal("Value"):Connect(function()
				v2.Value = v.Value
				if i2 == "Museum" or i2 == "Tomb" then
					v2.Open = (v.Value == 2)
				elseif i2 == "Mansion" then
					v2.Open = (v.Value == 1)
				else
					v2.Open = (v.Value ~= 3)
				end
				
				if Settings.NotifyOpenings and v.Value == 1 then
					if getgenv()._notify then
						getgenv()._notify("Robbery Alert", "The " .. (SplitCaps(i2) or i2) .. " is now open for robbery!", 8)
					end
				end
				if Settings.ChatOpenings and v.Value == 1 then
					Chat("The " .. (SplitCaps(i2) or i2) .. " is now open for robbery!")
				end
			end)
			break
		end
	end
end)

for k,v in pairs(Settings.RobberyDisabled) do
    Robbery[k].Enabled = not v
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Hooked RState to " .. tostring(Robbery))
end

-------------------->> Raycast Functions <<--------------------

RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function Raycast(origin, direction)
	return Workspace:Raycast(origin, direction, RaycastParams)
end

local function Ignore(obj)
	local IgnoreList = RaycastParams.FilterDescendantsInstances
	table.insert(IgnoreList, obj)
	RaycastParams.FilterDescendantsInstances = IgnoreList
end

local function WorkspaceOnChildAdded(child)
	if table.find(WorkspacePartIgnore, child.Name) then
		Ignore(child)
	end
end

local function OnDoorAdded(door)
	Ignore(door)

	if not door:FindFirstChild("Model") then
		return
	end

	for _, part in pairs(door.Model:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	local Touch = door:FindFirstChild("Touch")
	if not Touch or not Touch:IsA("BasePart") then
		return
	end

	for _, part in pairs(door:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
		pcall(function()
			part.Transparency = 1
		end)
	end

	local Front = false
	local Behind = false

	for dir = 0, 50, 10 do
		if Front and Behind then
			break
		end

		local FrontPos  = Touch.Position + (Touch.CFrame.LookVector * dir)
		local BehindPos = Touch.Position + (Touch.CFrame.LookVector * -dir)

		if not Front and not Raycast(Touch.Position, FrontPos - Touch.Position) and not Raycast(FrontPos, Vector3.new(0, 1000, 0)) then
			table.insert(NoBlockDoors, FrontPos)
			Front = true
		end
		if not Behind and not Raycast(Touch.Position, BehindPos - Touch.Position) and not Raycast(BehindPos, Vector3.new(0, 1000, 0)) then
			table.insert(NoBlockDoors, BehindPos)
			Behind = true
		end
	end
end

for _, child in pairs(workspace:GetChildren()) do
	WorkspaceOnChildAdded(child)
end
for _, tree in pairs(CollectionService:GetTagged("Tree")) do
	Ignore(tree)
end
for _, part in pairs(CollectionService:GetTagged("NoClipAllowed")) do
	Ignore(part)
end
for _, door in pairs(CollectionService:GetTagged("Door")) do
	OnDoorAdded(door)
end

Workspace.ChildAdded:Connect(WorkspaceOnChildAdded)
CollectionService:GetInstanceAddedSignal("Tree"):Connect(Ignore)
CollectionService:GetInstanceAddedSignal("NoClipAllowed"):Connect(Ignore)
CollectionService:GetInstanceAddedSignal("Door"):Connect(OnDoorAdded)

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded raycast checks / ignores")
end

-------------------->> Player Functions <<--------------------

local function SetupCharacter(character)
	Character = character
	Humanoid = character:WaitForChild("Humanoid")
	Root = character:WaitForChild("HumanoidRootPart")
	Ignore(Character)
	Humanoid.Died:Connect(function()
		Character, Root, Humanoid = nil, nil, nil
	end)
end

local function IsArrested()
	if PlayerGui.MainGui.CellTime.Visible or Backpack:FindFirstChild("Cuffed") then
		return true
	end

	return false
end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded client character parts")
end

-------------------->> Hooking Functions <<--------------------

Modules.MilitaryTurret._fire  = function() end
Modules.DartDispenser._fire   = function() end

Modules.TagUtils.isPointInTag = newcclosure(function(point, tag)
	if tag == "NoFallDamage" then
		return true
	end
	if tag == "NoRagdoll" and Settings.AntiRagdoll then
		return true
	end
	return DefaultModules.IsPointInTag(point, tag)
end)

Modules.CharacterAnim.getSkydiveTrack = newcclosure(function()
	if Settings.AntiSkydive then
		return task.wait(9e9)
	end 
	return DefaultModules.GetSkydiveTrack()
end)

Modules.Notification.new = function(NotificationData)
	if NotificationData.Text == "You cannot lock your car here." or NotificationData.Text == "Tasers not allowed here." or NotificationData.Text == "Vault must be armed to crack it!" then
		return
	end
	return DefaultModules.Notification_new(NotificationData)
end

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Module hooked validation passed #2")
end

-------------------->> Vehicle Functions <<--------------------

local GetVehiclePacket = Modules.Vehicle.GetLocalVehiclePacket
local GetVehicleModel = Modules.Vehicle.GetLocalVehicleModel
local GetLockable = Modules.Vehicle.canLocalLock
local ToggleLock = Modules.Vehicle.toggleLocalLocked
local GetEjectable = Modules.Vehicle.canLocalEject
local EjectPlayer = Modules.Vehicle.attemptPassengerEject
local VehicleLocked = (function() return GetVehicleModel():GetAttribute("Locked") end)
local EjectPlayer = Modules.Vehicle.attemptPassengerEject
local GetSeats = (function() local SeatedPlayers = {} if GetVehicleModel() then for i,v in next, Modules.Vehicle.getSeats(GetVehicleModel()) do if v.Player ~= Player then table.insert(SeatedPlayers, v) end end return SeatedPlayers else return nil end end)
local FakeSniper = {__ClassName = "Sniper", Local = true, Config = {}, IgnoreList = {}, LastImpact = 0, LastImpactSound = 0, Maid = Modules.Maid.new()}
local OwnedVehicles = {"Camaro", "Jeep"}

local function ClosestVehicle() 
	for i,v in pairs(Specs) do
		if v.Tag.Name == "Seat" and table.find(OwnedVehicles, v.ValidRoot.Name) and (v.Part.Position - Root.Position).Magnitude <= 60 then
			return true
		end
	end
end

local function EnterVehicle(vehicle)
	vehicle = vehicle or nil
	if vehicle then
		for i,v in pairs(Specs) do
			if v.Name == "Hijack" and v.Part and v.Part == vehicle:FindFirstChild("Seat") then
				v:Callback(true)
			end
		end
		for i,v in pairs(Specs) do
			if v.Part and v.Part == vehicle:FindFirstChild("Seat") then
				v:Callback(true)
			end
		end
	else
		for i,v in pairs(Specs) do
			if v.Name == "Hijack" then
				v:Callback(true)
			end
		end
		for i,v in pairs(Specs) do
			if v.Tag.Name == "Seat" and table.find(OwnedVehicles, v.ValidRoot.Name) and (v.Part.Position - Root.Position).Magnitude <= 60 then
				v:Callback(true)
			end
		end
	end
end

local function ExitVehicle()
	Modules.CharUtils.OnJump()
	repeat
		if GetVehiclePacket() then
			GetVehicleModel().PrimaryPart.Velocity = Vector3.new()
			GetVehicleModel().PrimaryPart.RotVelocity = Vector3.new()
		end
		task.wait()
	until GetVehiclePacket() == nil
end

Modules.GunItem.SetupBulletEmitter(FakeSniper)

task.spawn(function()
	while task.wait(0.5) do
		if GetVehicleModel() then
			if Settings.AutoLockVehicle then
				if not VehicleLocked() then
					if GetLockable() then
						ToggleLock()
					end
				end
			end

			if Settings.AutoKickPlayers then
				if GetEjectable() then
					if GetSeats() then
						for i,v in next, GetSeats() do
							if v.Player and v.Player.Name ~= Player.Name then
								EjectPlayer(v.Player.Name)
							end
						end
					end
				end
			end
		end

		if Settings.LoopTirePop then
			for _, car in pairs(Workspace.Vehicles:GetChildren()) do
				pcall(function()
					if car.PrimaryPart and car:FindFirstChild("Seat") and car.Seat.PlayerName.Value ~= "" and car.Seat.PlayerName.Value ~= Player.Name then
						for _ = 1, 2 do
							FakeSniper.LastImpact = 0
							FakeSniper.BulletEmitter.OnHitSurface:Fire(car.Engine, car.Engine.Position, car.Engine.Position)
							task.wait(0.25)
						end
					end
				end)
			end
		end
	end
end)

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Loaded vehicle functions")
end

-------------------->> Firearm Functions <<--------------------

local function GetClosestCop()
	for i, v in pairs(Players:GetPlayers()) do
		if v.Team.Name == "Police" and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			if DistanceXZ(Root.Position, v.Character.HumanoidRootPart.Position) <= 600 then
				return v
			end
		end
	end

	return nil
end

local function GetPistol()
	if Backpack:FindFirstChild("Pistol") then return end
	SetIdentity(2)
	Modules.GunShopUI.open()
	task.wait()
	firesignal(PlayerGui.GunShopGui.Container.Container.Main.Container.Slider["Pistol"].Bottom.Action.MouseButton1Down)
	SetIdentity(8)
	Modules.GunShopUI.close()
end

local function EquipPistol(bool)
	if not Backpack:FindFirstChild("Pistol") then return end
	Backpack["Pistol"]:SetAttribute("InventoryItemLocalEquipped", bool)
	Backpack["Pistol"].InventoryEquipRemote:FireServer(bool)
end

local function ShootPistol()
	local CurrentGun = Modules.ItemSystem.GetLocalEquipped()
	if not CurrentGun then 
		return 
	end
	Modules.GunItem._attemptShoot(CurrentGun)
end

task.spawn(function()
	while task.wait(0.5) do
		if not Settings.KillAura then continue end
		if KillAuraPaused then continue end
		if not Character then continue end
		if not Root then continue end
		if GetVehicleModel() then continue end

		pcall(function()
			local TargetedCop = GetClosestCop()
			if TargetedCop then
				Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = function(...)
					local arg = {DefaultModules.OldRayIgnore(...)}
					if (tostring(getfenv(2).script) == "BulletEmitter" or tostring(getfenv(2).script) == "Taser") and TargetedCop and TargetedCop.Character and TargetedCop.Character:FindFirstChild("HumanoidRootPart") and TargetedCop.Character:FindFirstChild("Humanoid") and (TargetedCop.Character.HumanoidRootPart.Position - Root.Position).Magnitude < 600 and TargetedCop.Character.Humanoid.Health > 0 then
						arg[1] = TargetedCop.Character.HumanoidRootPart
						arg[2] = TargetedCop.Character.HumanoidRootPart.Position
					end
					return unpack(arg)
				end
				if not Backpack:FindFirstChild("Pistol") then
					GetPistol()
				end
				if Backpack:FindFirstChild("Pistol") then
					while Backpack:FindFirstChild("Pistol") and TargetedCop and TargetedCop.Character and TargetedCop.Character:FindFirstChild("HumanoidRootPart") and TargetedCop.Character:FindFirstChild("Humanoid") and (TargetedCop.Character.HumanoidRootPart.Position - Root.Position).Magnitude < 600 and TargetedCop.Character.Humanoid.Health > 0 and not KillAuraPaused and Settings.KillAura and not GetVehicleModel() do
						EquipPistol(true)
						task.wait()
						ShootPistol()
					end
					EquipPistol(false)
					Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = DefaultModules.OldRayIgnore
				end
			else
				Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = DefaultModules.OldRayIgnore
			end
		end)
	end
end)

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Created custom firearm functions.")
end

-------------------->> Teleportation Functions <<--------------------

local LaggedBack = false

local function LagBackCheck(part)
	local ShouldStop = false
	local OldPosition = part.Position
	local Signal = part:GetPropertyChangedSignal("CFrame"):Connect(function()
		local CurrentPosition = part.Position

		if DistanceXZ(CurrentPosition, OldPosition) > 7 then
			LaggedBack = true
			task.delay(0.2, function()
				LaggedBack = false
			end)
		end
	end)

	task.spawn(function()
		while part and ShouldStop == false do
			OldPosition = part.Position
			task.wait()
		end
	end)

	return {
		Stop = function()
			ShouldStop = true
			Signal:Disconnect()
		end
	}
end

local function NoclipStart()
	local Noclipper = nil
	local NoclipLoop = function()
		pcall(function()
			if not Character then 
				Noclipper:Disconnect()
			end
			for i, child in pairs(Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true then
					child.CanCollide = false
				end
			end
		end)
	end

	Noclipper = RunService.Stepped:Connect(NoclipLoop)
	return {
		Stop = function()
			Noclipper:Disconnect()
		end
	}
end

local function SmallTP(cf, speed)
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end

	if speed == nil then
		speed = Settings.PlayerSpeed
	end

	local IsTargetMoving = type(cf) == "function"
	local LagCheck = LagBackCheck(Root)
	local Noclip = NoclipStart()
	local TargetPos = (IsTargetMoving and cf() or cf).Position
	local LagbackCount = 0
	local Success = true

	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	repeat
		TargetPos = (IsTargetMoving and cf() or cf).Position
		Mover.Velocity = CFrame.new(Root.Position, TargetPos).LookVector * speed

		task.wait(0.03) 

		if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
			return error()
		end

		if LaggedBack then
			LagbackCount = LagbackCount + 1
			Mover.Velocity = Vector3.zero
			task.wait(1)

			if LagbackCount > 7 then
				Mover:Destroy()
				Noclip:Stop()
				LagCheck:Stop()

				Humanoid.Health = 0
				return error()
			end
		end
	until (Root.Position - TargetPos).Magnitude <= 5 or not Success

	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end

	Mover.Velocity = Vector3.new(0, 0, 0)
	TargetPos = (IsTargetMoving and cf() or cf).Position
	Root.CFrame = CFrame.new(TargetPos)
	task.wait(0.001)

	Mover:Destroy()
	Noclip:Stop()
	LagCheck:Stop()
	Root.CFrame = CFrame.new(TargetPos)
	Root.Velocity, Root.RotVelocity = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
end

local function ChainTP(cfs, func, speed)
	for _, cframe in pairs(cfs) do
		SmallTP(cframe, speed)
		if func then
			func()
		end
	end
end

local function PathfindTP(vr, speed)
	local Path = PathfindingService:CreatePath({
		AgentRadius = 1.5,
		AgentCanJump = true
	})

	Path:ComputeAsync(Root.Position, vr)
	if not Path.Status == Enum.PathStatus.Success then
		return error()
	end

	local Waypoints = Path:GetWaypoints()
	local Points = {}
	for _, waypoint in pairs(Waypoints) do
		table.insert(Points, CFrame.new(waypoint.Position) * CFrame.new(0, 4.5, 0))
	end

	ChainTP(Points, speed)
end

local function IsBlockingUp()
	if Raycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
		return true
	end

	return false
end

local function FixPosition()
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end

	local tried = {}
	if not IsBlockingUp() then 
		return true 
	end

	repeat 
		local Distance, Nearest = math.huge, nil
		for _, Position in pairs(NoBlockDoors) do
			if not table.find(tried, Position) then
				local Magnitude = DistanceXZ(Root.Position, Position)
				if Magnitude < Distance then
					Distance = Magnitude
					Nearest = Position
				end
			end
		end

		PathfindTP(Nearest)
		task.wait(0.5)
		if IsBlockingUp() then
			table.insert(tried, Nearest)
		end
	until not IsBlockingUp()

	if not IsBlockingUp() then 
		return true 
	else
		return FixPosition()
	end
end

local function BigTP(cf, speed)
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end

	if speed == nil then
		speed = Settings.SkySpeed
	end

	local IsTargetMoving = type(cf) == "function"

	if DistanceXZ(Root.Position, (IsTargetMoving and cf() or cf).Position) < 20 then
		Root.CFrame = CFrame.new((IsTargetMoving and cf() or cf).Position)
		return true
	end

	if Raycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
		FixPosition()
		task.wait(0.5)
	end

	local LagCheck = LagBackCheck(Root)
	local Noclip = NoclipStart()
	local TargetPos = (IsTargetMoving and cf() or cf).Position
	local TargetOffset = Vector3.new(TargetPos.X, 500, TargetPos.Z)
	local LagbackCount = 0
	local Success = true

	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	repeat
		TargetPos = (IsTargetMoving and cf() or cf).Position
		TargetOffset = Vector3.new(TargetPos.X, 500, TargetPos.Z)

		Root.CFrame = CFrame.new(Root.CFrame.X, 500, Root.CFrame.Z)
		Mover.Velocity = (TargetOffset - Root.Position).Unit * speed

		task.wait(0.03) 

		if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
			return error()
		end

		if LaggedBack then
			LagbackCount = LagbackCount + 1
			Mover.Velocity = Vector3.zero
			task.wait(1)

			if Raycast(Root.Position + Vector3.new(0, 5, 0), Vector3.new(0, 1000, 0)) then
				FixPosition()
				task.wait(0.5)
			end

			if LagbackCount > 7 then
				Mover:Destroy()
				Noclip:Stop()
				LagCheck:Stop()
				Humanoid.Health = 0
				return error()
			end
		end
	until DistanceXZ(Root.Position, TargetOffset) < 15

	Mover.Velocity = Vector3.new(0, 0, 0)
	TargetPos = (IsTargetMoving and cf() or cf).Position
	Root.CFrame = CFrame.new(TargetPos)
	task.wait(0.05)

	Mover:Destroy()
	Noclip:Stop()
	LagCheck:Stop()

	task.wait(0.6)
	if (Root.Position - TargetPos).Magnitude > 30 then
		return BigTP(cf, speed)
	end
end

local function GetVehicle()
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end
	if GetVehiclePacket() then
		pcall(function()
			GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = "FarmHub"
		end)
		return true
	end
	local Vehicles = Workspace.Vehicles:GetChildren()
	local OwnedCars = {"Camaro", "Jeep"}

	table.sort(Vehicles, function(a, b)
		if a.PrimaryPart and b.PrimaryPart then
			return (a.PrimaryPart.Position - Root.Position).Magnitude < (b.PrimaryPart.Position - Root.Position).Magnitude
		end
	end)

	if ClosestVehicle() then
		FixPosition()
		EnterVehicle()
		BreakFunc = tick()
		repeat task.wait() until GetVehiclePacket() or tick() - BreakFunc > 1.5
		if GetVehiclePacket() then 
			pcall(function()
				GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = "FarmHub"
			end)
			return true
		end 
	end

	if GetSpawnTime() < 0 and Player.Team.Name == "Criminal" then
		wait(0.01)
		local LowestPoint = Raycast(Root.Position, Vector3.new(0, -1000, 0))
		if LowestPoint then
			local SpawnPoint = CFrame.new(LowestPoint.Position + Vector3.new(0, 7, 0))

			for i = 1, 5 do
				Root.CFrame = SpawnPoint
				wait(0.05)
			end

			Services.ReplicatedStorage.GarageSpawnVehicle:FireServer("Chassis", (math.random(1, 2) == 1 and "Camaro" or "Jeep"))

			local BreakTime = tick()
			repeat
				task.wait(0.25)
			until tick() - BreakTime > 5 or GetVehicleModel()

			if GetVehicleModel() then
				pcall(function()
					GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = "FarmHub"
				end)
				return true
			end
		end
	end

	for i, v in pairs(Vehicles) do
		if table.find(OwnedCars, v.Name) and v.PrimaryPart and v.Seat and not v.Seat.Player.Value and not Raycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then 
			if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
				return error()
			end

			if (Root.Position - v.Seat.Position).Magnitude > 50 then
				if BigTP(v.Seat.CFrame * CFrame.new(0, 4.5, 0)) == true then
					return
				end
			end

			for i = 1, 50 do
				EnterVehicle(v)
				task.wait(0.1)

				if GetVehiclePacket() then
					pcall(function()
						GetVehicleModel().Model.plate.SurfaceGui.Frame.TextLabel.Text = "FarmHub"
					end)
					return true
				end

				if not v.PrimaryPart or not v:FindFirstChild("Seat") or v.Seat.Player.Value then
					break
				end

				if i > 10 then
					if v:GetAttribute("Locked") then
						break
					end
				end
			end
		end
	end

	return GetVehicle()
end

local function VehicleTP(cframe, leave, offset, speed)
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() then
		return error()
	end

	GetVehicle()

	speed = (speed or Settings.VehicleSpeed)
	offset = (offset or 1000)

	local IsTargetMoving = type(cframe) == "function"
	local CarModel = GetVehicleModel().PrimaryPart
	local LagCheck = LagBackCheck(CarModel)
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)
	local LagbackCount = 0
	local Success = true

	local Mover = Instance.new("BodyVelocity", Root)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	repeat

		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		TargetOffset = Vector3.new(TargetPos.X, offset, TargetPos.Z)

		CarModel.CFrame = CFrame.new(CarModel.CFrame.X, offset, CarModel.CFrame.Z)
		Mover.Velocity = (TargetOffset - CarModel.Position).Unit * speed

		task.wait(0.03) 

		if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() or not GetVehicleModel() then
			return error()
		end

		if LaggedBack then
			LagbackCount = LagbackCount + 1
			Mover.Velocity = Vector3.zero
			task.wait(1)

			if LagbackCount == 10 then
				Mover:Destroy()
				if offset == 500 then
					LagCheck:Stop()
				end

				Humanoid.Health = 0
				return error()

			end
		end
	until not Success or DistanceXZ(CarModel.Position, TargetOffset) < 15

	Mover.Velocity = Vector3.new(0, 0.01, 0)
	task.wait(0.01)
	Mover:Destroy()

	TargetPos = (IsTargetMoving and cframe() or cframe).Position
	CarModel.CFrame = CFrame.new(TargetPos)
	task.wait(0.01)
	LagCheck:Stop()
	if leave then 
		wait(0.5)
		ExitVehicle() 
	end
end

local function VehicleDirectTP(cframe, speed)
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested()  then
		return error()
	end

	GetVehicle()

	speed = (speed or 90)

	local IsTargetMoving = type(cframe) == "function"
	local CarModel = GetVehicleModel().PrimaryPart
	local TargetPos = (IsTargetMoving and cframe() or cframe).Position
	local TargetOffset = Vector3.new(TargetPos.X, TargetPos.Y, TargetPos.Z)

	local Mover = Instance.new("BodyVelocity", CarModel)
	Mover.P = 3000
	Mover.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	repeat
		TargetPos = (IsTargetMoving and cframe() or cframe).Position
		TargetOffset = Vector3.new(TargetPos.X, TargetPos.Y, TargetPos.Z)                    
		CarModel.CFrame = CFrame.new(CarModel.CFrame.X, CarModel.CFrame.Y, CarModel.CFrame.Z)
		Mover.Velocity = (TargetOffset - CarModel.Position).Unit * speed

		task.wait(0.03) 

		if not Character or not Root or not Humanoid or Humanoid.Health == 0 or IsArrested() or not GetVehicleModel() then
			return error()
		end
	until DistanceXZ(CarModel.Position, TargetPos) < 15

	Mover.Velocity = Vector3.new(0, 0.01, 0)
	task.wait(0.01)
	Mover:Destroy()

	TargetPos = (IsTargetMoving and cframe() or cframe).Position
	CarModel.CFrame = CFrame.new(TargetPos)
	task.wait(0.01)
end

local function VehicleInstantTP(cf)
	GetVehicle()
    WaitUntil(function()
        return GetVehicleModel()
    end, 5)
	for i,v in pairs(GetVehicleModel():GetDescendants()) do
		pcall(function()
			v.CanCollide = false
		end)
	end
	GetVehicleModel().Name = "FarmhubVehicle"
	while GetVehicleModel() do
		GetVehicleModel():SetPrimaryPartCFrame(cf)
		task.wait()
	end
	for i = 1, 5 do
		Root.CFrame = cf
		Root.Velocity = Vector3.new()
	end
end

-------------------->>  Robbery Functions  <<--------------------

local function FlipTable(tab)
	local Res = {}

	for i, v in next, tab do
		Res[(#tab + 1) - i] = v
	end

	return Res
end

local function getPairs(grid)
	local pairs = {}
	for i = 1, #grid do
		for j = 1, #grid[i] do
			local cell = grid[i][j]
			local neighborCount = 0
			for k = -1, 1 do
				for l = -1, 1 do
					local neighbor = grid[i + k] and grid[i + k][j + l]
					if math.abs(k + l) == 1 and neighbor and neighbor == cell then
						neighborCount = neighborCount + 1
					end
				end
			end
			if neighborCount == 1 then
				if not pairs[cell] then
					pairs[cell] = {}
				end
				table.insert(pairs[cell], {
					Cell = cell,
					i = i,
					j = j
				})
			end
		end
	end
	return pairs
end

local function IsBagFull()
	if not RobberyMoneyGui.Enabled then
		return false
	end

	local BagText = BagLabel.Text
	for i, v in next, BagText:split("") do
		if v == "/" then
			return BagText:sub(1, i - 2) == BagText:sub(i + 2)
		end
	end

	return false
end

local function SolveNumberLink()
	if Puzzle.IsOpen then
		repeat task.wait()
			local Success = false
			local GridCopy = {}

			for i = 1, #Puzzle.Grid do
				GridCopy[i] = {}
				for j = 1, #Puzzle.Grid[i] do
					GridCopy[i][j] = Puzzle.Grid[i][j] + 1
				end     
			end

			local Body = http.request({
				Url = "https://api.farmhub.lol", -- "https://numberlink.ra1n.dev/",
				Method = "POST",
				Body = HttpService:JSONEncode({
					Matrix = GridCopy
				}),
				Headers = {
					["Content-Type"] = "application/json",
					["X-Requested-With"] = "RobloxHttp"
				}
			}).Body

			local Solution = HttpService:JSONDecode(Body).Solution
			for i = 1, #Solution do
				for j = 1, #Solution[i] do
					Solution[i][j] = Solution[i][j] - 1
				end
			end

			local Pairs = getPairs(Solution)
			for i = 0, #Pairs do
				local Start = Pairs[i][1]
				local End = Pairs[i][2]
				local Current = Start

				for _ = 1, 50 do
					if not Puzzle.IsOpen then
						break
					end

					for x = -1, 1 do
						for y = -1, 1 do
							local Cell = Puzzle.Grid[Current.i + x] and Puzzle.Grid[Current.i + x][Current.j + y]
							local SolvedCell = Solution[Current.i + x] and Solution[Current.i + x][Current.j + y]

							if math.abs(x + y) == 1 and SolvedCell == Start.Cell and (Cell == -1 or (Current.i + x == End.i and Current.j + y == End.j)) then
								Puzzle.Grid[Current.i + x][Current.j + y] = SolvedCell
								Puzzle:Draw()
								Current = {
									i = Current.i + x,
									j = Current.j + y
								}
								break
							end
						end
					end

					task.wait((Settings.HumanSolve and 0.08 or 0.0000001))
					if Current.i == End.i and Current.j == End.j then
						Puzzle.OnConnection()
						break
					end
				end
			end

			repeat task.wait() until not Puzzle.IsOpen
			Success = true

			if not Success then
				Puzzle:Reset()
			end
		until not Puzzle.IsOpen
		return true
	end
	return false
end

local function GetUraniumValue()
	if PlayerGui:FindFirstChild("PowerPlantRobberyGui") then
		return tonumber(table.concat({string.match(PlayerGui.PowerPlantRobberyGui.Price.TextLabel.Text, "Uranium Value: $(%d),(%d+)")}, ""))
	end

	return 0
end

local function IsPlaneInAir()
	for _, spec in pairs(Specs) do
		if spec.Name == "Inspect Crate" then
			return true
		end
	end

	return false
end

local function AreCopsClose(range)
	for i, v in pairs(Players:GetPlayers()) do
		if v.Team.Name == "Police" and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			if DistanceXZ(Root.Position, v.Character.HumanoidRootPart.Position) <= range then
				return true
			end
		end
	end

	return false
end

local function HeliOnMap()
	for _, v in pairs(Workspace.Vehicles:GetChildren()) do
		if v.Name == "Heli" and v.PrimaryPart and v.Seat and not v.Seat.Player.Value and not Raycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then 
			return true
		end
	end

	return false
end

local function GetClosestAirdrop()
	if Workspace:FindFirstChild("Drop") then
		local TargetDrop = Workspace:FindFirstChild("Drop")       

		if TargetDrop:GetAttribute("BriefcaseLanded") then
			return TargetDrop
		end
	end

	return nil
end

local Platform = Instance.new("Part", Workspace) or Workspace:FindFirstChild("JBARPlatform")
Platform.Name = "JBARPlatform"
Platform.Anchored = true
Platform.Size = Vector3.new(150, 2, 150)
Platform.Position = Vector3.new(0, 0, 0)
Platform.Transparency = 1
Ignore(Platform)

local function BringPlatform(pos, move)
    pos = pos or CFrame.new(Root.CFrame.X, 1020, Root.CFrame.Z)
    move = move or true
    Platform.CFrame = pos

    if move then
        if GetVehiclePacket() then 
            GetVehicleModel():SetPrimaryPartCFrame(pos * CFrame.new(0, 4, 0))
        else
            Root.CFrame = pos * CFrame.new(0, 4, 0)
        end
    end
end

local function Cooldown()
	if Settings.AwaitReward and Player.PlayerGui.AppUI:FindFirstChild("RewardSpinner") then
		SetStatus("Safe Platform", "Awaiting reward spin..")
		repeat wait() until Player.PlayerGui.AppUI:FindFirstChild("RewardSpinner") == nil
		
	end

	if Settings.Cooldown ~= 0 then
		for i = 1, Settings.Cooldown, -1 do
			SetStatus("Safe Platform", "Cooling down.. " .. i .. "s")
			wait(1)
		end

		SetStatus("Safe Platform", "Cooling down..")
		wait(1)
	end
end

local function OnRobbery(store)
    local TimeElapsed = tick() - getgenv().StartingTime
    local MoneyMade = Leaderstats.Money.Value - getgenv().StartingMoney
    if Settings.WebhookURL == "" then
        return 
    end

	if not Settings.AlertEarnings then
		return
	end

	print("okk")

    spawn(function()
        wait(1.5)
        http.request({
            Url = Settings.WebhookURL,
            Method = "POST",
            Body = HttpService:JSONEncode({
            	["content"] = "# " .. Player.Name .. " completed " .. store .. "!\n> **Money Made:** `$" .. FormatCash(MoneyMade) .. "`\n> **Time Elapsed:** `" .. TickToHM(TimeElapsed) .. "`",
                ["username"] = "FarmHub Premium 👑 (.gg/farmhub)",
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            },
        })
    end)
end

RemoteEvent.OnClientEvent:Connect(function(Hash, ...) -- thanks 0xmin
	if not Settings.AlertHyper then
		return
	end

	local Args = {...}
	local ServerMessage = Args[1]
	if type(ServerMessage) == 'string' then
		if ServerMessage:find(Player.Name) or ServerMessage:find(Player.DisplayName) then
			ServerMessage = ServerMessage:gsub(Player.Name, ''):gsub(Player.DisplayName, '')
			if ServerMessage:find("Hyper") and Settings.WebhookUrl then
				http.request({
					Url = Settings.WebhookURL,
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json"
					},
					Body = HttpService:JSONEncode(
						{
							username = "FarmHub Premium 👑 (.gg/farmhub)",
							content = "# " .. Args[1] .. "\n> Alerting @everyone"
						}
					)
				})
			end
		end
	end
end)

local VolcanoPos = {
    Vector3.new(2135, 19, -2652),
    Vector3.new(2009, 19, -2539),
    Vector3.new(2142, 19, -2527),
    Vector3.new(2213, 19, -2659)
}

local function Escape(title)
	title = title or ""
	if not Character or not Root or not Humanoid or Humanoid.Health == 0 or (IsArrested() and not Player.Team == Teams.Prisoner) then
        task.wait(5)
		return error()
	end

	if Player.Team == Teams.Prisoner or IsArrested() then
		SetStatus(title, "Waiting..") 
	    if IsArrested() then
	        repeat task.wait() until not IsArrested()
        end

        if IsBlockingUp() then
            Humanoid.Health = 0
            task.wait(5)

            while Root == nil or Humanoid == nil or Character == nil do
                task.wait()
            end
        end

		SetStatus(title, "Escaping..") 
		Root.CFrame = CFrame.new(Root.CFrame.X, 200, Root.CFrame.Z)
		SmallTP(CFrame.new(-1007, 73, -1759))

		while Player.Team ~= Teams.Criminal do 
			wait()
			SmallTP(CFrame.new(-1007, 73, -1759))
		end
        EnterVehicle()
        task.wait(0.45)
        BringPlatform()
	else
        for i, v in pairs(VolcanoPos) do
            if (Root.Position - v).Magnitude < 100 then
				SetStatus(title, "Escaping..")
                PathfindTP(Vector3.new(2185, 19, -2663))
                ChainTP({
                    CFrame.new(2172, 28, -2717),
                    CFrame.new(2126, 28, -2977),
                    CFrame.new(2097, 28, -3106),
                    CFrame.new(2051, 20, -3178),
                })
                task.wait(1)
            end
        end

        if DistanceXZ(Root.Position, Vector3.new(-274, 18, 1581)) < 150 and IsBlockingUp() then
            if not GetVehicleModel() then  
				SetStatus(title, "Escaping..")
                PathfindTP(Vector3.new(-274, 18, 1581))
                task.wait(1)
            end
        end

        if IsBlockingUp() then
            Humanoid.Health = 0
            task.wait(5)

            while Root == nil or Humanoid == nil or Character == nil do
                task.wait()
            end

            return error()
        end
    end
end

-------------------->>  Robbery Callbacks  <<--------------------

local function RobBank()
	-- if not Settings.Enabled then return end
	if not Robbery["Bank"].Enabled then return end Escape("Bank")

	local Layout = Bank.Layout:GetChildren()[1]
	local Path = BankPaths[Layout.Name]

	if Path then
        SetStatus("Bank", "Teleporting to robbery..")
		VehicleInstantTP(CFrame.new(41, 18, 926))

        SetStatus("Bank", "Opening robbery..")
		repeat task.wait() until Robbery["Bank"].Value ~= 1 

        SetStatus("Bank", "Starting robbery..")
		if Robbery["Bank"].Value == 3 then
			task.wait(2)
			return error()
		end

		for i, v in pairs(Layout.Lasers:GetDescendants()) do
			if v:IsA("TouchTransmitter") then
				pcall(function()
					v.Parent.Transparency = 1.000
				end)
				pcall(function()
					v:Destroy()
				end)
			end
		end

		ChainTP(Path)
        SetStatus("Bank", "Collecting cash..")
		Robbery["Bank"].Robbed = true
		repeat task.wait() until IsBagFull() or AreCopsClose(Settings.CopRange)

        SetStatus("Bank", "Exiting robbery..")
		ChainTP(FlipTable(Path))
		ChainTP({
			CFrame.new(41, 19, 926),
			CFrame.new(28, 19, 860),
			CFrame.new(5, 19, 864)
		})

        SetStatus("Bank", "Robbery Complete!")
		EnterVehicle()
		task.wait(0.45)
		OnRobbery("Bank")
		BringPlatform()
	end
end

local function RobCraterBank()
	-- if not Settings.Enabled then return end
	if not Robbery.CraterBank.Enabled then return end Escape("Crater Bank")

	local Layout = Bank2.Layout:GetChildren()[1]
	local Path = BankPaths[Layout.Name]

	if Path then
        SetStatus("Crater Bank", "Teleporting to robbery..")
        VehicleInstantTP(CFrame.new(-647, 20, -5990))

        SetStatus("Crater Bank", "Opening robbery..")
		repeat task.wait() until Robbery.CraterBank.Value ~= 1 

        SetStatus("Crater Bank", "Starting robbery..")
		if Robbery.CraterBank.Value == 3 then
			task.wait(2)
			return error()
		end

		for i, v in pairs(Layout.Lasers:GetDescendants()) do
			if v:IsA("TouchTransmitter") then
				pcall(function()
					v.Parent.Transparency = 1.000
				end)
				pcall(function()
					v:Destroy()
				end)
			end
		end

		ChainTP(Path)
        SetStatus("Crater Bank", "Collecting cash..")
		Robbery.CraterBank.Robbed = true
		repeat task.wait() until IsBagFull() or AreCopsClose(Settings.CopRange)

        SetStatus("Crater Bank", "Exiting robbery..")
		ChainTP(FlipTable(Path))
        ChainTP({
            CFrame.new(-647, 24, -5990),
            CFrame.new(-653, 20, -6009),
            CFrame.new(-600, 20, -6031),
            CFrame.new(-612, 20, -6058),
            CFrame.new(-634, 20, -6048),
            CFrame.new(-652, 20, -6091)
        })

        SetStatus("Crater Bank", "Robbery Complete!")
		EnterVehicle()
		task.wait(0.45)
		OnRobbery("Crater Bank")
		BringPlatform()
	end
end

local function RobJewelryStore()
    if not Robbery.Jewelry.Enabled then return end Escape("Jewelry Store")

	-- if not Jewelry then
	-- 	ExitVehicle()
	-- 	WaitUntil(function()
	-- 		Root.CFrame = NewCFrame(Robbery.Jewelry.GetPos())
	-- 		return Jewelry ~= nil
	-- 	end, 5)

	-- 	if Jewelry == nil then
	-- 		return error()
	-- 	end
	-- end

	local Jewelry = Workspace:FindFirstChild("Jewelrys"):GetChildren()[1]
	if not Jewelry then return end
    local Floor = Jewelry.Floors:GetChildren()[1]
    local Path = JewelryPaths[Floor.Name]
    local Boxes = Jewelry.Boxes:GetChildren()

    if Path then
        for _, v in pairs(Jewelry:GetDescendants()) do
            if (v:IsA("TouchInterest") or v:IsA("TouchTransmitter")) and v.Parent and v.Parent.Name ~= "LaserTouch" then
                pcall(function()
                    v:Remove()
                end)
                pcall(function()
                    v.Parent.Transparency = 1.000
                end)
            end
        end

        SetStatus("Jewelry Store", "Teleporting to robbery..")
        firetouchinterest(Root, Jewelry.WindowEntry.LaserTouch, 0)
        task.wait()
        firetouchinterest(Root, Jewelry.WindowEntry.LaserTouch, 1)
        VehicleInstantTP(CFrame.new(98, 19, 1311))
        
        SetStatus("Jewelry Store", "Collecting jewels..")
        KillAuraPaused = true
        Robbery.Jewelry.Robbed = true

        table.sort(Boxes, function(a, b)
            return DistanceXZ(Root.Position, a.Position) < DistanceXZ(Root.Position, b.Position)
        end)

        for _, box in pairs(Boxes) do
            if box.Transparency ~= 1 and box.Position.Y < 20 then            
                PathfindTP(box.Position + Vector3.new(0, 2.25, 2.25))
                task.wait(0.01)
                Character:PivotTo(CFrame.lookAt((box.Position + Vector3.new(0, 2.25, 2.25)), box.Position))
                BreakFunc = tick()
                repeat
                    AttemptPunch()
                    task.wait(0.25)
                until box.Transparency == 1 or tick() - BreakFunc > 6 or not Robbery.Jewelry.Open 
            end
            if IsBagFull() or not Robbery.Jewelry.Open then
                break
            end
        end

		SetStatus("Jewelry Store", "Exiting Robbery..")
        KillAuraPaused = false
        PathfindTP(Vector3.new(107, 22, 1343))     

        ChainTP({
            CFrame.new(107, 22, 1343),
            CFrame.new(96, 38, 1285),
            CFrame.new(129, 42, 1306),
            CFrame.new(107, 42, 1343),
            CFrame.new(96, 55, 1285)
        })
        ChainTP(Path)
        ChainTP({
            CFrame.new(137, 103, 1278),
            CFrame.new(137, 103, 1338),
            CFrame.new(125, 102, 1341),
            CFrame.new(113, 119, 1282)
        })

        task.wait(0.5)
		SetStatus("Jewelry Store", "Teleporting to base..")
        Root.CFrame = CFrame.new(100, 119, 1284)
        task.wait(0.5)
        BigTP(CFrame.new(-276, 18, 1606)) 

        SetStatus("Jewelry Store",  "Selling..")
        repeat wait() until not RobberyMoneyGui.Enabled

        SetStatus("Jewelry Store", "Robbery Complete!")
        EnterVehicle()
        task.wait(0.45)
        OnRobbery("Jewelry Store")
        BringPlatform()
    end
end

local function RobMuseum()
	-- if not Settings.Enabled then return end
	if not Robbery.Museum.Enabled then return end Escape("Museum")

    SetStatus("Museum", "Teleporting to robbery..")
	VehicleInstantTP(NewCFrame(1159, 102, 1237))
	Robbery.Museum.Robbed = true
	wait(0.5)

	local Timeout = tick()
    SetStatus("Museum", "Collecting items..")
	repeat 
		for _, spec in pairs(Specs) do
			if spec.Name:sub(1, 5) == "Grab " and spec.Part and DistanceXZ(Root.Position, spec.Part.Position) <= 100 then
				spec:Callback(true)
				if IsBagFull() then 
					break
				end
			end
		end
		task.wait()
	until IsBagFull() or Timeout - tick() > 10 or not Robbery.Museum.Open

	if not Robbery.Museum.Open then
		return error()
	end

	wait(0.5)
    SetStatus("Museum", "Exiting Robbery..")
	ChainTP({
		NewCFrame(1171, 102, 1221),
		NewCFrame(1183, 102, 1206)
	})

    SetStatus("Museum", "Teleporting to volcano..")
	VehicleTP(NewCFrame(2286, 19, -2060))
	task.wait(0.1)

	VehicleDirectTP(NewCFrame(2275, 25, -2127))
	VehicleDirectTP(NewCFrame(2213, 25, -2475))
	VehicleDirectTP(NewCFrame(2279, 25, -2551))
    SetStatus("Museum", "Selling..")
	VehicleDirectTP(NewCFrame(2291, 20, -2593))
	repeat task.wait() until not RobberyMoneyGui.Enabled
    SetStatus("Museum", "Robbery Complete!")

	VehicleDirectTP(NewCFrame(2279, 25, -2551))
	VehicleDirectTP(NewCFrame(2213, 25, -2475))
	VehicleDirectTP(NewCFrame(2275, 25, -2127))
	VehicleDirectTP(NewCFrame(2284, 19, -2072))

	task.wait(0.45)
	OnRobbery("Museum")
	BringPlatform()
end

local function RobPowerPlant()
    if not Robbery.PowerPlant.Enabled then return end Escape("Power Plant")
    SetStatus("Power Plant", "Teleporting to robbery..")
    VehicleTP(CFrame.new(61, 21, 2322), true)
    task.wait(0.5)
    Root.CFrame = CFrame.new(68, 21, 2324)
    task.wait(0.2)
    SetStatus("Power Plant", "Opening robbery..")
    SmallTP(CFrame.new(88, 22, 2324))

    BreakFunc = tick()
    repeat task.wait() until Puzzle.IsOpen or tick() - BreakFunc > 5
    if not Puzzle.IsOpen then
        SetStatus("Power Plant", "Robbery Failed!")
        EnterVehicle()
        task.wait(0.45)
        BringPlatform()
        return error()
    end

    if SolveNumberLink() then
        SetStatus("Power Plant", "Starting robbery..")

        ChainTP({
            CFrame.new(93, 30, 2336),
            CFrame.new(145, 27, 2296),
            CFrame.new(210, 19, 2246),
            CFrame.new(145, -8, 2096),
            CFrame.new(119, -9, 2099)
        })

        SetStatus("Power Plant", "Collecting uranium..")
        BreakFunc = tick()
        repeat task.wait() until Puzzle.IsOpen or tick() - BreakFunc > 5
        pcall(SolveNumberLink)

        Robbery.PowerPlant.Robbed = true
        SetStatus("Power Plant", "Exiting robbery..")
        ChainTP({
            CFrame.new(93, -13, 2130),
            CFrame.new(87, -37, 2115),
            CFrame.new(42, -37, 2100),
            CFrame.new(28, -37, 2135),
            CFrame.new(51, -37, 2169),
            CFrame.new(59, -5, 2188),
            CFrame.new(49, -5, 2197),
            CFrame.new(96, 14, 2259),
            CFrame.new(96, 23, 2259),
            CFrame.new(64, 21, 2303),
            CFrame.new(63, 21, 2324)
        })
    
		SetStatus("Power Plant", "Teleporting to volcano..")
		VehicleTP(NewCFrame(2286, 19, -2060))
		task.wait(0.1)
	
		VehicleDirectTP(NewCFrame(2275, 25, -2127))
		VehicleDirectTP(NewCFrame(2213, 25, -2475))
		VehicleDirectTP(NewCFrame(2279, 25, -2551))
		SetStatus("Power Plant", "Selling..")
		GetVehicleModel().PrimaryPart.Anchored = true
        if Player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") then
            GetVehicleModel():SetPrimaryPartCFrame(CFrame.new(2279, 70, -2551))
            repeat task.wait() until GetUraniumValue() <= 6400
            GetVehicleModel():SetPrimaryPartCFrame(CFrame.new(2279, 25, -2551))
        end
        GetVehicleModel().PrimaryPart.Anchored = false

		VehicleDirectTP(NewCFrame(2291, 20, -2593))
        repeat task.wait() until not PlayerGui:FindFirstChild("PowerPlantRobberyGui")
		SetStatus("Power Plant", "Robbery Complete!")
	
		VehicleDirectTP(NewCFrame(2279, 25, -2551))
		VehicleDirectTP(NewCFrame(2213, 25, -2475))
		VehicleDirectTP(NewCFrame(2275, 25, -2127))
		VehicleDirectTP(NewCFrame(2284, 19, -2072))
	
		task.wait(0.45)
		OnRobbery("Power Plant")
		BringPlatform()
    else
        SetStatus("Power Plant", "Robbery Failed!")
        EnterVehicle()
        task.wait(0.45)
        BringPlatform()
        return error()
    end
end

local function RobCargoTrain()
	if not Robbery.CargoTrain.Enabled then return end Escape("Cargo Train")

	local BoxCar = nil
    local Gold = nil

    for _, cart in pairs(Workspace.Trains:GetChildren()) do 
        if cart.Name:sub(1, 6) == "BoxCar" then
            BoxCar = cart
            Gold = BoxCar.Model.Rob.Gold
            break
        end
    end

    if not BoxCar then
        return false
    end

    SetStatus("Cargo Train", "Teleporting to cargo train!")
    for _, spec in pairs(Specs) do  
        if spec.Name == "Breach Vault" or spec.Name == "Open Door" then
            spec:Callback(true)
        end
    end
    
    ExitVehicle()
    BringPlatform()
    task.wait(0.2)
    repeat task.wait() until Gold.CFrame.Z > -5250
    Platform.CFrame = CFrame.new(0, 0, 0)
    task.wait(0.5)

    BreakFunc = tick()
    repeat
        Root.CFrame = Gold.CFrame * CFrame.new(0, 3, 0)
        task.wait()
        if tick() - BreakFunc > 8 and not RobberyMoneyGui.Enabled then
            return error()
        end
    until RobberyMoneyGui.Enabled and tick() - BreakFunc > 4
    
    SetStatus("Cargo Train", "Collecting cash..")
    Robbery.CargoTrain.Robbed = true
    repeat task.wait() until IsBagFull() or not RobberyMoneyGui.Enabled

    SetStatus("Cargo Train", "Waiting..")
    repeat task.wait() until not Raycast(Root.Position + Vector3.new(0, 8, 0), Vector3.new(0, 1000, 0)) 
    task.wait(1)

    SetStatus("Cargo Train", "Robbery Complete!")
    OnRobbery("Cargo Train")
    BringPlatform()
end

local function RobPassengerTrain()
	-- if not Settings.Enabled then return end
	if not Robbery.PassengerTrain.Enabled then return end Escape("Passenger Train")
    SetStatus("Passenger Train", "Teleporting to robbery..")
    BringPlatform()
    wait(1)
	BreakFunc = tick()
    SetStatus("Passenger Train", "Collecting items..")
	repeat task.wait()
		for _, spec in pairs(Specs) do
			if spec.Name:sub(1, 5) == "Grab " and spec.Part and Trains:IsAncestorOf(spec.Part) then 
				spec:Callback(true)

				if IsBagFull() then
					break
				end

				task.wait(1.4)
			end
		end
	until IsBagFull() or tick() - BreakFunc > 10 or not Robbery.PassengerTrain.Open
	Robbery.PassengerTrain.Robbed = true

    SetStatus("Passenger Train", "Teleporting to volcano..")
	VehicleTP(NewCFrame(2286, 19, -2060))
	task.wait(0.1)

	VehicleDirectTP(NewCFrame(2275, 25, -2127))
	VehicleDirectTP(NewCFrame(2213, 25, -2475))
	VehicleDirectTP(NewCFrame(2279, 25, -2551))
    SetStatus("Passenger Train", "Selling..")
	VehicleDirectTP(NewCFrame(2291, 20, -2593))
	repeat task.wait() until not RobberyMoneyGui.Enabled
    SetStatus("Passenger Train", "Robbery Complete!")

	VehicleDirectTP(NewCFrame(2279, 25, -2551))
	VehicleDirectTP(NewCFrame(2213, 25, -2475))
	VehicleDirectTP(NewCFrame(2275, 25, -2127))
	VehicleDirectTP(NewCFrame(2284, 19, -2072))

	task.wait(0.45)
	OnRobbery("Passenger Train")
	BringPlatform()
end

local function RobCargoPlane()
	-- if not Settings.Enabled then return end
	if not Robbery.CargoPlane.Enabled then return end Escape("Cargo Plane")
	if not IsPlaneInAir() then return end

	local PlaneCrate = nil
	for _, spec in pairs(Specs) do
		if spec.Name == "Inspect Crate" then
			PlaneCrate = spec
			break
		end
	end

    SetStatus("Cargo Plane", "Teleporting to robbery..")
	GetVehicle()
	BringPlatform()
	task.wait(0.5)
	Platform.CFrame = CFrame.new(0, 0, 0)
	task.wait(0.5)
	BreakFunc = tick()

	Robbery.CargoPlane.Robbed = true
    SetStatus("Cargo Plane", "Collecting crate..")
	repeat 
		GetVehicleModel():SetPrimaryPartCFrame(NewCFrame(Robbery.CargoPlane.GetPos() + NewVector3(0, 5, 0)))
		task.wait()
		for _, spec in pairs(Specs) do
			if spec.Name == "Inspect Crate" then
				spec:Callback(true)
				break
			end
		end
	until IsBagFull()

    SetStatus("Cargo Plane", "Teleporting to port..")
	VehicleTP(CFrame.new(-352, 21, 2057))

    SetStatus("Cargo Plane", "Selling..")

	repeat wait() until not RobberyMoneyGui.Enabled
    SetStatus("Cargo Plane", "Robbery Complete!")
	task.wait(0.45)
	OnRobbery("Cargo Plane")
	BringPlatform()
end

local function RobCargoShip()
	if not Robbery.CargoShip.Enabled then return end Escape("Cargo Ship")
	local Vehicles = Workspace.Vehicles:GetChildren()
	local Helis = {}

	for i, v in pairs(Vehicles) do
		if v.Name == "Heli" and v.PrimaryPart and v.Seat and not v.Seat.Player.Value and not Raycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then 
			table.insert(Helis, v)
		end
	end

	if #Helis == 0 then
		if not (GetVehiclePacket() and GetVehiclePacket().Name == "Heli") then
			return error()
		end
	end

	if not (GetVehiclePacket() and GetVehiclePacket().Name == "Heli") then
		table.sort(Helis, function(a, b)
			if a.PrimaryPart and b.PrimaryPart then
				return (a.PrimaryPart.Position - Root.Position).Magnitude < (b.PrimaryPart.Position - Root.Position).Magnitude
			end
		end)

		for i, v in pairs(Helis) do
            SetStatus("Cargo Ship", "Teleporting to heli..")
			VehicleTP(CFrame.new(v.Seat.CFrame.X, (v.Seat.CFrame.Y + 15), v.Seat.CFrame.Z), true)

			if v.Seat and v.PrimaryPart then
				Root.CFrame = CFrame.new(v.Seat.CFrame.X, (v.Seat.CFrame.Y + 2), v.Seat.CFrame.Z)

				for i = 1, 200 do
					if not v.Seat or not v.PrimaryPart then
						break
					end

					if GetVehiclePacket() then
						break
					end

					if v:GetAttribute("Locked") then
						break
					end

					if not v.PrimaryPart or not v:FindFirstChild("Seat") then
						break
					end

					EnterVehicle(v)
					Root.CFrame = v.Seat.CFrame
					task.wait(0.025)
				end

				if GetVehiclePacket() then
					break
				end
			end
		end
	end

	if not (GetVehiclePacket() and GetVehicleModel().Name == "Heli") then
		return error()
	end

    SetStatus("Cargo Ship", "Starting robbery..")
	GetVehicleModel():SetPrimaryPartCFrame(CFrame.new(Root.CFrame.X, 650, Root.CFrame.Z))
	task.wait(0.5)

	local ShipCrate = nil 
	local RopePull = nil
	local Ship = Workspace:FindFirstChild("CargoShip")
	Modules.Vehicle.Classes.Heli.attemptDropRope()
	wait(0.25)

	for i = 1, 2 do
		if not Ship then break end
		ShipCrate = Ship.Crates:FindFirstChild("Crate")
		Player:RequestStreamAroundAsync(ShipCrate.MeshPart.Position, 1000)

		RopePull = GetVehicleModel():WaitForChild("Preset"):WaitForChild("RopePull")
		RopePull.CanCollide = true
		if not ShipCrate then break end
		GetVehicleModel().Winch.RopeConstraint.Length = 10000  

        SetStatus("Cargo Ship", "Collecting crate..")
		repeat
			pcall(function()
				RopePull.CFrame = ShipCrate.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
				RopePull.ReqLink:FireServer(ShipCrate, Vector3.zero)
			end)
			task.wait()
		until RopePull.AttachedTo.Value or not Workspace:FindFirstChild("CargoShip") or not Ship.Crates:FindFirstChild("Crate")
		task.wait(0.5)

        SetStatus("Cargo Ship", "Selling..")
		pcall(function()
			repeat
				ShipCrate.PrimaryPart.Velocity, ShipCrate.PrimaryPart.RotVelocity = Vector3.new(), Vector3.new()
				RopePull:PivotTo(CFrame.new(-471, -50, 1906))
				ShipCrate:PivotTo(CFrame.new(-471, -50, 1906))
				task.wait(0.5)
			until not RopePull.AttachedTo.Value or not ShipCrate
		end)

		Robbery.CargoShip.Robbed = true
		RopePull.ReqUnlink:FireServer(ShipCrate)
		task.wait(0.5)
	end

    SetStatus("Cargo Ship", "Robbery Complete!")
	Modules.Vehicle.Classes.Heli.attemptDropRope()
	ExitVehicle()
	OnRobbery("Cargo Ship")
	BringPlatform()
end

local function RobMansion()
    if not Robbery.Mansion.Enabled then return end Escape("Mansion")

    SetStatus("Mansion", "Teleporting to robbery..")
    VehicleInstantTP(CFrame.new(3198, 65, -4611))
    SetStatus("Mansion", "Opening robbery..")

    BreakFunc = tick()
    repeat
		Root.CFrame = MansionRobbery.Lobby.EntranceElevator.TouchToEnter.CFrame
        firetouchinterest(Root, MansionRobbery.Lobby.EntranceElevator.TouchToEnter, 0)
        task.wait()
        firetouchinterest(Root, MansionRobbery.Lobby.EntranceElevator.TouchToEnter, 1)
    until Modules.MansionUtils.isPlayerInElevator(MansionRobbery, Player) or tick() - BreakFunc > 6

    if not Modules.MansionUtils.isPlayerInElevator(MansionRobbery, Player) then
        SetStatus("Mansion", "Robbery Failed!")
        ChainTP({
            CFrame.new(3197, 63, -4654),
            CFrame.new(3198, 65, -4611), 
            CFrame.new(3171, 65, -4609), 
            CFrame.new(3171, 68, -4610), 
            CFrame.new(3111, 68, -4606), 
            CFrame.new(3111, 65, -4606), 
            CFrame.new(3093, 65, -4606), 
            CFrame.new(3044, 62, -4605), 
            CFrame.new(3036, 58, -4696)
        })
        EnterVehicle()
        task.wait(0.45)
        BringPlatform()
        return error()
    end

    local ElevatorDoor = MansionRobbery.ArrivalElevator.Floors:GetChildren()[1].DoorLeft.InnerModel.Door
    task.wait(1)
    GetPistol()

    repeat
        task.wait(0.1)
    until ElevatorDoor.Position.X > 3208

    for _, instance in pairs(MansionRobbery.Lasers:GetChildren()) do
        instance:Remove()
    end
    for _, instance in pairs(MansionRobbery.LaserTraps:GetChildren()) do
        instance:Remove()
    end

	SetStatus("Mansion", "Starting robbery..")
    ChainTP({
        CFrame.new(3202, -200, -4703),
        CFrame.new(3201, -200, -4679),
        CFrame.new(3106, -204, -4675),
        CFrame.new(3106, -204, -4647),
        CFrame.new(3140, -204, -4647),
        CFrame.new(3147, -204, -4566)
    })
    KillAuraPaused = true
    repeat task.wait() until MansionRobbery:GetAttribute("MansionRobberyProgressionState") == 3
    Modules.MansionUtils.getProgressionStateChangedSignal(MansionRobbery):Wait()
    
    local BossCEO = MansionRobbery:WaitForChild("ActiveBoss")
    Robbery.Mansion.Robbed = true

    setreadonly(Modules.BossConsts.ATTACK_STATE._map, false)
	table.foreach(Modules.BossConsts.ATTACK_STATE._map, function(i, v)
		if i ~= "None" then
			Modules.BossConsts.ATTACK_STATE._map[i] = 89 + v
		end
	end)	
	setreadonly(Modules.BossConsts.ATTACK_STATE._map, true)

    Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = function(...)
        local arg = {DefaultModules.OldRayIgnore(...)}                 
        if (tostring(getfenv(2).script) == "BulletEmitter" or tostring(getfenv(2).script) == "Taser") then
            arg[1] = BossCEO.Head
            arg[2] = BossCEO.Head.Position
        end
        return unpack(arg)
    end

    SetStatus("Mansion", "Killing boss..")
    if not Player.Folder:FindFirstChild("Pistol") then
        Humanoid.Health = 0
        return error()
    end

	local NPCS = {}
	Modules.NPC.new = function(NPCObject, ...)
		if NPCObject.Name ~= "ActiveBoss" then
			for i, v in pairs(NPCObject:GetDescendants()) do
				pcall(function()
					v.Transparency = 1
				end)
				table.insert(NPCS, v)
			end
		end
		return DefaultModules.NPC_new(NPCObject, ...)
	end

	Modules.NPC.GetTarget = function(...)
		return MansionRobbery and MansionRobbery:FindFirstChild("ActiveBoss") and MansionRobbery:FindFirstChild("ActiveBoss").HumanoidRootPart
	end

	Workspace.Items.DescendantAdded:Connect(function(Des)
		if Des:IsA("BasePart") then
			Des.Transparency = 1
			Des:GetPropertyChangedSignal("Transparency"):Connect(function()
				Des.Transparency = 1
			end)
		end
	end)

	for i, v in pairs(ReplicatedStorage.Game.Item:GetChildren()) do
		require(v).ReloadDropAmmoVisual = function() end
		require(v).ReloadDropAmmoSound = function() end
		require(v).ReloadRefillAmmoSound = function() end
		require(v).ShootSound = function() end
	end

	getfenv(Modules.BulletEmitter.Emit).Instance = {
		new = function()
			return {
				Destroy = function() end
			}
		end
	}

	BringPlatform(CFrame.new(Root.CFrame.X, (Root.CFrame.Y + 18), Root.CFrame.Z))

	while BossCEO and BossCEO:FindFirstChild("HumanoidRootPart") and BossCEO.Humanoid.Health ~= 1 do
        EquipPistol(true)
		task.wait(0.15)
		ShootPistol()
        for i, v in pairs(MansionRobbery.GuardsFolder:GetChildren()) do
            v.HumanoidRootPart.CFrame = BossCEO.HumanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
        end
	end

	SetStatus("Mansion", "Collecting cash..")
    EquipPistol(false)
    repeat task.wait() until Player.PlayerGui.AppUI:FindFirstChild("RewardSpinner")
    KillAuraPaused = false
	Modules.Raycast.RayIgnoreNonCollideWithIgnoreList = DefaultModules.OldRayIgnore
	Modules.NPC.new = DefaultModules.NPC_new
	Modules.NPC.GetTarget = DefaultModules.NPC_GetTarget

	for i, v in pairs(NPCS) do
		pcall(function()
			v:Remove()
		end)
	end

    Platform.CFrame = CFrame.new(0, 0, 0)
	SetStatus("Mansion", "Robbery Complete!")
    ChainTP({ 
        CFrame.new(3113, -204, -4440),
        CFrame.new(3096, -204, -4440),
        CFrame.new(3097, -219, -4519),
        CFrame.new(3077, -221, -4518),
        MansionRobbery.ExitDoor.Touch.CFrame
    })

    repeat task.wait() until Root.CFrame.Y > 0
    task.wait(0.5)
    BigTP(CFrame.new(3036, 58, -4696))
    EnterVehicle()
    task.wait(0.45)
    OnRobbery("Mansion")
    BringPlatform()
end

--[[
local function robCasino()
    if not settings.includeCasino then return end escape()
    setStat("Going to the casino")
    movePlatform()
    exitVehicle()
    wait(1)
    local hacked = false
    for k, v in pairs(Casino.Computers:GetChildren()) do
        if v.Display.BrickColor == BrickColor.new("Lime green") then
            hacked = true
        end
    end

    if not hacked then
        setStat("Opening casino..")
        local Computers = Casino.Computers:GetChildren()    
        for k, v in pairs(Computers) do
            if v.Display.BrickColor ~= BrickColor.new("Institutional white") and v.Display.BrickColor ~= BrickColor.new("Lime green") then
                while (v.Display.BrickColor ~= BrickColor.new("Institutional white") and v.Display.BrickColor ~= BrickColor.new("Lime green")) do 
                    root.CFrame = v.Display.CFrame * CFrame.new(0, 2, 0)
                    v.CasinoComputerHack:FireServer()
                    task.wait()
                end 
            end
            if v.Display.BrickColor == BrickColor.new("Lime green") then
                break
            end
        end
    end
    for _, v in pairs(Casino.Loots:GetChildren()) do
        getgenv().breakfunc = tick()
        repeat
            root.CFrame = v.CFrame
            for i2, v2 in pairs(Casino.Loots:GetChildren()) do
                if distanceXZ(v2.Position, root.Position) < 15 then
                    v2.CasinoLootCollect:FireServer()
                    wait()
                end
            end  
            wait()
        until isBagFull() or tick() - getgenv().breakfunc > 2
        if isBagFull() then
            break
        end
    end
    robberys.casino.robbed = true
    setStat("Wait 5 seconds")
    wait(5)
    setStat("Going to the criminal base")
    vehicleTP(CFrame.new(-274, 18, 1581))
    repeat wait() until not robberyMoneyGui.Enabled
    setStat("Casino success!")
    movePlatform()
end
--]]

-- local function RobCasino()
--     if not Robbery.Casino.Enabled then return end Escape("Casino")
    
-- 	if not Casino then
-- 		ExitVehicle()
-- 		WaitUntil(function()
-- 			Root.CFrame = NewCFrame(Robbery.Casino.GetPos())
-- 			return Casino ~= nil
-- 		end, 5)

-- 		if Casino == nil then
-- 			return error()
-- 		end
-- 	end

--     local Hacked = false
--     -- for _, v in pairs(Casino.Computers:GetChildren()) do
--     --      if v.Display.BrickColor == BrickColor.new("Lime green") then
--     --          Hacked = true
--     --      end
--     -- end

--     pcall(function()
--         for _, v in pairs(Casino.CamerasMoving:GetChildren()) do
--             v:Remove()
--         end
--     end)
--     pcall(function()
--         for _, v in pairs(Casino.Lasers:GetChildren()) do
--             v:Remove()
--         end
--     end)
--     pcall(function()
--         for _, v in pairs(Casino.LasersMoving:GetChildren()) do
--             v:Remove()
--         end
--     end)
--     pcall(function()
--         for _, v in pairs(Casino.LaserCarousel:GetChildren()) do
--             v:Remove()
--         end
--     end)

--     SetStatus("Casino", "Teleporting to robbery..")
--     BringPlatform()
-- 	ExitVehicle()
-- 	wait(2)
	
--     if not Hacked then        
--         SetStatus("Casino", "Opening robbery..")
--         for _, v in pairs(Casino.Computers:GetChildren()) do
-- 			if v.Display.BrickColor == BrickColor.new("Really red") then
-- 				repeat 
-- 					Root.CFrame = v.Display.CFrame
-- 					for _, spec in pairs(Specs) do
-- 						if spec.Name == "Hack" then
-- 							spec:Callback(true)
-- 						end
-- 					end
-- 					task.wait()
-- 				until v.Display.BrickColor ~= BrickColor.new("Really red") or not Robbery.Casino.Open

-- 				if v.Display.BrickColor == BrickColor.new("Lime green") or not Robbery.Casino.Open then
-- 					break	
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if not Robbery.Casino.Open then
-- 		return error()
-- 	end

-- 	SetStatus("Casino", "Waiting..")
--     wait(5)
	
--     SetStatus("Casino", "Collecting cash..")
-- 	Robbery.Casino.Robbed = true

-- 	local Timeout = tick()
--     while not IsBagFull() and tick() - Timeout < 10 and Robbery.Casino.Open do
-- 		for _, v in pairs(Casino.Loots:GetChildren()) do
-- 			for i = 1, 20 do
-- 				Root.CFrame = v.CFrame
-- 				wait(0.1)
-- 				v.CasinoLootCollect:FireServer()

-- 				if IsBagFull() then
-- 					break
-- 				end
-- 			end
--         end
-- 	end

-- 	SetStatus("Casino", "Waiting..")
-- 	wait(5)
-- 	SetStatus("Casino", "Teleporting to volcano..")
-- 	VehicleTP(NewCFrame(2286, 19, -2060))
-- 	task.wait(0.1)

-- 	VehicleDirectTP(NewCFrame(2275, 25, -2127))
-- 	VehicleDirectTP(NewCFrame(2213, 25, -2475))
-- 	VehicleDirectTP(NewCFrame(2279, 25, -2551))
--     SetStatus("Casino", "Selling..")
-- 	VehicleDirectTP(NewCFrame(2291, 20, -2593))
-- 	repeat task.wait() until not RobberyMoneyGui.Enabled
--     SetStatus("Casino", "Robbery Complete!")

-- 	VehicleDirectTP(NewCFrame(2279, 25, -2551))
-- 	VehicleDirectTP(NewCFrame(2213, 25, -2475))
-- 	VehicleDirectTP(NewCFrame(2275, 25, -2127))
-- 	VehicleDirectTP(NewCFrame(2284, 19, -2072))

-- 	task.wait(0.45)
--     OnRobbery("Casino")
--     BringPlatform()
-- end

local function RobOilRig()
	if not Robbery.OilRig.Enabled then return end Escape("Oil Rig")
	SetStatus("Oil Rig", "Teleporting to robbery..")
	for i, v in pairs(Workspace.OilRig.Turrets:GetChildren()) do
		pcall(function()
			v:Remove()
		end)
	end

	VehicleTP(CFrame.new(-2786, 135, -4067), true)

	SetStatus("Oil Rig", "Opening robbery..")
	SmallTP(CFrame.new(-2780, 135, -4003))

	repeat
		for i, v in pairs(Specs) do
			if v.Name == "Place TNT" and v.Part and DistanceXZ(Root.Position, v.Part.Position) < 15 then
				v.Part.OnPressedRemote:FireServer(false)
				wait(1.5)
				v.Part.OnPressedRemote:FireServer(true)
				break
			end
		end
		wait(0.5)
	until RobberyMoneyGui.Enabled

	Robbery.OilRig.Robbed = true
	SmallTP(CFrame.new(-2797, 137, -4068))

	repeat 
		for i, v in pairs(Workspace.OilRig.GuardsFolder:GetChildren()) do
			v.Humanoid.Health = 0
		end
		wait(0.2)
	until Workspace.OilRig.GuardCounters.GuardCounter.SurfaceGui.TextLabel.Text == "00"

	local EntranceDoorOil = workspace.OilRig.ElevatorLockPuzzle.SlideDoor.InnerModel.Door
	if EntranceDoorOil.CFrame == CFrame.new(-2900.07056, 137.399994, -4065.89355, 0, 0, 1, 0, 1, 0, -1, 0, 0) then
		ChainTP({
			NewCFrame(-2807, 134, -4067), 
			NewCFrame(-2868, 134, -4066), 
			NewCFrame(-2893, 134, -4031), 
			NewCFrame(-2905, 134, -4031), 
			NewCFrame(-2908, 134, -4047) 
		})
		task.wait(.2)
		repeat
			for i, v in pairs(Specs) do
				if v.Name == "Pull Lever" and v.Part and DistanceXZ(Root.Position, v.Part.Position) < 15 then
					v.Part.Parent.OnPressedRemote:FireServer(false)
					wait(1.5)
					v.Part.Parent.OnPressedRemote:FireServer(true)
					break
				end
			end
			task.wait()
		until EntranceDoorOil.CFrame ~= CFrame.new(-2900.07056, 137.399994, -4065.89355, 0, 0, 1, 0, 1, 0, -1, 0, 0)
		ChainTP({
			NewCFrame(-2904, 134, -4030), 
			NewCFrame(-2891, 134, -4031), 
			NewCFrame(-2888, 134, -4065), 
			NewCFrame(-2904, 134, -4065) 
		})
	else
		ChainTP({
			NewCFrame(-2807, 134, -4067), 
			NewCFrame(-2904, 134, -4065) 
		})
	end

	SetStatus("Oil Rig",  "Starting robbery..")

	for i, v in pairs(workspace.OilRig.GuardsFolder:GetChildren()) do
		v.Humanoid.Health = 0
	end
	local Loopedkill = workspace.OilRig.GuardsFolder.ChildAdded:Connect(function(v)
		pcall(function()
			wait(2)
			v.Humanoid.Health = 0
		end)
	end)
	delay(40, function()
		Loopedkill:Disconnect()
	end)

	ChainTP({
		NewCFrame(-2905, 154, -4101), 
		NewCFrame(-2906, 172, -4090), 
		NewCFrame(-2906, 171, -4081), 
		NewCFrame(-2898, 164, -4081), 
		NewCFrame(-2887, 164, -4081) 
	})
	
	local CrackDoor = Workspace.OilRig.CommandRoomDoor.InnerModel.DoorVisual

	if CrackDoor.CFrame == CFrame.new(-2886.07104, 166.855942, -4082.29297, 0, 0, 1, 0, 1, -0, -1, 0, 0) then
		repeat 
			for i, v in pairs(Specs) do
				if v.Name == "Crack Door" and DistanceXZ(Root.Position, v.Part.Position) < 15 then
					v:Callback(true)
				end
			end
			task.wait(1)
		until Puzzle.IsOpen

		while not pcall(SolveNumberLink) do 
			wait(1)
		end
	end

	ChainTP({
		NewCFrame(-2864, 165, -4083), 
		NewCFrame(-2863, 165, -4043),
	})

	SetStatus("Oil Rig", "Collecting oil..")

	wait(20)

	ChainTP({
		NewCFrame(-2864, 165, -4083), 
		NewCFrame(-2893, 165, -4084) 
	})

	if not Player.Folder:FindFirstChild("Key") then
		SetStatus("Oil Rig", "Collecting key..")
		SmallTP(NewCFrame(-2900, 165, -4049))
		repeat 
			Workspace.OilRig.KeyCardTable.KeyCardGiver.OnPressedRemote:FireServer(false)
			wait(1.5)
			Workspace.OilRig.KeyCardTable.KeyCardGiver.OnPressedRemote:FireServer(true)
		until Player.Folder:FindFirstChild("Key")
		SmallTP(NewCFrame(-2893, 165, -4084))
	end

	SetStatus("Oil Rig",  "Starting robbery..")
	ChainTP({
		NewCFrame(-2909, 168, -4082), 
		NewCFrame(-2914, 164, -4105), 
		NewCFrame(-2913, 152, -4111), 
		NewCFrame(-2913, 152, -4130) 
	})

	SetStatus("Oil Rig", "Collecting oil..")
	wait(20)

	SetStatus("Oil Rig", "Exiting robbery..")
	ChainTP({
		NewCFrame(-2914, 152, -4110), 
		NewCFrame(-2904, 152, -4110), 
		NewCFrame(-2905, 138, -4066),
		NewCFrame(-2844, 135, -4067),
		NewCFrame(-2786, 135, -4067)
	})

	EnterVehicle()
	SetStatus("Oil Rig", "Teleporting to port..")
	wait(1)
	VehicleTP(CFrame.new(-509, 28, 2119))

	SetStatus("Oil Rig", "Selling..")
	repeat task.wait() until not RobberyMoneyGui.Enabled
	SetStatus("Oil Rig", "Robbery Complete!")
    task.wait(0.45)
    OnRobbery("Oil Rig")
    BringPlatform()
end

local function RobDonutStore()
    if not Robbery.Donut.Enabled then return end Escape("Donut Store")
    SetStatus("Donut Store", "Teleporting to robbery..")
    VehicleTP(CFrame.new(84, 34, -1605))
    task.wait(0.5)

    SetStatus("Donut Store", "Starting robbery..")
    for _, spec in pairs(Specs) do
        if spec.Name == "Rob" and DistanceXZ(Root.Position, spec.Part.Position) < 100 then
            Robbery.Donut.Robbed = true
            spec:Callback(false)
            task.wait(10)
            spec:Callback(true)
        end
    end

    SetStatus("Donut Store", "Robbery Complete!")
    task.wait(0.45)
    OnRobbery("Donut Store")
    BringPlatform()
end

local function RobGasStation()
    if not Settings.Enabled then return end
    if not Robbery.Gas.Enabled then return end Escape("Gas Station")
    SetStatus("Gas Station", "Teleporting to robbery..")
    VehicleTP(CFrame.new(-1594, 34, 710))
    task.wait(0.5)

    SetStatus("Gas Station", "Starting robbery..")
    for _, spec in pairs(Specs) do
        if spec.Name == "Rob" and DistanceXZ(Root.Position, spec.Part.Position) < 100 then
            Robbery.Gas.Robbed = true
            spec:Callback(false)
            task.wait(10)
            spec:Callback(true)
        end
    end

    SetStatus("Gas Station", "Robbery Complete!")
	
    task.wait(0.45)
    OnRobbery("Gas Station")
    BringPlatform()
end

local function RobAirdrop()
    if not Robbery.Airdrop.Enabled then return end Escape("Airdrop")
	local Drop = GetClosestAirdrop()
    if not Drop then return end

	SetStatus("Airdrop", "Teleporting to robbery..")
    VehicleTP(Drop.PrimaryPart.CFrame * CFrame.new(10, 10, 0), true)
    if not Drop then return end

    Root.CFrame = Drop.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
    spawn(function()
        while Drop:FindFirstChild("NPCs") == nil do
            task.wait(0.5)
        end
        Drop:FindFirstChild("NPCs"):Destroy()
    end)

	SetStatus("Airdrop", "Starting robbery..")

    repeat
        Drop.BriefcasePress:FireServer()
        Drop.BriefcaseCollect:FireServer()
		task.wait()
        Root.CFrame = Drop.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
    until Drop:GetAttribute("BriefcaseCollected") == true or not Drop.PrimaryPart or not Character or not Root or AreCopsClose(50) or IsArrested()

    Drop.Name = ""

    if IsArrested() then
        return error()
    end
    if not AreCopsClose(50) then
        task.wait(0.75)
        SetStatus("Airdrop", "Collecting cash..")

        for i = 1, 3 do
            for _, spec in pairs(Specs) do
                if spec.Name:sub(1, 9) == "Collect $" then
                    spec:Callback(true)
                end
            end

            task.wait(0.25)
        end
    end

    SetStatus("Airdrop", "Robbery Complete!")
	EnterVehicle()
    task.wait(0.45)
    OnRobbery("Airdrop")
    BringPlatform()
end

-------------------->  Robbery Checks  <<--------------------

function CheckPlaneCrates()
    if not Workspace:FindFirstChild("Plane") or not workspace.Plane:FindFirstChild("Crates") then
        return false
    end

    for i,v in pairs(PlaneCrates) do
        if Workspace.Plane.Crates:FindFirstChild(v) and Workspace.Plane.Crates:FindFirstChild(v)["1"].Transparency < 1 then
            return true
        end
    end

    return false
end

function AreHelisAvb()
	local Vehicles = Workspace.Vehicles:GetChildren()
	local Helis = {}

	for i, v in pairs(Vehicles) do
		if v.Name == "Heli" and v.PrimaryPart and v.Seat and not v.Seat.Player.Value and not Raycast(v.PrimaryPart.Position, Vector3.new(0, 1000, 0)) then 
			table.insert(Helis, v)
		end
	end

	if #Helis == 0 then
		if not (GetVehiclePacket() and GetVehiclePacket().Name == "Heli") then
			return false
		end
	end

	return true
end

function IsPlaneOutOfMap()
    local Plane = workspace:FindFirstChild("Plane")
    return not Plane or Plane.PrimaryPart.Position.Z < -5000
end

function GetCargoTrainBoxCar()
    for i,v in pairs(CargoTrainBoxCars) do
        if Trains:FindFirstChild(v) then
            return Trains:FindFirstChild(v)
        end
    end
end

function IsCargoTrainOutOfMap(Gold)
    return Gold.Position.X < -1663 and Gold.Position.Z > 258
end

local function CheckBank()
	return Robbery.Bank.Open and not Robbery.Bank.Robbed
end

local function CheckCraterBank()
	return Robbery.CraterBank.Open and not Robbery.CraterBank.Robbed
end

local function CheckJewelry()
	return Robbery.Jewelry.Open and not Robbery.Jewelry.Robbed
end

local function CheckMuseum()
	return Robbery.Museum.Open and not Robbery.Museum.Robbed
end

local function CheckPowerPlant()
	return Robbery.PowerPlant.Open and not Robbery.PowerPlant.Robbed
end

local function CheckCargoTrain()
	return Robbery.CargoTrain.Open and not Robbery.CargoTrain.Robbed and GetCargoTrainBoxCar() and not IsCargoTrainOutOfMap(GetCargoTrainBoxCar().Model.Rob.Gold)
end

local function CheckPassengerTrain()
	return Robbery.PassengerTrain.Open and not Robbery.PassengerTrain.Robbed
end

local function CheckCargoPlane()
	return Robbery.CargoPlane.Open and not Robbery.CargoPlane.Robbed and Workspace:FindFirstChild("Plane") and Workspace.Plane.PrimaryPart.Position.Y > 200 and CheckPlaneCrates() and not IsPlaneOutOfMap()
end

local function CheckCargoShip()
	return Robbery.CargoShip.Open and not Robbery.CargoShip.Robbed and AreHelisAvb()
end

local function CheckTomb()
	return Robbery.Tomb.Open and not Robbery.Tomb.Robbed
end

-- local function CheckCasino()
-- 	return Robbery.Casino.Open and not Robbery.Casino.Robbed
-- end

local function CheckMansion()
	return Robbery.Mansion.Open and not Robbery.Mansion.Robbed and Backpack:FindFirstChild("MansionInvite")
end

local function CheckOilRig()
	return Robbery.OilRig.Open and not Robbery.OilRig.Robbed
end

local function CheckDonutStore()
	return Robbery.Donut.Open and not Robbery.Donut.Robbed
end

local function CheckGasStation()
	return Robbery.Gas.Open and not Robbery.Gas.Robbed
end

local function CheckAirdrop()
	return GetClosestAirdrop()
end

-------------------->>  Configure Functions  <<--------------------

Robbery.Bank.Callback           = RobBank
Robbery.CraterBank.Callback     = RobCraterBank
Robbery.Jewelry.Callback        = RobJewelryStore
Robbery.Museum.Callback         = RobMuseum
Robbery.PowerPlant.Callback     = RobPowerPlant
Robbery.CargoTrain.Callback     = RobCargoTrain
Robbery.PassengerTrain.Callback = RobPassengerTrain
Robbery.CargoPlane.Callback     = RobCargoPlane
Robbery.CargoShip.Callback      = RobCargoShip
-- Robbery.Tomb.Callback           = function() end
-- Robbery.Casino.Callback         = RobCasino
Robbery.Mansion.Callback        = RobMansion
Robbery.OilRig.Callback         = RobOilRig
Robbery.Donut.Callback          = RobDonutStore
Robbery.Gas.Callback            = RobGasStation
Robbery.Airdrop.Callback        = RobAirdrop

Robbery.Bank.Check              = CheckBank
Robbery.CraterBank.Check        = CheckCraterBank
Robbery.Jewelry.Check           = CheckJewelry
Robbery.Museum.Check            = CheckMuseum
Robbery.PowerPlant.Check        = CheckPowerPlant
Robbery.CargoTrain.Check        = CheckCargoTrain
Robbery.PassengerTrain.Check    = CheckPassengerTrain
Robbery.CargoPlane.Check        = CheckCargoPlane
Robbery.CargoShip.Check         = CheckCargoShip
Robbery.Tomb.Check              = CheckTomb
-- Robbery.Casino.Check            = CheckCasino
Robbery.Mansion.Check           = CheckMansion
Robbery.OilRig.Check            = CheckOilRig
Robbery.Donut.Check             = CheckDonutStore
Robbery.Gas.Check               = CheckGasStation
Robbery.Airdrop.Check           = CheckAirdrop

Robbery.Donut.Priority          = 1
Robbery.Gas.Priority            = 2
Robbery.Jewelry.Priority        = 3
Robbery.PassengerTrain.Priority = 4
Robbery.CargoTrain.Priority     = 5
Robbery.Museum.Priority         = 6
Robbery.CargoPlane.Priority     = 7
Robbery.Bank.Priority           = 8
Robbery.CraterBank.Priority     = 9
Robbery.Airdrop.Priority        = 10
Robbery.PowerPlant.Priority     = 11
-- Robbery.Casino.Priority         = 100
Robbery.OilRig.Priority         = 13
Robbery.Tomb.Priority           = 14
Robbery.Mansion.Priority        = 15
Robbery.CargoShip.Priority      = 16

local function ReorderPriority(type)
    if type == "Highest" then
        Robbery.Donut.Priority          = 1
		Robbery.Gas.Priority            = 2
		Robbery.Jewelry.Priority        = 3
		Robbery.PassengerTrain.Priority = 4
		Robbery.CargoTrain.Priority     = 5
		Robbery.Museum.Priority         = 6
		Robbery.CargoPlane.Priority     = 7
		Robbery.Bank.Priority           = 8
		Robbery.CraterBank.Priority     = 9
		Robbery.Airdrop.Priority        = 10
		Robbery.PowerPlant.Priority     = 11
		-- Robbery.Casino.Priority         = 100
		Robbery.OilRig.Priority         = 13
		Robbery.Tomb.Priority           = 14
		Robbery.Mansion.Priority        = 15
		Robbery.CargoShip.Priority      = 16
    elseif type == "Lowest" then
        Robbery.Donut.Priority = 16
        Robbery.Gas.Priority = 15
        Robbery.Jewelry.Priority = 14
        Robbery.PassengerTrain.Priority = 13
        Robbery.CargoTrain.Priority = 12
        Robbery.Museum.Priority = 11
        Robbery.CargoPlane.Priority = 10
        Robbery.Bank.Priority = 9
        Robbery.CraterBank.Priority = 8
		Robbery.Airdrop.Priority = 7
        Robbery.PowerPlant.Priority = 6
        -- Robbery.Casino.Priority = 100
        Robbery.OilRig.Priority = 4
        Robbery.Tomb.Priority = 3
        Robbery.Mansion.Priority = 2
        Robbery.CargoShip.Priority = 1
    elseif type == "Grouped" then
        -- Group A (Bank, jewelry, museum)
        Robbery.Bank.Priority = 16
        Robbery.Jewelry.Priority = 15
        Robbery.Museum.Priority = 14

        -- Group B (powerplant, cargo plane &, passenger train)
        Robbery.PowerPlant.Priority = 13
        Robbery.CargoPlane.Priority = 12
        Robbery.PassengerTrain.Priority = 11
        
        -- Group C (crater bank, casino, oil rig)
        Robbery.CraterBank.Priority = 10
        -- Robbery.Casino.Priority = 100
        Robbery.OilRig.Priority = 8

        -- Group D (Cargo train, cargo ship, tomb)
        Robbery.CargoShip.Priority = 7
        Robbery.Tomb.Priority = 6
        Robbery.CargoTrain.Priority = 5

        -- Group ? (Gas station, donut store, mansion, airdrop)
        Robbery.Mansion.Priority = 4
		Robbery.Airdrop.Priority = 3
        Robbery.Gas.Priority = 2
        Robbery.Donut.Priority = 1
    end
end

------------------------>>  Robbery Prioritys  <<--------------------

local function GetRobberyPriority()
	local Selected, SelectedName = nil
    for i,v in pairs(Robbery) do
        if v.Check and v.Check() and v.Enabled and v.Priority and v.Callback then
            local Win = false

            if Selected then
                Win = v.Priority and v.Priority > Selected.Priority
            else
                Win = true
            end
            
            if Win then
                Selected, SelectedName = v, i
            end
        end
    end

    return Selected, SelectedName
end

local function CheckAvailable()
    for i,v in pairs(Robbery) do
        if v.Enabled and v.Check and v.Check() and not v.Robbed then
			print("open" ..i)
            return true
        end
    end
    return false
end

-------------------->>  Server Hopper  <<--------------------

function SwitchServer(SmallServer)
	AutoRobbing = false
	SwitchingServer = true

	queue_on_teleport([[
		print("qyueyue")
		getgenv().ServerHopped = true
		getgenv().StartingMoney = ]] .. getgenv().StartingMoney .. [[
		getgenv().StartingTime = ]] .. getgenv().StartingTime .. [[
		print("eyeqy:")
	]])
		
	while true do
		pcall(function()
			local AvailableServers = {}
			local Servers          = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/606849621/servers/Public?limit=100"..(SmallServer and "&sortOrder=Asc" or "")))
			while #AvailableServers < 20 and Servers.nextPageCursor do
				for _, v in pairs(Servers.data) do
					if v.maxPlayers and v.playing then
						if #AvailableServers >= 20 then
							break
						end
						if v.maxPlayers - v.playing > 3 then
							AvailableServers[#AvailableServers + 1] = v.id
						end
					end
				end
				Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/606849621/servers/Public?limit=100&cursor="..Servers.nextPageCursor..(SmallServer and "&sortOrder=Asc" or "")))
				wait()
			end
			TeleportService:TeleportToPlaceInstance(606849621, AvailableServers[math.random(1, #AvailableServers)])
			wait(15)
		end, "SwitchServer")
		wait(2)
	end
end

-------------------->>  Auto Rob  <<--------------------

local function Pcall(func, name)
    local Success, Error = pcall(func)
    if not Success then
		print(Error)
        -- warn("Error in "..name..": ".. debug.traceback())
    end
end

function ToggleAutorob(bool)
	Settings.Enabled = bool
	if not bool then
		return
	end

	if AutoRobbing then
		WaitUntil(function()
			return not AutoRobbing
		end)
	end

	AutoRobbing = true

	if not getgenv().ServerHopped then
		getgenv().StartingMoney         = Leaderstats:WaitForChild("Money").Value
		getgenv().StartingTime          = tick()
	end
	local DotCount                  = 0

	ForEvery(1, function(stop)
		if Settings.Enabled then
			SetStats(Leaderstats:WaitForChild("Money").Value - getgenv().StartingMoney, tick() - getgenv().StartingTime)
		else
			SetStats(0, 0)
			stop()
		end
	end)
	

	while Settings.Enabled do

		if CheckAvailable() then
			-- if BagVisible() then
			-- 	local MoneyGuiMessage = PlayerGui.RobberyMoneyGui.Container.Message.Text:lower()
			-- 	local BagType = (MoneyGuiMessage:match("criminal base") and "Jewelry") or (MoneyGuiMessage:match("cargo port") and "CargoPlane") or nil

			-- 	Pcall(function()
			-- 		AttemptSell(BagType)
			-- 	end, "SellExistingBag")

			-- 	Cooldown()
			-- end

			local Winner, WinnerName = GetRobberyPriority()

			if not Winner then
				wait()
				continue
			end

			Pcall(Winner.Callback, WinnerName)
			Cooldown()

			-- if BagVisible() then
			-- 	local MoneyGuiMessage = PlayerGui.RobberyMoneyGui.Container.Message.Text:lower()
			-- 	local BagType = (MoneyGuiMessage:match("criminal base") and "Jewelry") or (MoneyGuiMessage:match("cargo port") and "CargoPlane") or nil

			-- 	Pcall(function()
			-- 		AttemptSell(BagType)
			-- 	end, "SellExistingBag")

			--    Cooldown()
			-- end
		else
			if Settings.ServerHop then
				SetStatus("New game", "Server Hopping..")
				SwitchServer()
			end

			Pcall(function()
				if tostring(Player.Team) ~= "Criminal" then
					Escape()
				end

				WaitUntil(function()
					SetStatus("Safe Platform", "Waiting for robberys" .. string.rep(".", DotCount % 3))
					DotCount = DotCount + 1
					wait()
					return CheckAvailable() or not Settings.Enabled
				end, nil, 0.5)
			end, "Safety")
		end

		wait(0.1)
	end

	AutoRobbing = false
	SetStats(0, 0)
    SetStatus("None", "Auto Rob Disabled.")
end


ForEvery(5, function(stop)
	-- save settings
	Pcall(function()
		SaveFile("AutoRobSettings.json",  HttpService:JSONEncode(Settings))
	end, "SaveSettings")
end)

-------------------->>  Prestart Autorob  <<--------------------

if Settings.Enabled then
	spawn(ToggleAutorob, true)
end

-------------------->>  UI Library  <<--------------------

local Gui
Gui = {
	Data = {
		SetInteractionsEnabled = function(Value)
			Gui.InteractionsEnabled = Value or false
		end,
		SetTheme = function(t1,t2)
			Gui.Theme = t1; Gui.Theme2 = t2
		end,
	},
	Theme = nil,
	Theme2 = nil,
	InteractionsEnabled = true,
	FocusedDropdown = nil
}

do
	Gui.Flags = {}

	local Mouse = Player:GetMouse()

	local Signal = {}
	Signal.__index = Signal
	Signal.ClassName = "Signal"

	-- Constructor
	function Signal.new()
		return setmetatable(
			{
				_bindable = Instance.new("BindableEvent"),
				_args = nil,
				_argCount = nil -- To stay true to _args, even when some indexes are nil
			},
			Signal
		)
	end

	function Signal:Fire(...)
		-- I use this method of arguments because when passing it in a bindable event, it creates a deep copy which makes it slower
		self._args = {...}
		self._argCount = select("#", ...)
		self._bindable:Fire()
	end

	function Signal:fire(...)
		return self:Fire(...)
	end

	function Signal:Connect(handler)
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end
		return self._bindable.Event:Connect(
			function()
				handler(unpack(self._args, 1, self._argCount))
			end
		)
	end

	function Signal:connect(...)
		return self:Connect(...)
	end

	function Signal:Wait()
		self._bindableEvent.Event:Wait()
		assert(self._argData, "Missing argument data, likely due to :TweenSize/Position corrupting.")
		return unpack(self._args, 1, self._argCount)
	end

	function Signal:wait()
		return self:Wait()
	end

	function Signal:Remove()
		if self._bindable then
			self._bindable:Remove()
			self._bindable = nil
		end
		self._args = nil
		self._argCount = nil
		setmetatable(self, nil)
	end

	function Signal:Remove()
		return self:Remove()
	end

	local function HasProperty(Instance, Property)
		return pcall(
			function()
				local A = Instance[Property]
			end
		)
	end

	local function dragify(Frame)
		local dragToggle = nil
		local dragSpeed = .25
		local dragInput = nil
		local dragStart = nil
		local dragPos = nil
		local startPos = nil

		local function updateInput(input)
			local Delta = input.Position - dragStart
			local Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
			game:GetService("TweenService"):Create(Frame, TweenInfo.new(.25), {Position = Position}):Play()
		end

		Frame.InputBegan:Connect(
			function(input)
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or
						input.UserInputType == Enum.UserInputType.Touch)
				then
					dragToggle = true
					dragStart = input.Position
					startPos = Frame.Position
					input.Changed:Connect(
						function()
							if (input.UserInputState == Enum.UserInputState.End) then
								dragToggle = false
							end
						end
					)
				end
			end
		)

		Frame.InputChanged:Connect(
			function(input)
				if
					(input.UserInputType == Enum.UserInputType.MouseMovement or
						input.UserInputType == Enum.UserInputType.Touch)
				then
					dragInput = input
				end
			end
		)

		game:GetService("UserInputService").InputChanged:Connect(
		function(input)
			if (input == dragInput and dragToggle) then
				updateInput(input)
			end
		end
		)
	end

	Gui.CreateGui = function(self, AssignedGuiName, GuiSet)
		if type(GuiSet) ~= "table" then
			GuiSet = {}
		end
		GuiSet = GuiSet or {}
		GuiSet.Theme = GuiSet.Theme or Color3.fromRGB(255, 65, 68)
		GuiSet.Theme2 = GuiSet.Theme2 or Color3.fromRGB(66, 17, 18)
		Gui.Data.SetTheme(GuiSet.Theme,GuiSet.Theme2)
		local CreatedGui = {}

		local SpringGui = Instance.new("ScreenGui")
		SpringGui.Name = "SpringGui"
		SpringGui.DisplayOrder = 1

		local function SetHui()
			SpringGui.Parent = gethui()
		end

		while not pcall(SetHui) do
			wait(0.01)
		end

		CreatedGui.Toggle = function()
			SpringGui.Enabled = not SpringGui.Enabled
		end

		local Main = Instance.new("Frame")
		Main.Name = "Main"
		Main.AnchorPoint = Vector2.new(0.5, 0.5)
		Main.ZIndex = 0
		Main.Size = UDim2.new(0, 350, 0, 375)
		Main.BorderColor3 = Color3.fromRGB(195, 195, 195)
		Main.BackgroundTransparency = 1
		Main.Position = UDim2.new(0.5, 0, 0.5, 0)
		Main.Active = true
		Main.BorderSizePixel = 0
		Main.BackgroundColor3 = Color3.fromRGB(26, 32, 40)
		Main.Parent = SpringGui

		local Main1 = Instance.new("Frame")
		Main1.Name = "Main"
		Main1.ZIndex = 0
		Main1.Size = UDim2.new(1, -2, 1, -10)
		Main1.Position = UDim2.new(0, 1, 0, 9)
		Main1.BorderSizePixel = 0
		Main1.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		Main1.Parent = Main

		local UICorner = Instance.new("UICorner")
		UICorner.Parent = Main1

		local Top = Instance.new("Frame")
		Top.Name = "Top"
		Top.AnchorPoint = Vector2.new(0.5, 0)
		Top.Size = UDim2.new(1, -20, 0, 30)
		Top.Position = UDim2.new(0.5, 0, 0, 34)
		Top.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
		Top.Parent = Main1

		local UICorner1 = Instance.new("UICorner")
		UICorner1.CornerRadius = UDim.new(0, 6)
		UICorner1.Parent = Top

		local Frame = Instance.new("Frame")
		Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame.Size = UDim2.new(1, -2, 1, -2)
		Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
		Frame.Parent = Top

		local UICorner2 = Instance.new("UICorner")
		UICorner2.CornerRadius = UDim.new(0, 6)
		UICorner2.Parent = Frame

		local ScrollingFrame = Instance.new("ScrollingFrame")
		ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
		ScrollingFrame.BackgroundTransparency = 1
		ScrollingFrame.Active = true
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.Parent = Frame

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 3)
		UIListLayout.Parent = ScrollingFrame
		game:GetService("RunService").Heartbeat:Connect(function()
			ScrollingFrame.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X + 8, 0)
		end
		)

		local Content = Instance.new("Frame")
		Content.Name = "Content"
		Content.AnchorPoint = Vector2.new(0.5, 0)
		Content.Size = UDim2.new(1, -20, 1, -78)
		Content.Position = UDim2.new(0.5, 0, 0, 68)
		Content.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		Content.Parent = Main1

		local UICorner5 = Instance.new("UICorner")
		UICorner5.CornerRadius = UDim.new(0, 6)
		UICorner5.Parent = Content

		local Inner = Instance.new("Frame")
		Inner.Name = "Inner"
		Inner.AnchorPoint = Vector2.new(0.5, 0.5)
		Inner.Size = UDim2.new(1, -2, 1, -2)
		Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
		Inner.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		Inner.Parent = Content

		local UICorner6 = Instance.new("UICorner")
		UICorner6.CornerRadius = UDim.new(0, 6)
		UICorner6.Parent = Inner

		CreatedGui.CreateTab = function(self, Name)
			Name = Name or "..."
			local CreatedTab = {}
			local UIPadding = Instance.new("UIPadding")
			UIPadding.PaddingTop = UDim.new(0, 3)
			UIPadding.PaddingBottom = UDim.new(0, 3)
			UIPadding.PaddingLeft = UDim.new(0, 3)
			UIPadding.PaddingRight = UDim.new(0, 3)
			UIPadding.Parent = ScrollingFrame

			local Tab2 = Instance.new("ScrollingFrame")
			Tab2.Name = Name
			Tab2.AnchorPoint = Vector2.new(0.5, 0.5)
			Tab2.Size = UDim2.new(1, -12, 1, -12)
			Tab2.BackgroundTransparency = 1
			Tab2.Position = UDim2.new(0.5, 0, 0.5, 0)
			Tab2.Active = true
			Tab2.Visible = false
			Tab2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			Tab2.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
			Tab2.ScrollBarImageTransparency = 1
			Tab2.ScrollBarThickness = 0
			Tab2.Parent = Inner

			local Tab = Instance.new("TextButton")
			Tab.Name = Name
			Tab.Size = UDim2.new(0, 50, 1, 0)
			Tab.BackgroundTransparency = 0.975
			Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Tab.FontSize = Enum.FontSize.Size14
			Tab.TextSize = 14
			Tab.TextColor3 = Gui.Theme2
			Tab.Text = Name
			Tab.Font = Enum.Font.SourceSans
			Tab.Parent = ScrollingFrame
			Tab.MouseButton1Down:Connect(
				function()
					CreatedTab:SetDefault()
				end
			)
			game:GetService"RunService".Heartbeat:Connect(
				function()
					Tab.Size = UDim2.new(0, Tab.TextBounds.X + 16, 1, 0)
				end
			)

			local Border = Instance.new("Frame")
			Border.Name = "Border"
			Border.ZIndex = -1
			Border.Size = UDim2.new(1, 2, 1, 2)
			Border.Position = UDim2.fromScale(0.5,0.5)
			Border.AnchorPoint = Vector2.new(0.5,0.5)
			Border.BorderSizePixel = 0
			Border.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Border.Parent = Tab

			local UICorner3 = Instance.new("UICorner")
			UICorner3.CornerRadius = UDim.new(0, 6)
			UICorner3.Parent = Tab

			local UICorner32 = Instance.new("UICorner")
			UICorner32.CornerRadius = UDim.new(0, 6)
			UICorner32.Parent = Border

			local Left = Instance.new("Frame")
			Left.Name = "Left"
			Left.Size = UDim2.new(0.5, -2, 1, 0)
			Left.BackgroundTransparency = 1
			Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Left.Parent = Tab2

			local UIListLayout1 = Instance.new("UIListLayout")
			UIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout1.Padding = UDim.new(0, 3)
			UIListLayout1.Parent = Left

			local Right = Instance.new("Frame")
			Right.Name = "Right"
			Right.AnchorPoint = Vector2.new(1, 0)
			Right.Size = UDim2.new(0.5, -2, 1, 0)
			Right.BackgroundTransparency = 1
			Right.Position = UDim2.new(1, 0, 0, 0)
			Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Right.Parent = Tab2

			local UIListLayout6 = Instance.new("UIListLayout")
			UIListLayout6.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout6.Padding = UDim.new(0, 3)
			UIListLayout6.Parent = Right

			game:GetService"RunService".Heartbeat:Connect(function()
				Tab2.CanvasSize = UDim2.fromOffset(0, UIListLayout1.AbsoluteContentSize.Y + 4 >= UIListLayout6.AbsoluteContentSize.Y and UIListLayout1.AbsoluteContentSize.Y + 4 or UIListLayout6.AbsoluteContentSize.Y + 4)
			end)

			game:GetService"RunService".Heartbeat:Connect(function()
				Tab2.CanvasSize = UDim2.fromOffset(0, UIListLayout1.AbsoluteContentSize.Y + 4 >= UIListLayout6.AbsoluteContentSize.Y and UIListLayout1.AbsoluteContentSize.Y + 4 or UIListLayout6.AbsoluteContentSize.Y + 4)
			end)

			CreatedTab.SetDefault = function(self)
				Tab.BackgroundTransparency = 0.95
				Tab.TextColor3 = Gui.Theme
				table.foreachi(
					Inner:GetChildren(),
					function(i, v)
						if v ~= Tab2 and v:IsA("ScrollingFrame") then
							v.Visible = false
						end
					end
				)
				table.foreachi(
					ScrollingFrame:GetChildren(),
					function(i, v)
						if v ~= Tab and v:IsA("TextButton") then
							v.BackgroundTransparency = 0.975
							v.TextColor3 = Gui.Theme2
						end
					end
				)
				Tab2.Visible = true
				return CreatedTab
			end

			CreatedTab.CreateSection = function(self, SecetionName, Side)
				Side = Side and Side:lower() or "left"
				local CreatedSection = {}
				local Section = Instance.new("Frame")
				Section.Name = "Section"
				Section.Size = UDim2.new(1, 0, 0, 116)
				Section.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Section.Parent = Side == "left" and Left or Side == "right" and Right or Left

				local Inner1 = Instance.new("Frame")
				Inner1.Name = "Inner"
				Inner1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inner1.Size = UDim2.new(1, -2, 1, -2)
				Inner1.Position = UDim2.new(0.5, 0, 0.5, 0)
				Inner1.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Inner1.Parent = Section

				local UICorner7 = Instance.new("UICorner")
				UICorner7.CornerRadius = UDim.new(0, 4)
				UICorner7.Parent = Inner1

				local SectionName = Instance.new("TextLabel")
				SectionName.Name = "SectionName"
				SectionName.AnchorPoint = Vector2.new(1, 0)
				SectionName.Size = UDim2.new(1, -8, 0, 24)
				SectionName.BackgroundTransparency = 1
				SectionName.Position = UDim2.new(1, 0, 0, 8)
				SectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SectionName.FontSize = Enum.FontSize.Size14
				SectionName.TextSize = 14
				SectionName.TextColor3 = Gui.Theme
				SectionName.Text = SecetionName or "Section"
				SectionName.TextYAlignment = Enum.TextYAlignment.Top
				SectionName.TextWrapped = true
				SectionName.Font = Enum.Font.SourceSansBold
				SectionName.TextWrap = true
				SectionName.TextXAlignment = Enum.TextXAlignment.Left
				SectionName.Parent = Inner1

				local SectionContent = Instance.new("Frame")
				SectionContent.Name = "SectionContent"
				SectionContent.AnchorPoint = Vector2.new(0.5, 1)
				SectionContent.Size = UDim2.new(1, -12, 1, -40)
				SectionContent.BackgroundTransparency = 1
				SectionContent.Position = UDim2.new(0.5, 0, 1, -6)
				SectionContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SectionContent.Parent = Inner1

				local UIListLayout2 = Instance.new("UIListLayout")
				UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout2.Padding = UDim.new(0, 3)
				UIListLayout2.Parent = SectionContent
				game:GetService"RunService".Heartbeat:Connect(
					function()
						Section.Size =
							UDim2.new(1, 0, 0, UIListLayout2.AbsoluteContentSize.Y + 20 + SectionName.AbsoluteSize.Y)
					end
				)

				CreatedSection.CreateButton = function(self, Name, Callback)
					Callback = Callback or function()
					end
					local Button = Instance.new("Frame")
					Button.Name = "Button"
					Button.Size = UDim2.new(1, 0, 0, 23)
					Button.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Button.Parent = SectionContent
					Button.ClipsDescendants = true

					local UICorner8 = Instance.new("UICorner")
					UICorner8.CornerRadius = UDim.new(0, 4)
					UICorner8.Parent = Button

					local TextButton = Instance.new("TextButton")
					TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
					TextButton.Size = UDim2.new(1, -2, 1, -2)
					TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
					TextButton.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					TextButton.AutoButtonColor = false
					TextButton.FontSize = Enum.FontSize.Size9
					TextButton.Text = Name or "Button"
					TextButton.TextSize = 12
					TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					TextButton.TextWrapped = true
					TextButton.Font = Enum.Font.SourceSans
					TextButton.Parent = Button
					TextButton.ClipsDescendants = true

					local Sample = Instance.new("ImageLabel")
					Sample.Name = "Sample"
					Sample.BackgroundTransparency = 1
					Sample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Sample.ImageTransparency = 0.65
					Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
					Sample.Parent = TextButton

					TextButton.MouseEnter:Connect(
						function()
							game:GetService("TweenService"):Create(
							TextButton,
							TweenInfo.new(0.22),
							{
								TextColor3 = Gui.Theme
							}
							):Play()
						end
					)
					TextButton.MouseLeave:Connect(
						function()
							game:GetService("TweenService"):Create(
							TextButton,
							TweenInfo.new(0.22),
							{
								TextColor3 = Color3.fromRGB(255, 255, 255)
							}
							):Play()
						end
					)

					TextButton.MouseButton1Down:Connect(
						function()
							if Gui.InteractionsEnabled ~= true then
								return
							end
							spawn(
								function()
									game:GetService("TweenService"):Create(
									TextButton,
									TweenInfo.new(0.1),
									{
										TextSize = 8
									}
									):Play()
									wait(0.1)
									game:GetService("TweenService"):Create(
									TextButton,
									TweenInfo.new(0.1),
									{
										TextSize = 12
									}
									):Play()

									local c = Sample:Clone()
									c.Parent = Button
									c.Position = UDim2.new(0.5, 0, 0.5, 0)
									local len, size = 0.75, nil
									if Button.AbsoluteSize.X >= Button.AbsoluteSize.Y then
										size = (Button.AbsoluteSize.X * 1.5)
									else
										size = (Button.AbsoluteSize.Y * 1.5)
									end
									c:TweenSizeAndPosition(
										UDim2.new(0, size, 0, size),
										UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)),
										"Out",
										"Quad",
										len,
										true,
										nil
									)
									for i = 1, 10 do
										c.ImageTransparency = c.ImageTransparency + 0.05
										wait(len / 12)
									end
									c:Remove()
								end
							)
							Callback()
						end
					)

					local UICorner9 = Instance.new("UICorner")
					UICorner9.CornerRadius = UDim.new(0, 4)
					UICorner9.Parent = TextButton
				end

				CreatedSection.CreateTextbox = function(self, Name, Callback, Settings)
					Name = Name or "..."
					Callback = Callback or function()
					end
					Settings = Settings or {}
					Settings.RememberLastText = Settings.RememberLastText == nil and true or Settings.RememberLastText

					local PreviousText = Settings.Text or "..."

					local Textbox = Instance.new("Frame")
					Textbox.Name = "Textbox"
					Textbox.Size = UDim2.new(1, 0, 0, 23)
					Textbox.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Textbox.Parent = SectionContent

					local UICorner = Instance.new("UICorner")
					UICorner.CornerRadius = UDim.new(0, 4)
					UICorner.Parent = Textbox

					local Inner = Instance.new("Frame")
					Inner.Name = "Inner"
					Inner.AnchorPoint = Vector2.new(0.5, 0.5)
					Inner.Size = UDim2.new(1, -2, 1, -2)
					Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
					Inner.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
					Inner.Parent = Textbox

					local UICorner1 = Instance.new("UICorner")
					UICorner1.CornerRadius = UDim.new(0, 4)
					UICorner1.Parent = Inner

					local TextBox = Instance.new("TextBox")
					TextBox.AnchorPoint = Vector2.new(1, 0)
					TextBox.Size = UDim2.new(1, -6, 1, 0)
					TextBox.ClipsDescendants = true
					TextBox.BackgroundTransparency = 1
					TextBox.Position = UDim2.new(1, 0, 0, 0)
					TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextBox.FontSize = Enum.FontSize.Size10
					TextBox.TextStrokeTransparency = 0.75
					TextBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
					TextBox.TextSize = 12
					TextBox.TextColor3 = Gui.Theme
					TextBox.Text = Settings.Text or "..."
					TextBox.PlaceholderText = Settings.Text
					TextBox.CursorPosition = -1
					TextBox.Font = Enum.Font.Code
					TextBox.TextXAlignment = Enum.TextXAlignment.Left
					TextBox.Parent = Inner
					TextBox.Focused:Connect(
						function()
							if Gui.InteractionsEnabled ~= true then
								TextBox.TextEditable = false
								return
							else
								TextBox.TextEditable = true
							end
						end
					)
					TextBox.FocusLost:Connect(
						function()
							if TextBox.Text == "" then
								TextBox.Text = PreviousText or "..."
							else
								PreviousText = TextBox.Text
							end
							if TextBox.Text ~= "" then
								Callback(TextBox.Text)
							end
						end
					)
				end

				CreatedSection.CreateToggle = function(self, Name, Callback, Settings)
					Callback = Callback or function()
					end
					Settings = Settings or {}
					Settings.Enabled = Settings.Enabled or false
					if Settings.Flag then
						Gui.Flags[Settings.Flag] = {
							Enabled = false,
							Changed = Signal.new()
						}
					end
					local CreatedToggle = {}
					local Toggle = Instance.new("TextButton")
					Toggle.Name = "Toggle"
					Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
					Toggle.Size = UDim2.new(1, 0, 0, 23)
					Toggle.BackgroundTransparency = 1
					Toggle.Position = UDim2.new(0.5, 0, 0.5, 0)
					Toggle.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					Toggle.AutoButtonColor = false
					Toggle.FontSize = Enum.FontSize.Size9
					Toggle.TextSize = 12
					Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
					Toggle.Text = ""
					Toggle.Font = Enum.Font.SourceSans
					Toggle.Parent = SectionContent

					local Toggle1 = Instance.new("Frame")
					Toggle1.Name = "Toggle"
					Toggle1.Size = UDim2.new(0, 23, 0, 23)
					Toggle1.BackgroundColor3 = Settings.Enabled and Gui.Theme or Color3.fromRGB(37, 37, 37)
					Toggle1.Parent = Toggle

					local UICorner10 = Instance.new("UICorner")
					UICorner10.CornerRadius = UDim.new(0, 4)
					UICorner10.Parent = Toggle1

					local Toggle2 = Instance.new("Frame")
					Toggle2.Name = "Toggle"
					Toggle2.AnchorPoint = Vector2.new(0.5, 0.5)
					Toggle2.Size = UDim2.new(1, -2, 1, -2)
					Toggle2.Position = UDim2.new(0.5, 0, 0.5, 0)
					Toggle2.BackgroundColor3 = Settings.Enabled and Gui.Theme2 or Color3.fromRGB(21, 21, 21)
					Toggle2.Parent = Toggle1

					local ImageLabel = Instance.new("ImageLabel")
					ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel.Size = UDim2.new(1, -4, 1, -4)
					ImageLabel.BackgroundTransparency = 1
					ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
					ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ImageLabel.Image = "rbxassetid://8589545938"
					ImageLabel.ImageTransparency = Settings.Enabled and 0 or 1
					ImageLabel.Parent = Toggle2

					local UICorner11 = Instance.new("UICorner")
					UICorner11.CornerRadius = UDim.new(0, 4)
					UICorner11.Parent = Toggle2

					local TextLabel = Instance.new("TextLabel")
					TextLabel.Size = UDim2.new(1, 0, 1, 0)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Position = UDim2.new(0, 30, 0, 0)
					TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.FontSize = Enum.FontSize.Size10
					TextLabel.TextSize = 12
					TextLabel.TextColor3 = Settings.Enabled and Gui.Theme or Color3.fromRGB(255, 255, 255)
					TextLabel.Text = Name or "Toggle"
					TextLabel.Font = Enum.Font.SourceSans
					TextLabel.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel.Parent = Toggle

					CreatedToggle.Fire = function()
						if getgc ~= nil then
							for i, v in getgc(true) do
								--if v == CreatedToggle then
								--print('found')
								--CreatedToggle = v
								--else
								--end
							end
						end
						if Gui.InteractionsEnabled ~= true then
							return
						end
						Settings.Enabled = not Settings.Enabled
						if Gui.Flags[Settings.Flag] then
							Gui.Flags[Settings.Flag].Enabled = Settings.Enabled
							Gui.Flags[Settings.Flag].Changed:Fire(Settings.Enabled)
						end
						spawn(
							function()
								game:GetService("TweenService"):Create(
								Toggle1,
								TweenInfo.new(0.3),
								{
									BackgroundColor3 = Settings.Enabled and Gui.Theme or Color3.fromRGB(37, 37, 37)
								}
								):Play()
								game:GetService("TweenService"):Create(
								Toggle2,
								TweenInfo.new(0.3),
								{
									BackgroundColor3 = Settings.Enabled and Gui.Theme2 or Color3.fromRGB(21, 21, 21)
								}
								):Play()
								game:GetService("TweenService"):Create(
								ImageLabel,
								TweenInfo.new(0.3),
								{
									ImageTransparency = Settings.Enabled and 0 or 1
								}
								):Play()
								game:GetService("TweenService"):Create(
								TextLabel,
								TweenInfo.new(0.3),
								{
									TextColor3 = Settings.Enabled and Gui.Theme or Color3.fromRGB(255, 255, 255)
								}
								):Play()
							end
						)
						Callback(Settings.Enabled)
					end
					Toggle.MouseButton1Down:Connect(CreatedToggle.Fire)
					return CreatedToggle
				end

				local Line = Instance.new("Frame")
				Line.Name = "Line"
				Line.AnchorPoint = Vector2.new(0.5, 0)
				Line.Size = UDim2.new(1, -8, 0, 1)
				Line.Position = UDim2.new(0.5, 0, 0, 26)
				Line.BorderSizePixel = 0
				Line.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Line.Parent = Inner1

				local UICorner14 = Instance.new("UICorner")
				UICorner14.CornerRadius = UDim.new(0, 4)
				UICorner14.Parent = Section

				CreatedSection.CreateDividor = function(self, Size)
					local Divider = Instance.new("Frame")
					Divider.Name = "Divider"
					Divider.Size = UDim2.new(1, 0, 0, Size or 7)
					Divider.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Divider.Parent = SectionContent

					local UICorner = Instance.new("UICorner")
					UICorner.CornerRadius = UDim.new(0, 4)
					UICorner.Parent = Divider

					local Inner = Instance.new("Frame")
					Inner.Name = "Inner"
					Inner.AnchorPoint = Vector2.new(0.5, 0.5)
					Inner.Size = UDim2.new(1, -2, 1, -2)
					Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
					Inner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					Inner.Parent = Divider

					local UICorner1 = Instance.new("UICorner")
					UICorner1.CornerRadius = UDim.new(0, 4)
					UICorner1.Parent = Inner
				end

				CreatedSection.CreateTextlabel = function(self,FirstText)
					local CreatedTextlabel = {}
					local Text = Instance.new("Frame")
					Text.Name = "Text"
					Text.Size = UDim2.new(1, 0, 0, 26)
					Text.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Text.Parent = SectionContent
					local UICorner = Instance.new("UICorner")
					UICorner.CornerRadius = UDim.new(0, 4)
					UICorner.Parent = Text

					local Inner = Instance.new("Frame")
					Inner.Name = "Inner"
					Inner.AnchorPoint = Vector2.new(0.5, 0.5)
					Inner.Size = UDim2.new(1, -2, 1, -2)
					Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
					Inner.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
					Inner.Parent = Text

					local UICorner1 = Instance.new("UICorner")
					UICorner1.CornerRadius = UDim.new(0, 4)
					UICorner1.Parent = Inner

					local TextLabel = Instance.new("TextLabel")
					TextLabel.AnchorPoint = Vector2.new(0, 0.5)
					TextLabel.Size = UDim2.new(1, -7, 1, 0)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Position = UDim2.new(0, 7, 0.5, 0)
					TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.FontSize = Enum.FontSize.Size10
					TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel.TextSize = 12
					TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.Text = FirstText or "..."
					TextLabel.RichText = true
					TextLabel.Font = Enum.Font.SourceSans
					TextLabel.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel.Parent = Inner
					CreatedTextlabel.Set = function(self,New)
						TextLabel.Text = New or "..."
					end
					CreatedTextlabel.SetColor = function(self,New)
						TextLabel.TextColor3 = New
					end
					return CreatedTextlabel
				end

				CreatedSection.CreateSlider = function(self, Name, Callback, Settings)
					Callback = Callback or function()
					end
					Settings = Settings or {}
					Settings.Min = Settings.Min or 0
					Settings.Max = Settings.Max or 100
					Settings.Value = Settings.Value or 50
					local CreatedSlider = {}
					local Slider = Instance.new("Frame")
					Slider.Name = "Slider"
					Slider.Size = UDim2.new(1, 0, 0, 46)
					Slider.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Slider.Parent = SectionContent

					local UICorner30 = Instance.new("UICorner")
					UICorner30.CornerRadius = UDim.new(0, 4)
					UICorner30.Parent = Slider

					local TextButton10 = Instance.new("TextButton")
					TextButton10.AnchorPoint = Vector2.new(0.5, 0.5)
					TextButton10.Size = UDim2.new(1, -2, 1, -2)
					TextButton10.Position = UDim2.new(0.5, 0, 0.5, 0)
					TextButton10.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					TextButton10.AutoButtonColor = false
					TextButton10.FontSize = Enum.FontSize.Size9
					TextButton10.TextSize = 12
					TextButton10.TextColor3 = Color3.fromRGB(255, 255, 255)
					TextButton10.Text = ""
					TextButton10.Font = Enum.Font.SourceSans
					TextButton10.Parent = Slider

					local UICorner31 = Instance.new("UICorner")
					UICorner31.CornerRadius = UDim.new(0, 4)
					UICorner31.Parent = TextButton10

					local SectionName3 = Instance.new("TextLabel")
					SectionName3.Name = "SectionName"
					SectionName3.AnchorPoint = Vector2.new(1, 0)
					SectionName3.Size = UDim2.new(1, -6, 0, 24)
					SectionName3.BackgroundTransparency = 1
					SectionName3.Position = UDim2.new(1, 0, 0, 6)
					SectionName3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					SectionName3.FontSize = Enum.FontSize.Size10
					SectionName3.TextSize = 12
					SectionName3.TextColor3 = Color3.fromRGB(255, 255, 255)
					SectionName3.Text = Name or "Slider"
					SectionName3.TextYAlignment = Enum.TextYAlignment.Top
					SectionName3.TextWrapped = true
					SectionName3.Font = Enum.Font.SourceSans
					SectionName3.TextWrap = true
					SectionName3.TextXAlignment = Enum.TextXAlignment.Left
					SectionName3.Parent = Slider
					--SectionName3.ZIndex = 2

					local TextLabel = Instance.new("TextLabel")
					TextLabel.AnchorPoint = Vector2.new(1, 0)
					TextLabel.Size = UDim2.new(0, 20, 0, 10)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Position = UDim2.new(1, -6, 0, 6)
					TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.FontSize = Enum.FontSize.Size9
					TextLabel.TextYAlignment = Enum.TextYAlignment.Top
					TextLabel.TextSize = 12
					TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					TextLabel.Text = "1/12"
					TextLabel.Font = Enum.Font.SourceSans
					TextLabel.TextXAlignment = Enum.TextXAlignment.Right
					TextLabel.Parent = Slider
					--TextLabel.ZIndex = 2

					local Main2 = Instance.new("Frame")
					Main2.Name = "Main"
					Main2.AnchorPoint = Vector2.new(0.5, 1)
					Main2.Size = UDim2.new(1, -12, 0, 12)
					Main2.Position = UDim2.new(0.5, 0, 1, -6)
					Main2.BackgroundColor3 = Gui.Theme
					Main2.Parent = Slider
					--Main2.ZIndex = 2

					local UICorner32 = Instance.new("UICorner")
					UICorner32.CornerRadius = UDim.new(0, 4)
					UICorner32.Parent = Main2

					local Inner5 = Instance.new("Frame")
					Inner5.Name = "Inner"
					Inner5.AnchorPoint = Vector2.new(0.5, 0.5)
					Inner5.Size = UDim2.new(1, -2, 1, -2)
					Inner5.Position = UDim2.new(0.5, 0, 0.5, 0)
					Inner5.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					Inner5.Parent = Main2
					--Inner5.ZIndex = 2

					local UICorner33 = Instance.new("UICorner")
					UICorner33.CornerRadius = UDim.new(0, 4)
					UICorner33.Parent = Inner5

					local Indicator = Instance.new("Frame")
					Indicator.Name = "Indicator"
					--Indicator.AnchorPoint = Vector2.new(0, 0)
					Indicator.Size = UDim2.new(0.5649717, 0, 1, 0)
					Indicator.Position = UDim2.new(0, 0, 0, 0)
					Indicator.BackgroundColor3 = Gui.Theme2
					Indicator.Parent = Inner5
					Indicator.BorderSizePixel = 0
					--Indicator.ZIndex = 2

					local UICorner34 = Instance.new("UICorner")
					UICorner34.CornerRadius = UDim.new(0, 4)
					UICorner34.Parent = Indicator

					local MouseDown, Floor, EndInput = false, function(...)
						return math.floor(...)
					end, nil

					TextButton10.MouseButton1Down:Connect(function(x, y)
						if Gui.InteractionsEnabled ~= true then
							return
						end
						MouseDown = true
						Indicator:TweenSize(
							UDim2.new(0, math.clamp(Mouse.X - Inner5.AbsolutePosition.X, 0, Inner5.AbsoluteSize.X), 1, 0),
							Enum.EasingDirection.InOut,
							Enum.EasingStyle.Linear,
							0.1,
							true, function()
								Settings.Value = Floor(((Indicator.AbsoluteSize.X / Inner5.AbsoluteSize.X) * (Settings.Max - Settings.Min)) + Settings.Min)
								Callback(Settings.Value)
								TextLabel.Text = tostring(Settings.Value) .. "/" .. tostring(Settings.Max)
							end
						)
						game:GetService("RunService").Heartbeat:Connect(function()
							spawn(function()
								if MouseDown then
									Indicator:TweenSize(
										UDim2.new(0, math.clamp(Mouse.X - Inner5.AbsolutePosition.X, 0, Inner5.AbsoluteSize.X), 1, 0),
										Enum.EasingDirection.InOut,
										Enum.EasingStyle.Linear,
										0.1,
										true, function()
											Settings.Value = Floor(((Indicator.AbsoluteSize.X / Inner5.AbsoluteSize.X) * (Settings.Max - Settings.Min)) + Settings.Min)
											Callback(Settings.Value)
											TextLabel.Text = tostring(Settings.Value) .. "/" .. tostring(Settings.Max)
										end
									)
								else
									while _VERSION == "Luau" do
										wait()
										-- repeat wait() until MouseDown
									end
								end
							end)
						end)
						game:GetService("UserInputService").InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								if MouseDown then
									MouseDown = false
								else

								end

							end
						end)
					end)

					TextLabel.Text = tostring(Settings.Value) .. "/" .. tostring(Settings.Max)
					Indicator.Size = UDim2.new((Settings.Value - math.abs(Settings.Min))/(Settings.Max - math.abs(Settings.Min)), 0, 1, 0)

					return CreatedSlider
				end

				CreatedSection.CreateDropdown = function(self, Name, Items, Callback, Settings)
					Items = Items or {"Bread", "Harms", "Haze", "Mikee"}
					Callback = Callback or function()
					end
					Settings = Settings or {}
					Settings.Selected = Settings.Selected or "select"
					local CreatedDropdown = {Opened = false}
					Settings.ZIndex = Settings.ZIndex or 3
					if Settings.CloseAutomatically == nil then
						Settings.CloseAutomatically = true
					end
					Settings.Id = game.HttpService:GenerateGUID(false)

					local Dropdown = Instance.new("Frame")
					Dropdown.Name = "Dropdown"
					Dropdown.Size = UDim2.new(1, 0, 0, 23)
					Dropdown.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
					Dropdown.Parent = SectionContent
					Dropdown.ZIndex = Settings.ZIndex

					local UICorner16 = Instance.new("UICorner")
					UICorner16.CornerRadius = UDim.new(0, 4)
					UICorner16.Parent = Dropdown

					local TextButton1 = Instance.new("TextButton")
					TextButton1.AnchorPoint = Vector2.new(0.5, 0.5)
					TextButton1.Size = UDim2.new(1, -2, 1, -2)
					TextButton1.Position = UDim2.new(0.5, 0, 0.5, 0)
					TextButton1.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					TextButton1.AutoButtonColor = false
					TextButton1.FontSize = Enum.FontSize.Size9
					TextButton1.TextSize = 12
					TextButton1.TextColor3 = Gui.Theme2
					TextButton1.Text =
						"<font color='rgb(255,255,255)'>   " .. Name .. ":</font> " .. tostring(Settings.Selected)
					TextButton1.TextXAlignment = Enum.TextXAlignment.Left
					TextButton1.Font = Enum.Font.SourceSans
					TextButton1.Parent = Dropdown
					TextButton1.ZIndex = Settings.ZIndex
					TextButton1.RichText = true

					local UICorner17 = Instance.new("UICorner")
					UICorner17.CornerRadius = UDim.new(0, 4)
					UICorner17.Parent = TextButton1

					local ImageLabel1 = Instance.new("ImageLabel")
					ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
					ImageLabel1.Size = UDim2.new(0, 18, 0, 18)
					ImageLabel1.BackgroundTransparency = 1
					ImageLabel1.Position = UDim2.new(1, -12, 0.5, 0)
					ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ImageLabel1.ImageColor3 = Gui.Theme2
					ImageLabel1.ImageRectOffset = Vector2.new(564, 284)
					ImageLabel1.ImageRectSize = Vector2.new(36, 36)
					ImageLabel1.Image = "rbxassetid://3926305904"
					ImageLabel1.Parent = TextButton1
					ImageLabel1.ZIndex = Settings.ZIndex

					local DropdownContent = Instance.new("Frame")
					DropdownContent.Name = "DropdownContent"
					--DropdownContent.Visible = false
					DropdownContent.Size = UDim2.new(1, 0, 0, 95)
					DropdownContent.Position = UDim2.new(0, 0, 1, 8)
					DropdownContent.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
					DropdownContent.Parent = Dropdown
					DropdownContent.ZIndex = Settings.ZIndex
					DropdownContent.Active = true

					local UICorner18 = Instance.new("UICorner")
					UICorner18.CornerRadius = UDim.new(0, 5)
					UICorner18.Parent = DropdownContent

					local Frame1 = Instance.new("Frame")
					Frame1.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame1.Size = UDim2.new(1, -2, 1, -2)
					Frame1.Position = UDim2.new(0.5, 0, 0.5, 0)
					Frame1.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					Frame1.Parent = DropdownContent
					Frame1.ZIndex = Settings.ZIndex

					--Frame1.BackgroundTransparency = 1
					ImageLabel1.Rotation = 0
					--DropdownContent.BackgroundTransparency = 1

					TextButton1.MouseEnter:Connect(
						function()
							--if DropdownContent.BackgroundTransparency == 1 then
							--	DropdownContent.Visible = true
							--end
							game:GetService("TweenService"):Create(
							TextButton1,
							TweenInfo.new(0.3),
							{
								TextColor3 = Gui.Theme
							}
							):Play()
							game:GetService("TweenService"):Create(
							ImageLabel1,
							TweenInfo.new(0.3),
							{
								ImageColor3 = Gui.Theme
							}
							):Play()
						end
					)
					TextButton1.MouseLeave:Connect(
						function()
							--if DropdownContent.BackgroundTransparency == 1 then
							--	DropdownContent.Visible = false
							--end
							game:GetService("TweenService"):Create(
							TextButton1,
							TweenInfo.new(0.3),
							{
								TextColor3 = Gui.Theme2
							}
							):Play()
							game:GetService("TweenService"):Create(
							ImageLabel1,
							TweenInfo.new(0.3),
							{
								ImageColor3 = Gui.Theme2
							}
							):Play()
						end
					)

					TextButton1.TextColor3 = Gui.Theme2
					DropdownContent.BackgroundTransparency = 1
					for i, v in next, DropdownContent:GetDescendants() do
						if
							HasProperty(v, "BackgroundTransparency") and not v:IsA("TextLabel") and
							not v:IsA("ScrollingFrame")
						then
							v.BackgroundTransparency = 1
						end
						if HasProperty(v, "TextTransparency") then
							v.TextTransparency = 1
						end
					end

					TextButton1.MouseButton1Down:Connect(
						function()
							if Gui.InteractionsEnabled ~= true and Gui.FocusedDropdown ~= Name .. Settings.Id then
								return
							end
							Gui.FocusedDropdown = Name .. Settings.Id
							spawn(
								function()
									game:GetService("TweenService"):Create(
									ImageLabel1,
									TweenInfo.new(.3),
									{
										Rotation = ImageLabel1.Rotation == 180 and 0 or 180,
										ImageColor3 = ImageLabel1.BackgroundColor3 == Gui.Theme and Gui.Theme2 or
											Gui.Theme
									}
									):Play()
									game:GetService("TweenService"):Create(
									TextButton1,
									TweenInfo.new(.3),
									{
										TextColor3 = TextButton1.BackgroundColor3 == Gui.Theme and Gui.Theme2 or
											Gui.Theme
									}
									):Play()
									game:GetService("TweenService"):Create(
									DropdownContent,
									TweenInfo.new(.3),
									{
										BackgroundTransparency = DropdownContent.BackgroundTransparency == 1 and 0 or 1
									}
									):Play()
									table.foreachi(
										DropdownContent:GetDescendants(),
										function(i, v)
											if
												HasProperty(v, "BackgroundTransparency") and not v:IsA("TextLabel") and
												not v:IsA("ScrollingFrame")
											then
												game:GetService("TweenService"):Create(
												v,
												TweenInfo.new(.3),
												{
													BackgroundTransparency = v.BackgroundTransparency == 1 and 0 or 1
												}
												):Play()
											end
											if HasProperty(v, "TextTransparency") then
												game:GetService("TweenService"):Create(
												v,
												TweenInfo.new(0.3),
												{
													TextTransparency = v.TextTransparency == 1 and 0 or 1
												}
												):Play()
											end
										end
									)
									wait(.3)
									Gui.Data.SetInteractionsEnabled(ImageLabel1.Rotation == 0 and true or false) -- lol
								end
							)
						end
					)

					local UICorner19 = Instance.new("UICorner")
					UICorner19.CornerRadius = UDim.new(0, 5)
					UICorner19.Parent = Frame1

					local ScrollingFrame1 = Instance.new("ScrollingFrame")
					ScrollingFrame1.AnchorPoint = Vector2.new(0.5, 0.5)
					ScrollingFrame1.Size = UDim2.new(1, -4, 1.0210526, -4)
					ScrollingFrame1.BackgroundTransparency = 1
					ScrollingFrame1.Position = UDim2.new(0.5, 0, 0.5105263, 0)
					ScrollingFrame1.Active = true
					ScrollingFrame1.BorderSizePixel = 0
					ScrollingFrame1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ScrollingFrame1.CanvasSize = UDim2.new(0, 0, 0, 255)
					ScrollingFrame1.ScrollBarThickness = 0
					ScrollingFrame1.Parent = Frame1
					ScrollingFrame1.ZIndex = Settings.ZIndex
					ScrollingFrame1.BackgroundTransparency = 1

					local UIListLayout4 = Instance.new("UIListLayout")
					UIListLayout4.HorizontalAlignment = Enum.HorizontalAlignment.Center
					UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
					UIListLayout4.Padding = UDim.new(0, 3)
					UIListLayout4.Parent = ScrollingFrame1
					game:GetService("RunService").Heartbeat:Connect(function()
						if UIListLayout4.AbsoluteContentSize.Y > 120 then
							ScrollingFrame1.CanvasSize = UDim2.fromOffset(0, UIListLayout4.AbsoluteContentSize.Y + 8)
							DropdownContent.Size = UDim2.new(1, 0, 0, 120)
						else
							ScrollingFrame1.CanvasSize = UDim2.fromOffset(0, 0)
							DropdownContent.Size = UDim2.new(1, 0, 0, UIListLayout4.AbsoluteContentSize.Y + 8)
						end
					end)
					CreatedDropdown.Add = function(Key)
						local TextButton2 = Instance.new("Frame")
						TextButton2.Size = UDim2.new(1, -2, 0, 28)
						TextButton2.BorderSizePixel = 0
						TextButton2.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
						--TextButton2.AutoButtonColor = false
						--TextButton2.FontSize = Enum.FontSize.Size14
						--TextButton2.TextSize = 14
						--TextButton2.TextColor3 = Color3.fromRGB(0, 0, 0)
						--TextButton2.Text = ""
						--TextButton2.Font = Enum.Font.SourceSans
						TextButton2.Parent = ScrollingFrame1
						TextButton2.ZIndex = Settings.ZIndex
						TextButton2.BackgroundTransparency = 1
						TextButton2.Active = true

						local TextLabel2 = Instance.new("TextLabel")
						TextLabel2.Size = UDim2.new(1, 0, 1, 0)
						TextLabel2.BorderColor3 = Color3.fromRGB(27, 42, 53)
						TextLabel2.BackgroundTransparency = 1
						TextLabel2.Position = UDim2.new(0, 6, 0, 0)
						TextLabel2.BorderSizePixel = 0
						TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel2.FontSize = Enum.FontSize.Size18
						TextLabel2.Text = Key
						TextLabel2.TextSize = 15
						TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel2.Font = Enum.Font.SourceSans
						TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
						TextLabel2.Parent = TextButton2
						TextLabel2.ZIndex = Settings.ZIndex
						TextLabel2.BackgroundTransparency = 1
						TextLabel2.TextTransparency = 1
						TextButton2.MouseEnter:Connect(
							function()
								--if TextButton2.BackgroundTransparency > 0 then
								--	return
								--end
								game:GetService("TweenService"):Create(
								TextLabel2,
								TweenInfo.new(0.22),
								{
									TextColor3 = Gui.Theme
								}
								):Play()
							end
						)
						TextButton2.MouseLeave:Connect(
							function()
								game:GetService("TweenService"):Create(
								TextLabel2,
								TweenInfo.new(0.22),
								{
									TextColor3 = Color3.fromRGB(255, 255, 255)
								}
								):Play()
							end
						)

						TextButton2.InputEnded:Connect(function(Mouse)
							if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
								Gui.Data.SetInteractionsEnabled(true)
							end
						end)

						TextButton2.InputBegan:Connect(
							function(Mouse)
								if Gui.InteractionsEnabled ~= false or TextButton2.Transparency > 0 then
									return
								end
								if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
									if DropdownContent.Visible == false then
										return
									end
									spawn(
										function()
											if Settings.CloseAutomatically then
												game:GetService("TweenService"):Create(
												ImageLabel1,
												TweenInfo.new(.3),
												{
													Rotation = 0
												}
												):Play()
												game:GetService("TweenService"):Create(
												DropdownContent,
												TweenInfo.new(.3),
												{
													BackgroundTransparency = 1
												}
												):Play()
												table.foreachi(
													DropdownContent:GetDescendants(),
													function(i, v)
														if
															HasProperty(v, "BackgroundTransparency") and
															not v:IsA("TextLabel") and
															not v:IsA("ScrollingFrame")
														then
															game:GetService("TweenService"):Create(
															v,
															TweenInfo.new(.3),
															{
																BackgroundTransparency = 1
															}
															):Play()
														end
														if HasProperty(v, "TextTransparency") then
															game:GetService("TweenService"):Create(
															v,
															TweenInfo.new(0.3),
															{
																TextTransparency = 1
															}
															):Play()
														end
													end
												)
												--DropdownContent.Visible = false
											end
											Settings.Selected = Key
											TextButton1.Text =
												"<font color='rgb(255,255,255)'>   " ..
												Name .. ":</font> " .. tostring(Settings.Selected)
											Callback(Settings.Selected)
											wait(.3)
											--DropdownContent.Visible = not DropdownContent.Visible
										end
									)
								end
							end
						)
					end

					table.foreachi(
						Items,
						function(i, v)
							CreatedDropdown.Add(v)
						end
					)
					return CreatedDropdown
				end

				--local Line1 = Instance.new("Frame")
				--Line1.Name = "Line"
				--Line1.AnchorPoint = Vector2.new(0.5, 0)
				--Line1.Size = UDim2.new(1, -8, 0, 1)
				--Line1.Position = UDim2.new(0.5, 0, 0, 26)
				--Line1.BorderSizePixel = 0
				--Line1.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				--Line1.Parent = Inner

				--local UICorner24 = Instance.new("UICorner")
				--UICorner24.CornerRadius = UDim.new(0, 4)
				--UICorner24.Parent = Section

				local Section2 = Instance.new("Frame")
				Section2.Name = "Section"
				Section2.Size = UDim2.new(1, 0, 0, 140)
				Section2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Section2.Parent = nil

				local Inner3 = Instance.new("Frame")
				Inner3.Name = "Inner"
				Inner3.AnchorPoint = Vector2.new(0.5, 0.5)
				Inner3.Size = UDim2.new(1, -2, 1, -2)
				Inner3.Position = UDim2.new(0.5, 0, 0.5, 0)
				Inner3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Inner3.Parent = Section2

				local UICorner25 = Instance.new("UICorner")
				UICorner25.CornerRadius = UDim.new(0, 4)
				UICorner25.Parent = Inner3

				local SectionName2 = Instance.new("TextLabel")
				SectionName2.Name = "SectionName"
				SectionName2.AnchorPoint = Vector2.new(1, 0)
				SectionName2.Size = UDim2.new(1, -8, 0, 24)
				SectionName2.BackgroundTransparency = 1
				SectionName2.Position = UDim2.new(1, 0, 0, 8)
				SectionName2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SectionName2.FontSize = Enum.FontSize.Size14
				SectionName2.TextSize = 14
				SectionName2.TextColor3 = Gui.Theme
				SectionName2.Text = "Section"
				SectionName2.TextYAlignment = Enum.TextYAlignment.Top
				SectionName2.TextWrapped = true
				SectionName2.Font = Enum.Font.SourceSansBold
				SectionName2.TextWrap = true
				SectionName2.TextXAlignment = Enum.TextXAlignment.Left
				SectionName2.Parent = Inner3

				local SectionContent2 = Instance.new("Frame")
				SectionContent2.Name = "SectionContent"
				SectionContent2.AnchorPoint = Vector2.new(0.5, 1)
				SectionContent2.Size = UDim2.new(1, -12, 1, -40)
				SectionContent2.BackgroundTransparency = 1
				SectionContent2.Position = UDim2.new(0.5, 0, 1, -6)
				SectionContent2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SectionContent2.Parent = Inner3

				local UIListLayout7 = Instance.new("UIListLayout")
				UIListLayout7.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout7.Padding = UDim.new(0, 3)
				UIListLayout7.Parent = SectionContent2

				local Button1 = Instance.new("Frame")
				Button1.Name = "Button"
				Button1.Size = UDim2.new(1, 0, 0, 23)
				Button1.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Button1.Parent = SectionContent2

				local UICorner26 = Instance.new("UICorner")
				UICorner26.CornerRadius = UDim.new(0, 4)
				UICorner26.Parent = Button1

				local TextButton9 = Instance.new("TextButton")
				TextButton9.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton9.Size = UDim2.new(1, -2, 1, -2)
				TextButton9.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextButton9.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
				TextButton9.AutoButtonColor = false
				TextButton9.FontSize = Enum.FontSize.Size9
				TextButton9.TextSize = 12
				TextButton9.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton9.Font = Enum.Font.SourceSans
				TextButton9.Parent = Button1

				local UICorner27 = Instance.new("UICorner")
				UICorner27.CornerRadius = UDim.new(0, 4)
				UICorner27.Parent = TextButton9
				CreatedSection.CreateKeybind = function(self, Dname, Callback, Settings)
					Callback = Callback or function()
					end
					Settings = Settings or {}
					Settings.Bind = Settings.Bind or Enum.KeyCode.E
					local Keybind = Instance.new("TextButton")
					Keybind.Name = "Keybind"
					Keybind.AnchorPoint = Vector2.new(0.5, 0.5)
					Keybind.Size = UDim2.new(1, 0, 0, 23)
					Keybind.BackgroundTransparency = 1
					Keybind.Position = UDim2.new(0.5, 0, 0.5, 0)
					Keybind.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
					Keybind.AutoButtonColor = false
					Keybind.FontSize = Enum.FontSize.Size9
					Keybind.TextSize = 12
					Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
					Keybind.Text = ""
					Keybind.Font = Enum.Font.SourceSans
					Keybind.Parent = SectionContent

					local Bind = Instance.new("Frame")
					Bind.Name = "Bind"
					Bind.Size = UDim2.new(0, 43, 0, 23)
					Bind.BackgroundColor3 = Gui.Theme
					Bind.Parent = Keybind

					local UICorner28 = Instance.new("UICorner")
					UICorner28.CornerRadius = UDim.new(0, 4)
					UICorner28.Parent = Bind

					local Inner4 = Instance.new("Frame")
					Inner4.Name = "Inner"
					Inner4.AnchorPoint = Vector2.new(0.5, 0.5)
					Inner4.Size = UDim2.new(1, -2, 1, -2)
					Inner4.Position = UDim2.new(0.5, 0, 0.5, 0)
					Inner4.BackgroundColor3 = Gui.Theme2
					Inner4.Parent = Bind

					local UICorner29 = Instance.new("UICorner")
					UICorner29.CornerRadius = UDim.new(0, 4)
					UICorner29.Parent = Inner4

					local Key = Instance.new("TextLabel")
					Key.Name = "Key"
					Key.Size = UDim2.new(1, -6, 1, 0)
					Key.BackgroundTransparency = 1
					Key.Position = UDim2.new(0, 6, 0, 0)
					Key.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Key.FontSize = Enum.FontSize.Size10
					Key.TextTruncate = Enum.TextTruncate.AtEnd
					Key.TextSize = 12
					Key.TextColor3 = Color3.fromRGB(255, 255, 255)
					Key.Text = "Backspace"
					Key.Font = Enum.Font.SourceSans
					Key.TextXAlignment = Enum.TextXAlignment.Left
					Key.Parent = Inner4

					local Name = Instance.new("TextLabel")
					Name.Name = "Name"
					Name.Size = UDim2.new(1, 0, 1, 0)
					Name.BackgroundTransparency = 1
					Name.Position = UDim2.new(0, 50, 0, 0)
					Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Name.FontSize = Enum.FontSize.Size10
					Name.TextSize = 12
					Name.TextColor3 = Color3.fromRGB(255, 255, 255)
					Name.Text = Dname or "Keybind"
					Name.Font = Enum.Font.SourceSans
					Name.TextXAlignment = Enum.TextXAlignment.Left
					Name.Parent = Keybind

					local Ignore = false
					local IgnoreNext = function()
						--spawn(
						--	function()
						Ignore = true
						wait()
						Ignore = false
						--	end
						--)
					end
					local Binput = function()
						Key.Text = "..."
						local Binded = false
						game:GetService("UserInputService").InputBegan:Connect(
						function(input, processed)
							if not processed then
								if not tostring(input.UserInputType):find("Mouse") then
									if Binded then return end
									IgnoreNext()
									Settings.Bind = input.KeyCode
								end
								if Binded then return end
								IgnoreNext()
								Key.Text = Settings.Bind.Name
								Binded = true
							end
						end
						)
					end

					Key.Text = Settings.Bind.Name

					game:GetService("UserInputService").InputBegan:Connect(
					function(input, processed)
						if not processed and input.KeyCode == Settings.Bind and not Ignore then
							Callback()
						end
					end
					)

					Keybind.InputBegan:Connect(
						function(Input, Processed)
							if not Processed then
								if Gui.InteractionsEnabled ~= true then
									return
								end
								if Input.UserInputType == Enum.UserInputType.MouseButton1 then
									Binput()
								end
							end
						end
					)
				end

				local Line2 = Instance.new("Frame")
				Line2.Name = "Line"
				Line2.AnchorPoint = Vector2.new(0.5, 0)
				Line2.Size = UDim2.new(1, -8, 0, 1)
				Line2.Position = UDim2.new(0.5, 0, 0, 26)
				Line2.BorderSizePixel = 0
				Line2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Line2.Parent = Inner3

				local UICorner35 = Instance.new("UICorner")
				UICorner35.CornerRadius = UDim.new(0, 4)
				UICorner35.Parent = Section2

				local UIPadding1 = Instance.new("UIPadding")
				UIPadding1.PaddingTop = UDim.new(0, 1)
				UIPadding1.PaddingBottom = UDim.new(0, 1)
				UIPadding1.PaddingLeft = UDim.new(0, 1)
				UIPadding1.PaddingRight = UDim.new(0, 1)
				UIPadding1.Parent = Tab2

				local Border = Instance.new("Frame")
				Border.Name = "Border"
				Border.ZIndex = -1
				Border.Size = UDim2.new(1, 0, 1, 0)
				Border.BorderSizePixel = 0
				Border.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				Border.Parent = Main

				local UICorner36 = Instance.new("UICorner")
				UICorner36.Parent = Border
				return CreatedSection
			end
			return CreatedTab
		end

		dragify(Main)

		local Frame3 = Instance.new("Frame")
		Frame3.Size = UDim2.new(1, -2, 0, 31)
		Frame3.Position = UDim2.new(0, 1, 0, 1)
		Frame3.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
		Frame3.Parent = Main

		local UICorner37 = Instance.new("UICorner")
		UICorner37.Parent = Frame3

		local Bottom = Instance.new("Frame")
		Bottom.Name = "Bottom"
		Bottom.AnchorPoint = Vector2.new(0, 1)
		Bottom.Size = UDim2.new(1, 0, 0, 8)
		Bottom.ClipsDescendants = true
		Bottom.BorderColor3 = Color3.fromRGB(255, 255, 255)
		Bottom.Position = UDim2.new(0, 0, 1, 0)
		Bottom.BorderSizePixel = 0
		Bottom.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
		Bottom.Parent = Frame3

		local Border1 = Instance.new("Frame")
		Border1.Name = "Border"
		Border1.Size = UDim2.new(1, 0, 0, 1)
		Border1.Position = UDim2.new(0, 0, 1, -1)
		Border1.BorderSizePixel = 0
		Border1.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
		Border1.Parent = Bottom

		local Buttons = Instance.new("Frame")
		Buttons.Name = "Buttons"
		Buttons.ZIndex = 3
		Buttons.Size = UDim2.new(1, 0, 1, 0)
		Buttons.BackgroundTransparency = 1
		Buttons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Buttons.Parent = Frame3

		local UIListLayout8 = Instance.new("UIListLayout")
		UIListLayout8.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout8.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout8.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout8.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout8.Padding = UDim.new(0, 4)
		UIListLayout8.Parent = Buttons

		local UIPadding2 = Instance.new("UIPadding")
		UIPadding2.PaddingRight = UDim.new(0, 10)
		UIPadding2.Parent = Buttons

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.Size = UDim2.new(1, -48, 1, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 12, 0, -1)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.FontSize = Enum.FontSize.Size18
		Title.TextSize = 15
		Title.TextColor3 = Gui.Theme
		Title.Text = "Spring"
		Title.Font = Enum.Font.SourceSans
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Frame3

		local Notifications = Instance.new("Frame")
		Notifications.Name = "Notifications"
		Notifications.AnchorPoint = Vector2.new(1, 1)
		Notifications.Size = UDim2.new(0, 255, 1, 0)
		Notifications.BackgroundTransparency = 1
		Notifications.Position = UDim2.new(1, -16, 1, -16)
		Notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Notifications.Parent = SpringGui

		local UIListLayout9 = Instance.new("UIListLayout")
		UIListLayout9.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout9.VerticalAlignment = Enum.VerticalAlignment.Bottom
		UIListLayout9.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout9.Padding = UDim.new(0, 3)
		UIListLayout9.Parent = Notifications

		CreatedGui.CreateNotification = function(self, Name, Description, Duration)
			local AlreadyClosing = false
			local Notification = {}
			Notification.Checked = Signal.new()
			Notification.Revoked = Signal.new()
			Notification.Ended = Signal.new()

			local Main3 = Instance.new("Frame")
			Main3.Name = "Main"
			Main3.ZIndex = 6
			Main3.Size = UDim2.new(0, 416, 0, 64)
			Main3.BorderColor3 = Color3.fromRGB(195, 195, 195)
			Main3.BackgroundTransparency = 1
			Main3.Position = UDim2.new(0, -161, 0, 508)
			Main3.Active = true
			Main3.ClipsDescendants = true
			Main3.BorderSizePixel = 0
			Main3.BackgroundColor3 = Color3.fromRGB(26, 32, 40)
			Main3.Parent = Notifications

			local Main4 = Instance.new("Frame")
			Main4.Name = "Main"
			Main4.ZIndex = 1
			Main4.Size = UDim2.new(1, -2, 1, -10)
			Main4.Position = UDim2.new(0, 1, 0, 9)
			Main4.BorderSizePixel = 0
			Main4.ClipsDescendants = true
			Main4.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
			Main4.Parent = Main3

			local UICorner38 = Instance.new("UICorner")
			UICorner38.Parent = Main4

			local Title1 = Instance.new("TextLabel")
			Title1.Name = "Desc"
			Title1.ZIndex = 2
			Title1.AnchorPoint = Vector2.new(0, 1)
			Title1.Size = UDim2.new(1, -48, 1, -28)
			Title1.BackgroundTransparency = 1
			Title1.Position = UDim2.new(0, 12, 1, -1)
			Title1.BorderSizePixel = 0
			Title1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title1.FontSize = Enum.FontSize.Size18
			Title1.TextSize = 15
			Title1.TextColor3 = Color3.fromRGB(245, 245, 245)
			Title1.Text =
				Description or 'This module has been disabled for: "As of now, Kill all is detected, don\'t use it"'
			Title1.TextYAlignment = Enum.TextYAlignment.Top
			Title1.Font = Enum.Font.SourceSans
			Title1.TextXAlignment = Enum.TextXAlignment.Left
			Title1.Parent = Main4

			local Border2 = Instance.new("Frame")
			Border2.Name = "Border"
			Border2.ZIndex = -1
			Border2.Size = UDim2.new(1, 0, 1, 0)
			Border2.BorderSizePixel = 0
			Border2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
			Border2.Parent = Main3

			local UICorner39 = Instance.new("UICorner")
			UICorner39.Parent = Border2

			--local UIScale1 = Instance.new("UIScale")
			--UIScale1.Parent = Main3

			local Frame4 = Instance.new("Frame")
			Frame4.Size = UDim2.new(1, -2, 0, 31)
			Frame4.Position = UDim2.new(0, 1, 0, 1)
			Frame4.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
			Frame4.Parent = Main3

			local UICorner40 = Instance.new("UICorner")
			UICorner40.Parent = Frame4

			local Bottom1 = Instance.new("Frame")
			Bottom1.Name = "Bottom"
			Bottom1.AnchorPoint = Vector2.new(0, 1)
			Bottom1.Size = UDim2.new(1, 0, 0, 8)
			Bottom1.ClipsDescendants = true
			Bottom1.BorderColor3 = Color3.fromRGB(255, 255, 255)
			Bottom1.Position = UDim2.new(0, 0, 1, 0)
			Bottom1.BorderSizePixel = 0
			Bottom1.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
			Bottom1.Parent = Frame4

			local Border3 = Instance.new("Frame")
			Border3.Name = "Border"
			Border3.Size = UDim2.new(1, 0, 0, 1)
			Border3.Position = UDim2.new(0, 0, 1, -1)
			Border3.BorderSizePixel = 0
			Border3.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
			Border3.Parent = Bottom1

			local Buttons1 = Instance.new("Frame")
			Buttons1.Name = "Buttons"
			Buttons1.ZIndex = 3
			Buttons1.Size = UDim2.new(1, 0, 1, 0)
			Buttons1.BackgroundTransparency = 1
			Buttons1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Buttons1.Parent = Frame4

			local UIListLayout10 = Instance.new("UIListLayout")
			UIListLayout10.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout10.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout10.VerticalAlignment = Enum.VerticalAlignment.Center
			UIListLayout10.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout10.Padding = UDim.new(0, 3)
			UIListLayout10.Parent = Buttons1

			local ImageButton1 = Instance.new("ImageButton")
			ImageButton1.ZIndex = 2
			ImageButton1.Size = UDim2.new(0, 14, 0, 14)
			ImageButton1.BackgroundTransparency = 1
			ImageButton1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageButton1.ImageColor3 = Gui.Theme
			ImageButton1.Image = "rbxassetid://3224442404"
			ImageButton1.Parent = Buttons1
			ImageButton1.MouseButton1Down:Connect(
				function()
					if AlreadyClosing then
						return
					end
					Notification.Checked:fire()
					Notification.Ended:fire()
				end
			)
			local UIPadding3 = Instance.new("UIPadding")
			UIPadding3.PaddingRight = UDim.new(0, 10)
			UIPadding3.Parent = Buttons1

			local ImageButton2 = Instance.new("ImageButton")
			ImageButton2.ZIndex = 2
			ImageButton2.Size = UDim2.new(0, 14, 0, 14)
			ImageButton2.BackgroundTransparency = 1
			ImageButton2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageButton2.ImageColor3 = Gui.Theme
			ImageButton2.Image = "rbxassetid://4661609682"
			ImageButton2.Parent = Buttons1
			ImageButton2.MouseButton1Down:Connect(
				function()
					if AlreadyClosing then
						return
					end
					Notification.Revoked:fire()
					Notification.Ended:fire()
				end
			)

			local CircularProgressBar = Instance.new("Frame")
			CircularProgressBar.Name = "CircularProgressBar"
			CircularProgressBar.LayoutOrder = -1
			CircularProgressBar.AnchorPoint = Vector2.new(0.5, 0.5)
			CircularProgressBar.Size = UDim2.new(0, 15, 0, 15)
			CircularProgressBar.BackgroundTransparency = 1
			CircularProgressBar.Position = UDim2.new(1, -56, 1, -56)
			CircularProgressBar.Parent = Buttons1

			local Half2 = Instance.new("Frame")
			Half2.Name = "Half2"
			Half2.Size = UDim2.new(0.5, 0, 1, 0)
			Half2.ClipsDescendants = true
			Half2.BackgroundTransparency = 1
			Half2.Parent = CircularProgressBar

			local ImageLabel3 = Instance.new("ImageLabel")
			ImageLabel3.Size = UDim2.new(2, 0, 1, 0)
			ImageLabel3.BackgroundTransparency = 1
			ImageLabel3.ImageColor3 = Gui.Theme
			ImageLabel3.Image = "rbxassetid://2763450503"
			ImageLabel3.Parent = Half2

			local UIGradient = Instance.new("UIGradient")
			UIGradient.Transparency =
				NumberSequence.new(
					{
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.4999, 0),
						NumberSequenceKeypoint.new(0.5, 1),
						NumberSequenceKeypoint.new(1, 1)
					}
				)
			UIGradient.Rotation = -125
			UIGradient.Parent = ImageLabel3

			local Half1 = Instance.new("Frame")
			Half1.Name = "Half1"
			Half1.Size = UDim2.new(0.5, 0, 1, 0)
			Half1.ClipsDescendants = true
			Half1.BackgroundTransparency = 1
			Half1.Position = UDim2.new(0.5, 0, 0, 0)
			Half1.Parent = CircularProgressBar

			local ImageLabel4 = Instance.new("ImageLabel")
			ImageLabel4.Size = UDim2.new(2, 0, 1, 0)
			ImageLabel4.BackgroundTransparency = 1
			ImageLabel4.Position = UDim2.new(-1, 0, 0, 0)
			ImageLabel4.ImageColor3 = Gui.Theme
			ImageLabel4.Image = "rbxassetid://2763450503"
			ImageLabel4.Parent = Half1

			local UIGradient1 = Instance.new("UIGradient")
			UIGradient1.Transparency =
				NumberSequence.new(
					{
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.4999, 0),
						NumberSequenceKeypoint.new(0.5, 1),
						NumberSequenceKeypoint.new(1, 1)
					}
				)
			UIGradient1.Rotation = 180
			UIGradient1.Parent = ImageLabel4

			local Title2 = Instance.new("TextLabel")
			Title2.Name = "Title"
			Title2.ZIndex = 2
			Title2.Size = UDim2.new(1, -48, 1, 0)
			Title2.BackgroundTransparency = 1
			Title2.Position = UDim2.new(0, 12, 0, -1)
			Title2.BorderSizePixel = 0
			Title2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title2.FontSize = Enum.FontSize.Size18
			Title2.TextSize = 15
			Title2.TextColor3 = Gui.Theme
			Title2.Text = Name or "Kill all"
			Title2.Font = Enum.Font.SourceSans
			Title2.TextXAlignment = Enum.TextXAlignment.Left
			Title2.Parent = Frame4

			local function Close()
				if AlreadyClosing == true then
					return
				end
				AlreadyClosing = true
				spawn(
					function()
						game:GetService("TweenService"):Create(
						Main3,
						TweenInfo.new(.25, Enum.EasingStyle.Sine),
						{
							Size = UDim2.new(0, Main3.AbsoluteSize.X - 4, 0, Main3.AbsoluteSize.Y - 4),
							BackgroundColor3 = Color3.fromRGB(18, 18, 18)
						}
						):Play()
						wait(.2)
						game:GetService("TweenService"):Create(
						Main3,
						TweenInfo.new(.65, Enum.EasingStyle.Sine),
						{
							Size = UDim2.new(0, 0, 0, Main3.AbsoluteSize.Y - 4)
						}
						):Play()
						wait(1)
						game:GetService("TweenService"):Create(
						Main3,
						TweenInfo.new(.35, Enum.EasingStyle.Sine),
						{
							Size = UDim2.new(0, 0, 0, 0)
						}
						):Play()
						wait(1)
						Main3:Remove()
					end
				)
			end

			local T, d = Title2, Title1
			local GreatestAbsX = nil
			--print(Title2.TextBounds.X <= Title1.TextBounds.X)
			GreatestAbsX =
				math.ceil(Title2.TextBounds.X + 76) >= math.ceil(Title1.TextBounds.X + 32) and
				math.ceil(Title2.TextBounds.X + 76) or
				math.ceil(Title1.TextBounds.X + 32)
			print(GreatestAbsX, T.TextBounds.X, d.TextBounds.X)
			Main3.Size = UDim2.fromOffset(GreatestAbsX, 64)
			spawn(
				function()
					Main3.Size = UDim2.fromOffset(0, 0)
					game:GetService("TweenService"):Create(
					Main3,
					TweenInfo.new(.2, Enum.EasingStyle.Back),
					{
						Size = UDim2.fromOffset(0, 64)
					}
					):Play()
					wait(.2)
					game:GetService("TweenService"):Create(
					Main3,
					TweenInfo.new(.65, Enum.EasingStyle.Sine),
					{
						Size = UDim2.fromOffset(GreatestAbsX, 64)
					}
					):Play()
					wait(Duration)
					Close()
				end
			)

			Notification.Ended:Connect(Close)

			spawn(
				function()
					UIGradient1.Rotation = 0
					UIGradient.Rotation = -180
					game:GetService("TweenService"):Create(
					UIGradient1,
					TweenInfo.new(Duration / 2, Enum.EasingStyle.Linear),
					{
						Rotation = 180
					}
					):Play()
					repeat
						wait()
					until UIGradient1.Rotation == 180
					game:GetService("TweenService"):Create(
					UIGradient,
					TweenInfo.new(Duration / 2, Enum.EasingStyle.Linear),
					{
						Rotation = 0
					}
					):Play()
					repeat
						wait()
					until UIGradient.Rotation == 0
					Notification.Ended:fire()
				end
			)
			return Notification
		end
		CreatedGui.SetTitle = function(self, New)
			Title.Text = New or "Title"
		end
		CreatedGui:SetTitle(AssignedGuiName)
		return CreatedGui
	end
end

local MainWindow = Gui:CreateGui("Farmhub Autorob", {
	Theme = Color3.fromHex("5193a3"),
	Theme2 = Color3.fromHex("244D57")
})

getgenv()._notify = function(title, desc, duration)
	MainWindow.CreateNotification(MainWindow, title, desc, duration)
end

local HomeTab = MainWindow:CreateTab("Home"):SetDefault()
local RobberiesTab = MainWindow:CreateTab("Robberies")
local SettingsTab = MainWindow:CreateTab("Settings")
local MiscTab = MainWindow:CreateTab("Miscellaneous")

local MainTab = HomeTab:CreateSection("Autorob")
local StatusTab = HomeTab:CreateSection("Statuses", "Right")
local CreditsSec = HomeTab:CreateSection("Credits")
local AboutSec = HomeTab:CreateSection("About", "Right")

MainTab:CreateToggle("Enabled", function(state)
    ToggleAutorob(state)
end, { Enabled = Settings.Enabled })

local StoreLbl = MainTab:CreateTextlabel("Store: None")
local StatusLbl = MainTab:CreateTextlabel("Status: Autorob disabled.")
local MoneyLbl = StatusTab:CreateTextlabel("Money Earned: $0")
local TimeLbl = StatusTab:CreateTextlabel("Time Elapsed: 0h/0m")
local RatesLbl = StatusTab:CreateTextlabel("Estimated Rates: $0/hr")

CreditsSec:CreateTextlabel("@babyfayy333: Scripting")
CreditsSec:CreateTextlabel("@itztempy0: Scripting")
CreditsSec:CreateTextlabel("@harmonicdust: UI Library")

AboutSec:CreateKeybind("Toggle Gui", MainWindow.Toggle, { Bind = Enum.KeyCode.RightShift })
AboutSec:CreateTextlabel("Total Executions: " .. "0")
AboutSec:CreateButton("Copy Script Key", function()
    setclipboard(script_key)
end)

function SetStats(money, time)
    local function Set()
        MoneyLbl:Set("Money Earned: $" .. FormatCash(money))
        TimeLbl:Set("Time Elapsed: " .. TickToHM(time))
		RatesLbl:Set("Estimated Rates: $" .. FormatCash(math.floor(money / time * 3600)) .. "/hr")
    end

    spawn(function()
        while not pcall(Set) do 
            wait()
        end
    end)
end

function SetStatus(store, stat)
    local function Set()
        StoreLbl:Set("Store: " .. store)
        StatusLbl:Set("Status: " .. stat)
    end

    spawn(function()
        while not pcall(Set) do 
            wait()
        end
    end)
end

local StatusSec = RobberiesTab:CreateSection("Robbery Status")
local IncludedSec = RobberiesTab:CreateSection("Included Robberys", "Right")

do
	local OldOpen = {
		Donut = 3,
		Gas = 3,
		Jewelry = 3,
		PassengerTrain = 3,
		CargoTrain = 3,
		Museum = 3,
		CargoPlane = 3,
		Bank = 3,
		CraterBank = 3,
		Airdrop = 3,
		PowerPlant = 3,
		-- Casino = 100,
		OilRig = 3,
		Tomb = 3,
		Mansion = 3,
		CargoShip = 3,
	}

	for i, v in next, Robbery do
		local StatLbl = StatusSec:CreateTextlabel((SplitCaps(i) or i) .. ": ??")

		local function UpdateStatus()
			if (i ~= "Airdrop" and v.Open) or (i == "Airdrop" and GetClosestAirdrop()) then
				StatLbl:Set(SplitCaps(i) or i)
				StatLbl:SetColor(Color3.new(0, 255, 0))
			else
				StatLbl:Set(SplitCaps(i) or i)
				StatLbl:SetColor(Color3.new(255, 0, 0))
			end
		end

		UpdateStatus()
		Robbery.OnOpen:Connect(UpdateStatus)

        IncludedSec:CreateToggle((SplitCaps(i) or i), function(state)
            Robbery[i].Enabled = state
			Settings.RobberyTogglesOff[i] = not state
        end, { Enabled = Robbery[i].Enabled })
	end
end

local RobSetsSec = SettingsTab:CreateSection("Robberies")
local FirearmsSec = SettingsTab:CreateSection("Firearms", "Right")
local TeleportSec = SettingsTab:CreateSection("Teleportation", "Right")

RobSetsSec:CreateSlider("Cooldown", function(Value)
	Settings.Cooldown = Value
end, { Min = 0, Max = 20, Value = Settings.Cooldown, Exact = false })
RobSetsSec:CreateSlider("Police Abort Range", function(Value)
	Settings.CopRange = Value
end, { Min = 30, Max = 200, Value = Settings.CopRange, Exact = false })
RobSetsSec:CreateDropdown("Priority Order", {"Highest Cash", "Lowest Cash", "Store Groups"}, function(Item)
    ReorderPriority((Item == "Highest $" and "Highest") or (Item == "Lowest $" and "Lowest" or "Grouped"))
end, {ZIndex = 4})
RobSetsSec:CreateToggle("Hyperchromes Focused", function(state)
	Settings.HyperFocus = state
end, { Enabled = Settings.HyperFocus})
RobSetsSec:CreateToggle("Await Reward Roll", function(state)
	Settings.AwaitReward = state
end, { Enabled = Settings.AwaitReward })
RobSetsSec:CreateToggle("Human Solve Puzzles", function(state)
	Settings.HumanSolve = state
end, { Enabled = Settings.HumanSolve })
RobSetsSec:CreateToggle("Avoid detections (BROKEN)", function(state)
end, { })
FirearmsSec:CreateDropdown("Prefered Gun", {"Pistol", "Shotgun", "Uzi", "AK-47"}, function(Item)
    print(Item)
end, {ZIndex = 4})

TeleportSec:CreateSlider("Player Speed", function(Value)
	Settings.PlayerSpeed = Value
end, { Min = 50, Max = 100, Value = 85, Exact = false })
TeleportSec:CreateSlider("Sky Speed", function(Value)
	Settings.SkySpeed = Value
end, { Min = 70, Max = 120, Value = 100, Exact = false })
TeleportSec:CreateSlider("Vehicle Speed", function(Value)
    Settings.VehicleSpeed = Value
end, { Min = 300, Max = 450, Value = 350, Exact = false })

local PlayerSec = MiscTab:CreateSection("Player")
local VehicleSec = MiscTab:CreateSection("Vehicle", "Right")
local WebhookSec = MiscTab:CreateSection("Webhooking")
local NotifySec = MiscTab:CreateSection("Store Status", "Right")

PlayerSec:CreateToggle("Kill Aura", function(state)
    Settings.KillAura = state
end, { Enabled = Settings.KillAura })

PlayerSec:CreateToggle("Server Hop", function(state)
	Settings.ServerHop = state
end, { Enabled = Settings.ServerHop })

PlayerSec:CreateButton("Open All Safes", function(state)
	local SafeAmt = #Modules.Store._state.safesInventoryItems
	if SafeAmt ~= 0 then
		for i = 1, SafeAmt do
			local CurrentSafe = Modules.Store._state.safesInventoryItems[1]

			ReplicatedStorage[Modules.SafeConsts.SAFE_OPEN_REMOTE_NAME]:FireServer(CurrentSafe.itemOwnedId)
			task.wait(3)
		end
	end
end)

PlayerSec:CreateButton("Reset Character", function(state)
    if Humanoid and Humanoid.Health > 0 then
		ExitVehicle()
        Humanoid.Health = 0
        task.wait(0.01)
    end
end)

VehicleSec:CreateToggle("Auto Lock Vehicle", function(state)
    Settings.AutoLockVehicle = state
end, { Enabled = Settings.AutoLockVehicle })

VehicleSec:CreateToggle("Auto Kick Players", function(state)
    Settings.AutoKickPlayers = state
end, { Enabled = Settings.AutoKickPlayers })

VehicleSec:CreateToggle("Auto Disable Vehicles", function(state)
    Settings.LoopTirePop = state
end, { Enabled = Settings.LoopTirePop })

WebhookSec:CreateTextbox("Webhook URL", function(text)
    Settings.WebhookURL = text
end, { Text = (Settings.WebhookURL == "" and "Webhook URL" or tostring(Settings.WebhookURL)), RememberLastText = false })

WebhookSec:CreateToggle("Alert Earnings", function(state)
	Settings.AlertEarnings = state
end, { Enabled = Settings.AlertEarnings })

WebhookSec:CreateToggle("Alert Hyperchromes", function(state)
	Settings.AlertHyper = state
end, { Enabled = Settings.AlertHyper })

NotifySec:CreateToggle("Notify Robbery Status", function(state)
	Settings.NotifyOpenings = state
end, { Enabled = Settings.NotifyOpenings })

NotifySec:CreateToggle("Chat Robbery Status", function(state)
	Settings.ChatOpenings = state
end, { Enabled = Settings.ChatOpenings })

-------------------->>  Wrapping up  <<--------------------

Notif("Farmhub Injected in " .. string.format("%.2f", (tick() - TimeStarted)) .. "s", 7)

if FH_DEBUG then
	print("[FarmHub (DEBUG)]: Farmhub Injected successfully")
end
