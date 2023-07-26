local Players = game:GetService('Players');
local RunService = game:GetService('RunService');
local UserInputService = game:GetService('UserInputService');
local CurrentPlayer = Players.LocalPlayer;
local CurrentPlrChar, CurrentPlayerNode = CurrentPlayer.CharacterAdded:Wait(), 1;

CurrentPlayer.CameraMode = Enum.CameraMode.LockFirstPerson;

local Pathfinder = require(script.Pathfinder);
local AllNodes, BakedPaths = Pathfinder:Init();

local ZombiesFolder = workspace.Zombies;
local ZombiesFolderArray = ZombiesFolder:GetChildren();
local ZombieChunkSize = 25;
local ZombieChunks: {
	[number]: {
		Actor: Actor;
		Zombies: {}
	}
} = {};

local function DeepCopyTable(t: {}): {}
	local copy = {}
	for k,v in t do
		if (typeof(v) == "table") then
			copy[k] = DeepCopyTable(v)
		else
			copy[k] = v
		end
	end
	return copy
end

for i = 1, math.ceil(#ZombiesFolderArray/ZombieChunkSize) do
	local ActorTemplate = script.Actor:Clone();
	ActorTemplate.Parent = script.Threads;
	ActorTemplate.Script.Enabled = true;

	ActorTemplate:SendMessage('Initialize',
		CurrentPlrChar:WaitForChild('HumanoidRootPart'),
		DeepCopyTable(AllNodes),
		BakedPaths
	);
	ActorTemplate:SendMessage('InitializeLoop', 0.5);

	ZombieChunks[i] = {
		Actor = ActorTemplate;
		Zombies = {};
	};
end

for i, Model in ZombiesFolderArray do
	--> Split the zombies into chunks
	local ChunkData = ZombieChunks[math.ceil(i/ZombieChunkSize)];

	ChunkData.Actor:SendMessage('AddZombie', Model);

	table.insert(
		ZombieChunks[math.ceil(i/ZombieChunkSize)].Zombies,
		Model
	);
end

-- task.delay(1, function()
-- 	for _, Chunk in ZombieChunks do
-- 		RunService.RenderStepped:Connect(function()
-- 			for _,v in Chunk.Zombies do
-- 				v:Step();
-- 			end
-- 		end)
-- 	end
-- end)

while true do
	local nodeId = Pathfinder:FindNearestNode(CurrentPlrChar.HumanoidRootPart.Position);

	if (nodeId ~= CurrentPlayerNode) then
		CurrentPlayerNode = nodeId;

		for _, Chunk in ZombieChunks do
			Chunk.Actor:SendMessage('UpdatePlayerNode', nodeId);
		end
	end

	task.wait(1)
end