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

end

function Zombie:ChangeTargetNode(NodeId)
	self.TargetNode = NodeId;

	if (not self.InView) then
		self:UpdatePath();
	end
end

function Zombie:UpdatePath() end

return Zombie;