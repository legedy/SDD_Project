local Actor = script:GetActor();

local RunService = game:GetService('RunService');
local ZombieClass = require(script.Parent.Parent.Parent.Zombie);

local TargetBasePart = nil;
local AllNodes, BakedPaths = {}, {};
local ActorZombies = {};

local function FindNearestNode(Position)
	local dist, nearestId = math.huge, nil
	for NodeId, NodePos in AllNodes do
		local d = (Position - NodePos).Magnitude
		if (d < dist) then
			dist, nearestId = d, NodeId;
		end
	end
	return nearestId
end

local function FindBakedPath(startPosition: Vector3 | number, goalPosition: Vector3 | number)
	local startNode = if (typeof(startPosition) == "Vector3") then FindNearestNode(startPosition) else startPosition

	return BakedPaths[startNode][goalPosition]
end

Actor:BindToMessage('Initialize', function(TargetBasePartParam, AllNodesParam, BakedPathsParam)
	TargetBasePart = TargetBasePartParam;
	AllNodes, BakedPaths = AllNodesParam, BakedPathsParam;
end)

Actor:BindToMessage('InitializeLoop', function()
	RunService.RenderStepped:ConnectParallel(function()
		local ComputedGoalPos = {};

		for i, Zombie in ActorZombies do
			ComputedGoalPos[i] = Zombie:Step();
			print(ComputedGoalPos[i])
		end

		task.synchronize();

		for i, Zombie in ActorZombies do
			if (not ComputedGoalPos[i]) then continue end
			Zombie.Humanoid:MoveTo(ComputedGoalPos[i]);
		end
	end)
end)

Actor:BindToMessage('UpdatePlayerNode', function(NodeId)
	for _, Zombie in ActorZombies do
		Zombie:ChangeTargetNode(NodeId);
	end
end)

Actor:BindToMessage('AddZombie', function(Zombie)
	local ZombieObj = ZombieClass.new(Zombie);
	ZombieObj:Init(TargetBasePart);

	ZombieObj.UpdatePath = function()
		ZombieObj.PathIter, ZombieObj.Path = 1, FindBakedPath(
			ZombieObj.HumanoidRootPart.Position,
			ZombieObj.TargetNode
		);

		print(ZombieObj.Path)
	end

	ActorZombies[Zombie] = ZombieObj;
end)

Actor:BindToMessage('RemoveZombie', function(Zombie)
	ActorZombies[Zombie]:DelayDestroy();
	ActorZombies[Zombie] = nil;
end)