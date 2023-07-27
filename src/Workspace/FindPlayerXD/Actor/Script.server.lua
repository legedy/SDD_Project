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

Actor:BindToMessage('InitializeLoop', function(IterationDelay)
	local t = 0;

	RunService.RenderStepped:ConnectParallel(function(deltaTime)
		if (t < IterationDelay) then t = 0 else return end

		local ComputedGoalPos = {};

		for i, Zombie in ActorZombies do
			ComputedGoalPos[i] = Zombie:Step();
		end

		task.synchronize();

		for i, Zombie in ActorZombies do
			if (not ComputedGoalPos[i]) then continue end
			Zombie.Humanoid:MoveTo(ComputedGoalPos[i]);
		end

		t += deltaTime;
	end)
end)

Actor:BindToMessage('UpdatePlayerNode', function(NodeId)
	for _, Zombie in ActorZombies do
		Zombie:ChangeTargetNode(NodeId);
	end
end)

Actor:BindToMessage('AddZombie', function(Zombie)
	--[[
		Zombies start with 150 health on Round 1,
		and gain 100 health every round until
		round 9. Upon reaching round 10, their
		health is given a 1.1 multiplier every round.

		For example, a zombie has 550 health on
		Round 5, 1045 on Round 10, 2710 on
		Round 20, 47295 on Round 50 and 5552108
		on Round 100.
	]]

	local ZombieObj = ZombieClass.new(Zombie);
	ZombieObj:Init(TargetBasePart);

	ZombieObj.UpdatePath = function()
		ZombieObj.PathIter, ZombieObj.Path = 1, FindBakedPath(
			ZombieObj.HumanoidRootPart.Position,
			ZombieObj.TargetNode
		);
	end

	ZombieObj.Humanoid.Died:Connect(function()
		ZombieObj:DelayDestroy();
		ActorZombies[Zombie] = nil;
	end)

	ActorZombies[Zombie] = ZombieObj;
end)

Actor:BindToMessage('RemoveZombie', function(Zombie)
	ActorZombies[Zombie]:DelayDestroy();
	ActorZombies[Zombie] = nil;
end)