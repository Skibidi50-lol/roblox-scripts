local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
print("not virus 100% | Klyro Softworks")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local roles

local teleportEnabled = false
local espEnabled = false
local godModeEnabled = false
local InfiniteJumpEnabled = false
local xrayEnabled = false

function Xray()
	for _, xray in pairs(workspace:GetDescendants()) do
	   if xray:IsA("BasePart") and not xray.Parent:FindFirstChildWhichIsA("Humanoid") and not xray.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
		   xray.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
		 end
	 end
 end

 
function infJump()
	game:GetService("UserInputService").JumpRequest:connect(function()
		if InfiniteJumpEnabled then
			game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
		end
	end)
end
 


local function findCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        local coinContainer = child:FindFirstChild("CoinContainer")
        if coinContainer then
            return coinContainer
        end
    end
    return nil
end


local function findNearestCoin(radius)
    local coinContainer = findCoinContainer()
    if not coinContainer then
        print("CoinContainer not found")
        return nil
    end
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local nearestCoin = nil
    local nearestDistance = radius
    for _, coin in pairs(coinContainer:GetChildren()) do
        local distance = (coin.Position - humanoidRootPart.Position).Magnitude
        if distance < nearestDistance then
            nearestCoin = coin
            nearestDistance = distance
        end
    end
    return nearestCoin
end


local function teleportToCoin(coin)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local tweenInfo = TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
    tween:Play()
    return tween
end

-- Variable to track if a teleport is in progressocal 
isTeleporting = false

-- Function to teleport to a nearby coin or a random coin
local function teleportToNearbyOrRandomCoin()
    if not teleportEnabled or isTeleporting then return end
    local nearbyRadius = 50 -- Adjust this value to change the "nearby" distance
    local nearbyCoin = findNearestCoin(nearbyRadius)
    if nearbyCoin then
        print("Teleporting to nearby coin")		
        isTeleporting = true
        local tween = teleportToCoin(nearbyCoin)
        tween.Completed:Connect(function()
            isTeleporting = false
            teleportToNearbyOrRandomCoin() -- Immediately move to the next coin
        end)
    else
        local coinContainer = findCoinContainer()
        if not coinContainer then
            print("CoinContainer not found")
            return
        end
        local coins = coinContainer:GetChildren()
        if #coins == 0 then
            print("No coins found")
            return
        end
        local randomCoin = coins[math.random(1, #coins)]
        print("Teleporting to random coin")
        isTeleporting = true
        local tween = teleportToCoin(randomCoin)
        tween.Completed:Connect(function()
            isTeleporting = false
            teleportToNearbyOrRandomCoin() -- Immediately move to the next coin
        end)
    end
end

-- Function to handle character respawn
local function onCharacterAdded(newCharacter)
    character = newCharacter
end

-- Connect to current and future characters
player.CharacterAdded:Connect(onCharacterAdded)

-- Start the continuous teleportation loop
RunService.Heartbeat:Connect(function()
    if teleportEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        teleportToNearbyOrRandomCoin()
    end
end)

-- ESP Functions
function CreateHighlight() -- make any new highlights for new players
    for i, v in pairs(Players:GetChildren()) do
        if v ~= player and v.Character and not v.Character:FindFirstChild("Highlight") then
            Instance.new("Highlight", v.Character)           
        end
    end
end

function UpdateHighlights() -- Get Current Role Colors (messy)
    for _, v in pairs(Players:GetChildren()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Highlight") then
            local Highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == Sheriff and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(0, 0, 225)
            elseif v.Name == Murder and IsAlive(v) then
                Highlight.FillColor = Color3.fromRGB(225, 0, 0)
            elseif v.Name == Hero and IsAlive(v) and not IsAlive(game.Players[Sheriff]) then
                Highlight.FillColor = Color3.fromRGB(255, 250, 0)
            else
                Highlight.FillColor = Color3.fromRGB(0, 225, 0)
            end
        end
    end
end    

function IsAlive(Player) -- Simple function
    for i, v in pairs(roles) do
        if Player.Name == i then
            if not v.Killed and not v.Dead then
                return true
            else
                return false
            end
        end
    end
end

-- ESP Loop
RunService.RenderStepped:connect(function()
    if espEnabled then
        roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        for i, v in pairs(roles) do
            if v.Role == "Murderer" then
                Murder = i
            elseif v.Role == 'Sheriff' then
                Sheriff = i
            elseif v.Role == 'Hero' then
                Hero = i
            end
        end
        CreateHighlight()
        UpdateHighlights()
    end
end)

-- GodMode Function
local accessories = {}
function GodMode()
    if player.Character then
        if player.Character:FindFirstChild("Humanoid") then
            for _, accessory in pairs(player.Character.Humanoid:GetAccessories()) do
                table.insert(accessories, accessory:Clone())
            end
            player.Character.Humanoid.Name = "deku"
        end
        local v = player.Character["deku"]:Clone()
        v.Parent = player.Character
        v.Name = "Humanoid"
        wait(0.1)
        player.Character["deku"]:Destroy()
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        for _, accessory in pairs(accessories) do
            player.Character.Humanoid:AddAccessory(accessory)
        end
        player.Character.Animate.Disabled = true
        wait(0.1)
        player.Character.Animate.Disabled = false
    end
end

local function enableNoclip()
	noclipConnection = game:GetService("RunService").Stepped:Connect(function()
		local char = game.Players.LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function disableNoclip()
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
end

local Window = Rayfield:CreateWindow({
	Name = "Murder Mystery 2",
	Icon = "pocket-knife", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
	LoadingTitle = "mm2",
	LoadingSubtitle = "by Klyro Softworks",
	Theme = "Default",
 
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
	ConfigurationSaving = {
	   Enabled = true,
	   FolderName = nil, -- Create a custom folder for your hub/game
	   FileName = "Klyro"
	},
 
	Discord = {
	   Enabled = false, =
	   Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
	   RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	},
 
	KeySystem = false, -- Set this to true to use our key system
	KeySettings = {
	   Title = "Untitled",
	   Subtitle = "Key System",
	   Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
	   FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
	   SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
	   GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
	   Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	}
 })

 local coinTab = Window:CreateTab("Auto Farm", "coins")
 local Section = coinTab:CreateSection("Auto Farm Settings")

 local Toggle = coinTab:CreateToggle({
	Name = "Auto Coins",
	CurrentValue = false,
	Flag = "CoinToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
	    teleportEnabled = Value
	end,
 })

 local Slider = coinTab:CreateSlider({
	Name = "Farm Radius",
	Range = {10, 250},
	Increment = 10,
	Suffix = "Radius",
	CurrentValue = 50,
	Flag = "RadiusSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		nearbyRadius = Value
	end,
 })

 local plrTab = Window:CreateTab("Player", "user")
 local Section = plrTab:CreateSection("Player Settings")

 local Slider = plrTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {0, 250},
	Increment = 1,
	Suffix = "WS",
	CurrentValue = 16,
	Flag = "SpeedSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
	end,
 })

 local Slider = plrTab:CreateSlider({
	Name = "Jump Boost",
	Range = {50, 250},
	Increment = 10,
	Suffix = "JB",
	CurrentValue = 50,
	Flag = "JumpSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
	end,
 })

 local Toggle = plrTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "infToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
	    InfiniteJumpEnabled = Value
		infJump()
	end,
 })

 local Toggle = plrTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Flag = "noclipToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(state)
	    noclipEnabled = state
		if state then
			enableNoclip()
		else
			disableNoclip()
		end
	end,
 })


 local miscTab = Window:CreateTab("Other", "box")
 local Section = miscTab:CreateSection("Visuals Settings")

 local Toggle = miscTab:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Flag = "espToggle", 
	Callback = function(Value)
	    espEnabled = Value
	end,
 })

 local Toggle = miscTab:CreateToggle({
	Name = "X-Ray",
	CurrentValue = false,
	Flag = "xrayToggle", 
	Callback = function(Value)
	    xrayEnabled = Value
		Xray()
	end,
 })

 local Divider = miscTab:CreateDivider()

 local Toggle = miscTab:CreateToggle({
    Name = "God Mode (reset after round)",
    CurrentValue = false,
    Flag = "godToggle", 
    Callback = function(Value)
        godModeEnabled = Value
        if godModeEnabled then
            GodMode()
        end
    end,
 })

 local function GetMurderer()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and (player.Character:FindFirstChild("Knife") or player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild("Knife")) then
			return player
		end
	end
end

local function TrackMurderer()
	local murderer = GetMurderer()
	if not murderer then return end

	repeat
		if murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
			workspace.CurrentCamera.CFrame = murderer.Character.HumanoidRootPart.CFrame
		end
		wait()
	until murderer.Character:FindFirstChild("Humanoid") and murderer.Character.Humanoid.Health == 0
end

local Button = miscTab:CreateButton({
    Name = "Kill Murder (Need a gun)",
    Callback = function()
		local Murderer = GetMurderer() 
		local pos = Murderer.Character.HumanoidRootPart.Position
	repeat
	    if Murderer ~= nil then 
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
				workspace.CurrentCamera.CFrame = Murderer.Character.HumanoidRootPart.CFrame
				
			end
	         wait()
	        until Murderer.Character.Humanoid.Health == 0
    end,
 })

 local Button = miscTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/MarsQQ/ScriptHubScripts/master/FPS%20Boost"))();
    end,
 })


 local Button = miscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
		TeleportService:Teleport(game.PlaceId, player)
    end,
 })

 local themesTab = Window:CreateTab("UI Settings", "settings")
 local Section = themesTab:CreateSection("UI Settings")

 themesTab:CreateDropdown({
	Name = "Current Theme",
	Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
	CurrentOption = {"Default"},
	MultipleOptions = false,
	Flag = "CurrentTheme",
	Callback = function(Options)
		 Window.ModifyTheme(Options[1])
	end,
 })

 Rayfield:LoadConfiguration()
