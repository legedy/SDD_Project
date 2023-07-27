repeat
	task.wait();
until game.Players.LocalPlayer.Character
task.wait(0.5);

--// Variables
local Gun = script.Parent;
local Player = game.Players.LocalPlayer;
local Character = Player.Character;
local Mouse = Player:GetMouse();
local Camera = workspace.CurrentCamera;

local Rand = Random.new();

local Humanoid = Character:WaitForChild('Humanoid');
local RightArm = Character:WaitForChild('Right Arm');
local LeftArm = Character:WaitForChild('Left Arm');

--// Weapon Parts
local AimPart = Gun:WaitForChild('AimPart');
local Grip = Gun:WaitForChild('Grip');
local FirePart = Gun:WaitForChild('FirePart');
local Mag = Gun:WaitForChild('Mag');
local Bolt = Gun:WaitForChild('Bolt');

--// Services
local UIS = game:GetService('UserInputService');
local RunService = game:GetService('RunService');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local RenderStep = RunService.RenderStepped;

--// Declarables
local L_15_ = false;

local GunResources = Gun:WaitForChild('Resource');
local Effects = GunResources:WaitForChild('FX');
local Modules = GunResources:WaitForChild('Modules');
local SettingsModules = GunResources:WaitForChild('SettingsModule');

local MaxAmmoEvent: BindableEvent = ReplicatedStorage.Bindables:WaitForChild('MaxAmmo');

local ClientConfig = require(SettingsModules:WaitForChild("ClientConfig"));
local SpringModule = require(Modules:WaitForChild("Spring"));

-- local MainGUI = HUD:WaitForChild('MainGui'):Clone();
-- MainGUI.Parent = Player.PlayerGui;

local MainGUI = Player.PlayerGui:WaitForChild('MainGUI');

--// New gui
local InfoFrame = MainGUI:WaitForChild('InfoFrame');
local AmmoFrame = InfoFrame:WaitForChild('AmmoFrame');
local Ammo = AmmoFrame:WaitForChild('Ammo');
local MagAmmo = AmmoFrame:WaitForChild('MagAmmo');
local Title = InfoFrame:WaitForChild('Title');
local HitMarker: ImageLabel = MainGUI:WaitForChild('HitMarker');

--// SETUP
function Weld(Part0, Part1, Offset)
	local Motor = Instance.new("Motor6D", Part0);
	Motor.Part0 = Part0;
	Motor.Part1 = Part1;
	Motor.Name = Part0.Name;
	Motor.C0 = Offset or Part0.CFrame:inverse() * Part1.CFrame;
	return Motor;
end

local Arms = Instance.new("Model");
Arms.Name = Gun.Name.."Arms";
Arms.Parent = Camera;

local CameraRoot = Instance.new("Part");
CameraRoot.Name = "CameraRoot";
CameraRoot.FormFactor = "Custom";
CameraRoot.Position = Vector3.new(0, 0, 0);
CameraRoot.Size = Vector3.new(0.2, 0.2, 0.2);
CameraRoot.Transparency = 1;
CameraRoot.Anchored = true;
CameraRoot.CanCollide = false;
CameraRoot.Parent = Arms;
Arms.PrimaryPart = CameraRoot;

local AnimBase = Instance.new("Part");
AnimBase.FormFactor = "Custom";
AnimBase.CanCollide = false;
AnimBase.Transparency = 1;
AnimBase.Anchored = false;
AnimBase.Name = "AnimBase";
AnimBase.Parent = Arms;

local AnimBaseW = Instance.new("Motor6D");
AnimBaseW.Part0 = AnimBase;
AnimBaseW.Part1 = CameraRoot;
AnimBaseW.Name = "AnimBaseW";
AnimBaseW.Parent = AnimBase;

local ViewmodelHumanoid = Instance.new("Humanoid");
ViewmodelHumanoid.MaxHealth = 0;
ViewmodelHumanoid.Health = 0;
ViewmodelHumanoid.Name = "";
ViewmodelHumanoid.Parent = Arms;

--// Right Arm Setup
local RightArmClone = RightArm:Clone();
RightArmClone.Name = "Right Arm";
RightArmClone.FormFactor = "Custom";
RightArmClone.Size = Vector3.new(0.8, 2.5, 0.8);
RightArmClone.Transparency = 0.0;
RightArmClone.Parent = Arms;

local RightArmW = Instance.new("Motor6D");
RightArmW.Name = 'RightArmMotor';
RightArmW.Part0 = AnimBase;
RightArmW.Part1 = RightArmClone;
RightArmW.C1 = ClientConfig.RightArmPos;
RightArmW.Parent = AnimBase;

local LeftArmClone = LeftArm:Clone();
LeftArmClone.Name = "Left Arm";
LeftArmClone.FormFactor = "Custom";
LeftArmClone.Size = Vector3.new(0.8, 2.5, 0.8);
LeftArmClone.Transparency = 0.0;
LeftArmClone.Parent = Arms;

local LeftArmW = Instance.new("Motor6D");
LeftArmW.Name = 'LeftArmMotor';
LeftArmW.Part0 = AnimBase;
LeftArmW.Part1 = LeftArmClone;
LeftArmW.C1 = ClientConfig.LeftArmPos;
LeftArmW.Parent = AnimBase;

local GripJoint = Instance.new("Motor6D");
GripJoint.Name = 'GripJoint';
GripJoint.Part0 = RightArmClone;
GripJoint.Part1 = Grip;
GripJoint.C1 = ClientConfig.GunPos;
GripJoint.Parent = RightArmClone;

for _, GunChild in Gun:GetChildren() do
	if GunChild:IsA("Part") or GunChild:IsA("MeshPart") or GunChild:IsA("UnionOperation") then
		GunChild.Anchored = true
		
		if GunChild.Name ~= "Grip" and GunChild.Name ~= "Bolt" and GunChild.Name ~= 'Lid' then
			Weld(GunChild, Gun:WaitForChild("Grip"))
		end
		
		if GunChild.Name == "Bolt" then
			if Gun:FindFirstChild('BoltHinge') then
				Weld(GunChild, Gun:WaitForChild("BoltHinge"))
			else
				Weld(GunChild, Gun:WaitForChild("Grip"))
			end
		end;
		
		if GunChild.Name == "Lid" then
			if Gun:FindFirstChild('LidHinge') then
				Weld(GunChild, Gun:WaitForChild("LidHinge"))
			else
				Weld(GunChild, Gun:WaitForChild("Grip"))
			end
		end
	end
end

for _, GunChild in Gun:GetChildren() do
	if GunChild:IsA("Part") or GunChild:IsA("MeshPart") or GunChild:IsA("UnionOperation") then
		GunChild.Anchored = false
		GunChild.Parent = Arms;
	end
end

-- local NeckClone;
local BoltMotor;

local CurrentAimZoom = ClientConfig.AimZoom;

local MouseSens = ClientConfig.MouseSensitivity;
local MouseDeltaSens = UIS.MouseDeltaSensitivity;

--// States
local IsAiming = false;
local IsReloading = false;
local IsSprinting = false;
local Mouse1Holding = false;
local CanShoot = true;
local IsSprintKeyDown = false;
local CanSprint = false;
local isIdle = false;

local CurrentGunRecoil;
local CurrentCamRecoil;
local CurrentKickback;

local CurrentCamShake;

local FireType = ClientConfig.FireMode;
local CurrentFOV = 70;

local DebrisFolder = Instance.new("Folder");
DebrisFolder.Name = "BulletModel: " .. Player.Name;
DebrisFolder.Parent = workspace;

local AmmoInMag = ClientConfig.Ammo
local TotalAmmo = ClientConfig.StoredAmmo * ClientConfig.MagCount

local RayParams = RaycastParams.new();
RayParams.FilterType = Enum.RaycastFilterType.Exclude;
RayParams.FilterDescendantsInstances = {
	Character,
	DebrisFolder,
	Camera
};

--// Math
local LeanOffset = CFrame.Angles(0, 0, 0)

local function UpdateAmmo()
	MagAmmo.Text = AmmoInMag;
	Ammo.Text = TotalAmmo;
end

MaxAmmoEvent.Event:Connect(function()
	TotalAmmo = ClientConfig.StoredAmmo * ClientConfig.MagCount
	UpdateAmmo()
end)

Gun.Equipped:Connect(function()
	Title.Text = Gun.Name
	UpdateAmmo()
	
	BoltMotor = Bolt.Bolt
	
	UIS.MouseIconEnabled = false
	Camera.FieldOfView = 70
	L_15_ = true
end)

Gun.Unequipped:Connect(function()
	L_15_ = false

	IsAiming = false
	IsSprinting = false
	IsReloading = false
	Shooting = false
	
	CurrentFOV = 70
	Camera.FieldOfView = 70
	Arms:PivotTo(CFrame.new())

	CanShoot = true
	
	UIS.MouseIconEnabled = true
	UIS.MouseDeltaSensitivity = MouseDeltaSens
end)

--// Firemode Functions
local function FireRaycast(BulletSpread)
	local RandomAngle = CFrame.Angles(
		math.rad(Rand:NextNumber(-BulletSpread, BulletSpread)),
		math.rad(Rand:NextNumber(-BulletSpread, BulletSpread)),
		math.rad(Rand:NextNumber(-BulletSpread, BulletSpread))
	);
	
	local RandomDirection = CFrame.lookAt(
		Camera.CFrame.Position,
		Camera.CFrame.Position + (RandomAngle * Camera.CFrame.LookVector)
	);

	local RayHit = workspace:Raycast(
		Camera.CFrame.Position,
		RandomDirection.LookVector * 200,
		RayParams
	);

	if (RayHit) then
		local RayHitInstance = RayHit.Instance;
		local Humanoid = RayHitInstance.Parent:FindFirstChild('Humanoid');

		if (Humanoid) then
			if (RayHitInstance.Name == 'Head') then
				HitMarker.ImageColor3 = Color3.fromRGB(255, 50, 50);
				HitMarker.Visible = true

				Humanoid:TakeDamage(ClientConfig.BaseDamage * ClientConfig.HeadshotMultiplier);
			elseif (RayHitInstance.Name == 'HumanoidRootPart' or RayHitInstance.Name == 'Torso') then
				HitMarker.ImageColor3 = Color3.fromRGB(255, 255, 255);
				HitMarker.Visible = true

				Humanoid:TakeDamage(ClientConfig.BaseDamage);
			else
				HitMarker.ImageColor3 = Color3.fromRGB(255, 255, 255);
				HitMarker.Visible = true

				Humanoid:TakeDamage(ClientConfig.BaseDamage * ClientConfig.LimbshotMultiplier);
			end

			if (Humanoid.Health <= 0) then
				RayHitInstance:ApplyImpulse(RandomDirection.LookVector * 100)
			end
		end

		task.delay(0.05, function()
			HitMarker.Visible = false
		end)
	end
end

function fireSemi()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		
		FirePart:WaitForChild('Fire'):Play()
		AmmoInMag = AmmoInMag - 1
		UpdateAmmo()
		RecoilFront = true
		
		FireRaycast(ClientConfig.BulletSpread);
		
		if ClientConfig.CanBolt == true then
			BoltingBackAnim()
			task.delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if AmmoInMag > 0 then
						BoltingForwardAnim()
					end
				end
			end)
		end
		
		task.delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)
		
		task.wait(ClientConfig.Firerate)
		CanShoot = true
		Shooting = false
	end
end

function fireAuto()
	while not Shooting and AmmoInMag > 0 and Mouse1Holding and CanShoot and L_15_ do
		CanShoot = false
		Recoiling = true

		FirePart:WaitForChild('Fire'):Play()
		AmmoInMag = AmmoInMag - 1
		UpdateAmmo()
		Shooting = true
		RecoilFront = true

		FireRaycast(ClientConfig.BulletSpread);
					
		for _, L_261_forvar2 in pairs(FirePart:GetChildren()) do
			if L_261_forvar2.Name:sub(1, 7) == "FlashFX" then
				L_261_forvar2.Enabled = true
			end
		end
	
		task.delay(1 / 30, function()
			for _, L_263_forvar2 in pairs(FirePart:GetChildren()) do
				if L_263_forvar2.Name:sub(1, 7) == "FlashFX" then
					L_263_forvar2.Enabled = false
				end
			end
		end)
		
		if ClientConfig.CanBolt == true then
			BoltingBackAnim()
			task.delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if AmmoInMag > 0 then
						BoltingForwardAnim()
					end
				end
			end)
		end
		
		
		task.delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)
		task.wait(ClientConfig.Firerate)
		
		CanShoot = true
		Shooting = false
	end
end

function Shoot()
	if L_15_ and CanShoot then
		if FireType == 1 then
			fireSemi()
		elseif FireType == 2 then
			fireAuto()
		end
	end
end

--// Walk and Sway
local SwayX = 0
local SwayY = 0
local SwayDeltaLimit = 35 --This is the limit of the mouse input for the sway
local UnaimedSway = -9 --This is the Magnitude of the sway when you're unaimed
local AimedSway = -9 --This is the Magnitude of the sway when you're aimed

local SwaySpring = SpringModule.new(Vector3.new())
SwaySpring.s = 15
SwaySpring.d = 0.5

game:GetService("UserInputService").InputChanged:Connect(function(InputObject) --Get the mouse delta for the gun sway
	if InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		SwayX = math.min(math.max(InputObject.Delta.X, -SwayDeltaLimit), SwayDeltaLimit)
		SwayY = math.min(math.max(InputObject.Delta.Y, -SwayDeltaLimit), SwayDeltaLimit)
	end
end)

Mouse.Idle:Connect(function() --Reset the sway to 0 when the mouse is still
	SwayX = 0
	SwayY = 0
end)

local IsMoving = false
local RecoilAddition = CFrame.new()

local IdleBobbleTime = 0
local IdleBobbleSize = 0.05
local IdleBobbleSpeed = 2

local BobbleTime = 0
local BobbleSize = 0.09
local BobbleSpeed = 11

local AnimBaseC0 = AnimBaseW.C0

local function CalculateSwayCFrame()
	SwaySpring.t = Vector3.new(SwayX, SwayY, 0);
	local SwaySpringPosition = SwaySpring.p;
	local SwayFinalX = SwaySpringPosition.X / SwayDeltaLimit * (IsAiming and AimedSway or UnaimedSway);
	local SwayFinalY = SwaySpringPosition.Y / SwayDeltaLimit * (IsAiming and AimedSway or UnaimedSway);

	if (IsAiming) then
		return CFrame.Angles(
			math.rad(-SwayFinalX),
			math.rad(SwayFinalX),
			math.rad(SwayFinalY)
		) * CFrame.fromAxisAngle(
			Vector3.new(5, 0, -1),
			math.rad(SwayFinalX)
		);
	end

	return CFrame.Angles(
		math.rad(-SwayFinalY),
		math.rad(-SwayFinalX),
		math.rad(-SwayFinalX)
	) * CFrame.fromAxisAngle(
		AnimBase.Position,
		math.rad(-SwayFinalY)
	);
end

local function CalculateBobbleCFrame(deltaTime)
	local BobbingCFrame = CFrame.new();

	if IsMoving then
		BobbleTime += deltaTime;
		BobbingCFrame = CFrame.new(
			(math.sin(BobbleTime * BobbleSpeed / 2) * BobbleSize),
			(math.sin(BobbleTime * BobbleSpeed) * BobbleSize),
			0.02
		) * CFrame.Angles(
			(math.cos(BobbleTime * BobbleSpeed) * BobbleSize),
			(math.cos(BobbleTime * BobbleSpeed / 2) * BobbleSize),
			0
		);
	else --> Reset sway
		BobbleTime = 0;
	end

	return BobbingCFrame;
end

local function CalculateIdleBobbleCFrame(deltaTime)
	local IdleBobbingCFrame = CFrame.new();
	
	if (IsAiming) then
		IdleBobbleTime = 0;
	else
		IdleBobbleTime += deltaTime;
		IdleBobbingCFrame = CFrame.new(
			(math.sin(IdleBobbleTime * IdleBobbleSpeed / 2) * IdleBobbleSize),
			(math.cos(IdleBobbleTime * IdleBobbleSpeed) * IdleBobbleSize),
			0.02
		);
	end

	return IdleBobbingCFrame;
end

local function Reload()
	if TotalAmmo > 0 and AmmoInMag < ClientConfig.Ammo then
		Shooting = false
		IsReloading = true
		
		ReloadAnim()

		if AmmoInMag <= 0 then
			--> If total ammo doesn't fill the mag
			if (TotalAmmo - (ClientConfig.Ammo - AmmoInMag)) < 0 then
				AmmoInMag = AmmoInMag + TotalAmmo
				TotalAmmo = 0
			else --> If total ammo fills the mag
				TotalAmmo = TotalAmmo - (ClientConfig.Ammo - AmmoInMag)
				AmmoInMag = ClientConfig.Ammo
			end
		elseif AmmoInMag > 0 then
			if (TotalAmmo - (ClientConfig.Ammo - AmmoInMag)) < 0 then
				AmmoInMag = AmmoInMag + TotalAmmo + 1
				TotalAmmo = 0
			else
				TotalAmmo = TotalAmmo - (ClientConfig.Ammo - AmmoInMag)
				AmmoInMag = ClientConfig.Ammo
			end
		end

		IdleAnim()

		CanShoot = true

		IsReloading = false
		if not isIdle then
			CanShoot = true
		end
	end;
end

Character.Humanoid.Running:Connect(function(Speed)
	IsMoving = (Speed > 1)
end)

RenderStep:Connect(function(deltaTime)
	if L_15_ then
		Camera.CFrame = Camera.CFrame:Lerp(Camera.CFrame * RecoilAddition, 0.3)
		Camera.FieldOfView = Camera.FieldOfView * (1 - ClientConfig.ZoomSpeed) + (CurrentFOV * ClientConfig.ZoomSpeed)
		
		--> Sway
		AnimBaseW.C0 = AnimBaseW.C0:Lerp(
			AnimBaseC0 *
			CalculateSwayCFrame() *
			CalculateBobbleCFrame(deltaTime) *
			CalculateIdleBobbleCFrame(deltaTime),
			0.1
		)
		
		--> If sprinting, lower the gun to hip
		if IsSprinting and CanSprint and not IsAiming and not IsReloading and not Shooting then
			AnimBaseW.C1 = AnimBaseW.C1:Lerp(
				AnimBaseW.C0 * ClientConfig.SprintPos,
				0.1
			);

		--> If not then position it back to normal
		elseif not IsSprinting and not CanSprint and not IsAiming and not IsReloading and not Shooting then
			AnimBaseW.C1 = AnimBaseW.C1:Lerp(
				CFrame.new() * LeanOffset,
				0.15
			);
		end
		
		
		if IsAiming and not IsSprinting then
			CurrentCamRecoil = ClientConfig.AimCamRecoil;
			CurrentGunRecoil = ClientConfig.AimGunRecoil;
			CurrentKickback = ClientConfig.AimKickback;

			CurrentCamShake = ClientConfig.AimCamShake;
			
			AnimBaseW.C1 = AnimBaseW.C1:Lerp(
				AnimBaseW.C0 * AimPart.CFrame:toObjectSpace(AnimBase.CFrame),
				ClientConfig.AimSpeed
			);
			
			UIS.MouseDeltaSensitivity = MouseSens;
		elseif not IsAiming and not IsSprinting then
			CurrentCamRecoil = ClientConfig.CamRecoil;
			CurrentGunRecoil = ClientConfig.GunRecoil;
			CurrentKickback = ClientConfig.Kickback;

			CurrentCamShake = ClientConfig.CamShake;

			AnimBaseW.C1 = AnimBaseW.C1:Lerp(
				CFrame.new() * LeanOffset,
				ClientConfig.UnaimSpeed
			);
			
			UIS.MouseDeltaSensitivity = MouseDeltaSens;
		end
		
		if Recoiling then
			-->
			RecoilAddition = CFrame.fromEulerAnglesXYZ(
				math.rad(CurrentCamRecoil * Rand:NextNumber(0, CurrentCamShake)),
				math.rad(CurrentCamRecoil * Rand:NextNumber(-CurrentCamShake, CurrentCamShake)),
				math.rad(CurrentCamRecoil * Rand:NextNumber(-CurrentCamShake, CurrentCamShake))
			);

			AnimBaseW.C0 = AnimBaseW.C0:Lerp(
				AnimBaseW.C0 * CFrame.new(0, 0, CurrentGunRecoil) *
				CFrame.Angles(-math.rad(CurrentKickback), 0, 0),
				0.3
			);
		else
			RecoilAddition = CFrame.Angles(0, 0, 0);
			AnimBaseW.C0 = AnimBaseW.C0:Lerp(
				CFrame.new(),
				0.2
			);
		end
		
		CameraRoot.CFrame = Camera.CFrame;
		-- NeckClone.C0 = HRP.CFrame:toObjectSpace(
		-- 	HRP.CFrame *
		-- 	CFrame.new(0, 1.5, 0) *
		-- 	CFrame.new(Humanoid.CameraOffset)
		-- );
		-- NeckClone.C1 = CFrame.Angles(-math.asin(Camera.CFrame.LookVector.Y), 0, 0);
		UIS.MouseIconEnabled = false;
	end
end)

--// Input Connections
UIS.InputBegan:Connect(function(Input, GPE)
	if not GPE and L_15_ then
		if (Input.UserInputType == Enum.UserInputType.MouseButton2 and
			not IsReloading and
			not IsSprinting)
		then
			if not IsAiming then
				BobbleSize = 0.015
				BobbleSpeed = 7
				Humanoid.WalkSpeed = 7
				
				CurrentFOV = CurrentAimZoom
				IsAiming = true
			end
		end;
		
		if Input.KeyCode == Enum.KeyCode.A then
			LeanOffset = CFrame.Angles(0, 0, 0.1)
		end;
		
		if Input.KeyCode == Enum.KeyCode.D then
			LeanOffset = CFrame.Angles(0, 0, -0.1)
		end;
		
		if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.E) and
			CanShoot and
			not IsReloading and
			not IsSprinting
		) then
			Mouse1Holding = true;

			if (not Shooting and AmmoInMag > 0) then
				Shoot();
			end
		end;
		
		if (Input.KeyCode == Enum.KeyCode.LeftShift and IsMoving) then
			IsSprintKeyDown = true

			if (not IsSprinting and IsSprintKeyDown) then
				Shooting = false
				IsAiming = false
				IsSprinting = true
						
				task.delay(0, function()
					if IsSprinting and not IsReloading then
						IsAiming = false
						CanSprint = true
					end
				end)
				CurrentFOV = 80

				BobbleSize = 0.4
				BobbleSpeed = 16
				Character.Humanoid.WalkSpeed = ClientConfig.SprintSpeed
			end
		end;
		
		if (Input.KeyCode == Enum.KeyCode.R and
			not IsReloading and
			not IsAiming and
			not Shooting and
			not IsSprinting
		) then
			Reload();
		end;

		UpdateAmmo()
	end
end)

UIS.InputEnded:Connect(function(Input, GPE)
	if not GPE and L_15_ then
		if (Input.UserInputType == Enum.UserInputType.MouseButton2) then
			if IsAiming then --> Return back to normal unaimed position
				Humanoid.WalkSpeed = 16;
				BobbleSize = 0.09;
				BobbleSpeed = 11;

				CurrentFOV = 70;
				IsAiming = false;
			end
		end;
		
		if (Input.KeyCode == Enum.KeyCode.A or Input.KeyCode == Enum.KeyCode.D) then
			LeanOffset = CFrame.Angles(0, 0, 0)
		end;
		
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.E) then
			Mouse1Holding = false
			if Shooting then
				Shooting = false
			end
		end;
		
		if (Input.KeyCode == Enum.KeyCode.LeftShift) then -- SPRINT
			IsSprintKeyDown = false
			if IsSprinting and not IsAiming and not Shooting and not IsSprintKeyDown then
				IsSprinting = false
				CanSprint = false
				CurrentFOV = 70
			
				Character.Humanoid.WalkSpeed = 16
				BobbleSize = 0.09
				BobbleSpeed = 11
			end
		end;
	end
end)


--// Animations
local AnimationSpeed

function IdleAnim()
	ClientConfig.IdleAnim(Character, AnimationSpeed, {
		AnimBaseW,
		RightArmW,
		LeftArmW
	});
end;

function ReloadAnim()
	ClientConfig.ReloadAnim(Character, AnimationSpeed, {
		[1] = Arms,
		[2] = RightArmW,
		[3] = LeftArmW,
		[4] = Mag,
		[5] = false,
		[6] = Grip
	});
end;

function BoltingBackAnim()
	ClientConfig.BoltingBackAnim(Character, AnimationSpeed, {
		BoltMotor
	});
end

function BoltingForwardAnim()
	ClientConfig.BoltingForwardAnim(Character, AnimationSpeed, {
		BoltMotor
	});
end