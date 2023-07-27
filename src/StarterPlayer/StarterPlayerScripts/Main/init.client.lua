local Players = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage');
local CurrentPlayer = Players.LocalPlayer;
local CurrentPlrChar, CurrentPlayerNode = CurrentPlayer.CharacterAdded:Wait(), 1;

local MainGUI = CurrentPlayer.PlayerGui:WaitForChild('MainGUI');
local RoundText = MainGUI.Round;

local HumanoidRootPart = CurrentPlrChar:WaitForChild('HumanoidRootPart');

local ZombieSpawns = workspace.ZombieSpawns:GetChildren();
local ZombieTemplate = ReplicatedStorage.Zombie;

--// Sounds
local Sounds = workspace.Sounds;
local MaxAmmoSound = Sounds.MaxAmmo;
local DoublePointsSound = Sounds.DoublePoints;
local RoundEnd = Sounds.RoundEnd;
local RoundStart = Sounds.RoundStart;

local WalkingAnim = script:WaitForChild('Walking');
local WakeupAnim = script:WaitForChild('Wakeup');

local MaxAmmoEvent: BindableEvent = ReplicatedStorage.Bindables:WaitForChild('MaxAmmo');

CurrentPlayer.CameraMode = Enum.CameraMode.LockFirstPerson;

local RollPowerUps = require(script.PowerUps);
local Pathfinder = require(script.Pathfinder);
local AllNodes, BakedPaths = Pathfinder:Init();

local ZombiesFolder = workspace.Zombies;
local ZombieChunkSize = 5;
local ZombieChunks: {
	[number]: {
		Actor: Actor;
		Zombies: {}
	}
} = {};

local Points = 500;
local Round = 1;

for i = 1, 5 do
	local ActorTemplate = script.Actor:Clone();
	ActorTemplate.Parent = script.Threads;
	ActorTemplate.Script.Enabled = true;

	ActorTemplate:SendMessage('Initialize',
		CurrentPlrChar:WaitForChild('HumanoidRootPart'),
		AllNodes,
		BakedPaths
	);
	ActorTemplate:SendMessage('InitializeLoop', 0.5);

	ZombieChunks[i] = {
		Actor = ActorTemplate;
		Zombies = {};
	};
end

task.spawn(function()
	while task.wait(1) do
		local nodeId = Pathfinder:FindNearestNode(CurrentPlrChar.HumanoidRootPart.Position);

		if (nodeId ~= CurrentPlayerNode) then
			CurrentPlayerNode = nodeId;

			for _, Chunk in ZombieChunks do
				Chunk.Actor:SendMessage('UpdatePlayerNode', nodeId);
			end
		end
	end
end)

task.wait(5);

while task.wait() do
	RoundText.Text = Round;
	RoundStart:Play();
	local AliveZombies = 0;
	local ZombiesToSpawn = math.min(math.floor(
		0.09 * Round^2 - 0.0029 * Round + 23.9580
	), 100);

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

	local RoundHealth = if (Round < 10) then (50 + 100 * Round) else (950 * 1.1^(Round - 9));
	local SpawnDelay = math.max(2 * 0.95^Round-1, 0.1);

	print('ROUND: '..Round)
	print(ZombiesToSpawn)
	while ZombiesToSpawn > 0 do

		AliveZombies += 1;
		ZombiesToSpawn -= 1;
		local NewZombie = ZombieTemplate:Clone();
		NewZombie.Humanoid.WalkSpeed = 0;
		NewZombie.Humanoid.MaxHealth = RoundHealth;
		NewZombie.Humanoid.Health = RoundHealth;
		NewZombie.Parent = ZombiesFolder;

		NewZombie:PivotTo(CFrame.new(
			ZombieSpawns[math.random(1, #ZombieSpawns)].Position
		));

		local WakeupAnimTrack = NewZombie.Humanoid.Animator:LoadAnimation(WakeupAnim);
		local WalkAnimTrack = NewZombie.Humanoid.Animator:LoadAnimation(WalkingAnim);

		WakeupAnimTrack:Play();
		WakeupAnimTrack.Stopped:Connect(function()
			NewZombie.Humanoid.WalkSpeed = 4;
		end)

		NewZombie.Humanoid.Running:Connect(function(speed)
			if speed > 0 then
				if not WalkAnimTrack.IsPlaying then
					WalkAnimTrack:Play()
				end
			else
				if WalkAnimTrack.IsPlaying then
					WalkAnimTrack:Stop()
				end
			end
		end)

		for _, Chunk in ZombieChunks do
			if (#Chunk.Zombies < ZombieChunkSize) then --> If this chunk has space then
				for i = 1, 5 do
					local ZombieExist = Chunk.Zombies[i];

					if (not ZombieExist) then --> If this spot is empty
						Chunk.Zombies[i] = NewZombie;

						NewZombie.Humanoid.Died:Connect(function()
							AliveZombies -= 1;
							Chunk.Zombies[i] = nil;

							RollPowerUps(NewZombie.Torso.Position, HumanoidRootPart, function(SelectedPowerUp)
								if (SelectedPowerUp == 'DoublePoints') then
									DoublePointsSound:Play();
								elseif (SelectedPowerUp == 'MaxAmmo') then
									MaxAmmoEvent:Fire();
									MaxAmmoSound:Play();
								end
							end)
						end)

						break;
					end
				end
				
				Chunk.Actor:SendMessage('AddZombie', NewZombie);
				break;
			end
		end
		
		repeat task.wait(SpawnDelay) until AliveZombies < 25;
	end

	repeat task.wait() until AliveZombies == 0;
	RoundEnd:Play();
	RoundEnd.Ended:Wait();
	Round += 1;
end