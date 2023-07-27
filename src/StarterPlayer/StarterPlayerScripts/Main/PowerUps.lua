local ReplicatedStorage = game:GetService('ReplicatedStorage');
local RunService = game:GetService('RunService');

local MaxAmmo = ReplicatedStorage.MaxAmmo;
local DoublePoints = ReplicatedStorage.DoublePoints;

local AllPowerUps = {
	MaxAmmo,
	DoublePoints
};

return function(Position, HRP, CallBack)
	--> 4% chance to spawn a powerup
	local CanDrop = math.random(1, 100) <= 4;

	if (not CanDrop) then return end

	local PowerUp = AllPowerUps[math.random(1, #AllPowerUps)]:Clone();
	PowerUp.PrimaryPart.powerup:Play();
	PowerUp:PivotTo(CFrame.new(Position));
	PowerUp.Parent = workspace;

	local Time = 0;
	local Connection; Connection = RunService.RenderStepped:Connect(function(deltaTime)
		Time += deltaTime;

		if (HRP.Position - Position).Magnitude <= 5 then
			CallBack(PowerUp.Name);
			PowerUp:Destroy();
			Connection:Disconnect();
		end

		if (Time >= 30) then
			PowerUp:Destroy();
			Connection:Disconnect();
		end
	end)
end