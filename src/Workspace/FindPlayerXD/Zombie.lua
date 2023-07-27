local RemoveY = Vector3.new(1, 0, 1);

local RayParams = RaycastParams.new();
RayParams.FilterType = Enum.RaycastFilterType.Include;

local Zombie = {};
Zombie.__index = Zombie;
local TargetInstance = nil;

function Zombie.new(Model)
	local self = setmetatable({}, Zombie);

	self.TargetNode = 1;

	self.Object = Model;
	self.Humanoid = Model:WaitForChild('Humanoid');
	self.HumanoidRootPart = Model:WaitForChild('HumanoidRootPart');

	self.InView = false; --> Overrides the path following to follow them directly
	self.PathIter = 1;
	self.Path = {};

	return self;
end

function Zombie:Init(TargetBasePart)
	--> Animate the zombie
	RayParams.FilterDescendantsInstances = {TargetBasePart, workspace.Karachi};
	TargetInstance = TargetBasePart;

	self.Humanoid.Died:Connect(function()
		self:DelayDestroy();
	end);

	print('initialized')
end

function Zombie:Step()
	local CurrentPlayerPos = TargetInstance.Position;
	local CurrentZombiePos = self.HumanoidRootPart.Position;

	local RayResult = workspace:Raycast(
		CurrentZombiePos,
		CurrentPlayerPos - CurrentZombiePos,
		RayParams
	);

	local GoalPos;

	--> If Player is in view
	if (RayResult and RayResult.Instance == TargetInstance) then
		GoalPos = CurrentPlayerPos;
		self.InView = true;
	else
		if (self.InView) then
			self:UpdatePath();
		end

		local ClosestNode = self.Path[self.PathIter];

		if (((CurrentZombiePos*RemoveY) - (ClosestNode*RemoveY)).Magnitude >= 1) then
			GoalPos = ClosestNode;
		else
			if (self.PathIter >= #self.Path and #self.Path > 0) then
				self.PathIter, self.Path = 1, {};
			end

			self.PathIter += 1;
		end

		self.InView = false;
	end

	return GoalPos, self.PathIter;
end

--> Puts the zombie into ragdoll state with no functionability and it slowly fades away
function Zombie:DelayDestroy()
	self.Step = nil;
	self.ChangeTargetNode = nil;
	self.UpdatePath = nil;

	--> Ragdoll the zombie
	for _, v in self.Object:GetDescendants() do
		if (v:IsA('BasePart')) then
			v.CanCollide = true
			if (v.Name == 'Head') then
				v:ApplyImpulse(-v.CFrame.LookVector*25);
			end
		end

		if ((v:IsA('Motor6D') and v.Name == 'Torso') or v.Name == 'HumanoidRootPart') then
			return v:Destroy();
		end

		if v:IsA("Motor6D") then
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame = v.C0
			a1.CFrame = v.C1
			a0.Parent = v.Part0
			a1.Parent = v.Part1
			
			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Parent = v.Part0
			
			v:Destroy()
		end
	end

end

function Zombie:ChangeTargetNode(NodeId)
	self.TargetNode = NodeId;

	if (not self.InView) then
		self:UpdatePath();
	end
end

function Zombie:UpdatePath() end

return Zombie;