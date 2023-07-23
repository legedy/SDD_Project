local Players = game:GetService('Players');
local CurrentPlrChar, CurrentPlayerNode = Players.PlayerAdded:Wait().CharacterAdded:Wait(), nil;

local Pathfinder = require(script.Pathfinder);
Pathfinder:Init();

local ZombiesFolder = workspace.Zombies;
local ZombiesData = {};

for _,v in ZombiesFolder:GetChildren() do
	table.insert(ZombiesData, {
		Model = v,
		PathIter = 1,
		Path = {}
	})
end

while task.wait(1) do
	local _, nodeId = Pathfinder:FindNearestNode(CurrentPlrChar.HumanoidRootPart.Position);

	if (nodeId ~= currentPlayerNode) then
		currentPlayerNode = nodeId;
		
		currentIter, path = 1, Pathfinder:FindPath(script.Parent.HumanoidRootPart.Position, currentPlayerNode);
	end
end