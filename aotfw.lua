-- SERVICES
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "TeamESP_UI"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.fromOffset(150, 40)
toggleBtn.Position = UDim2.fromOffset(20, 20)
toggleBtn.Text = "Show Players"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = gui

-- Main Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(300, 400)
panel.Position = UDim2.fromOffset(20, 70)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.Visible = false
panel.Parent = gui

-- UI List
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = panel

-- Toggle logic
toggleBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
	toggleBtn.Text = panel.Visible and "Hide Players" or "Show Players"
end)

-- ESP STORAGE
local highlights = {}

-- Clear UI + ESP
local function clearAll()
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	for _, h in pairs(highlights) do
		h:Destroy()
	end
	highlights = {}
end

-- Add player to UI + ESP
local function addPlayer(player)
	if player == localPlayer then return end
	if not player.Character then return end
	if not player.Team then return end

	-- UI Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 30)
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	label.Text = player.Name .. " | Team: " .. player.Team.Name
	label.Parent = panel

	-- ESP Highlight
	local highlight = Instance.new("Highlight")
	highlight.Adornee = player.Character
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = gui

	-- Color by team
	if player.Team == localPlayer.Team then
		highlight.FillColor = Color3.fromRGB(0, 170, 255) -- same team (blue)
	else
		highlight.FillColor = Color3.fromRGB(255, 60, 60) -- enemy (red)
	end

	highlights[player] = highlight
end

-- Refresh everything
local function refresh()
	clearAll()
	for _, player in ipairs(Players:GetPlayers()) do
		addPlayer(player)
	end
end

-- Character loaded
local function onCharacterAdded(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		refresh()
	end)
end

-- EVENTS
Players.PlayerAdded:Connect(function(player)
	onCharacterAdded(player)
	task.wait(1)
	refresh()
end)

Players.PlayerRemoving:Connect(function()
	refresh()
end)

for _, player in ipairs(Players:GetPlayers()) do
	onCharacterAdded(player)
	player:GetPropertyChangedSignal("Team"):Connect(refresh)
end

-- Initial load
repeat task.wait() until localPlayer.Team ~= nil
refresh()
