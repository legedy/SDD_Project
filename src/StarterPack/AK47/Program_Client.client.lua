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

local HRP = Character:WaitForChild('HumanoidRootPart');
local Humanoid = Character:WaitForChild('Humanoid');

--// Services
local UIS = game:GetService('UserInputService');
local RunService = game:GetService('RunService');

local RenderStep = RunService.RenderStepped;

--// Declarables
local L_15_ = false;
local L_16_ = false;

local GunResources = Gun:WaitForChild('Resource');
local Effects = GunResources:WaitForChild('FX');
local Events = GunResources:WaitForChild('Events');
local Modules = GunResources:WaitForChild('Modules');
local SettingsModules = GunResources:WaitForChild('SettingsModule');

local ClientConfig = require(SettingsModules:WaitForChild("ClientConfig"));
local SpringModule = require(Modules:WaitForChild("Spring"));

local AmmoFrame;
local Ammo;
local AmmoBG;
local MagCount;
local MagCountBG;
local Title;

local MainGUI;

local AnimBase;
local AnimBaseW;
local RightArmW;
local LeftArmW;
local NeckClone;
local L_49_;

local CurrentAimZoom = ClientConfig.AimZoom;

local MouseSens = ClientConfig.MouseSensitivity;
local MouseDeltaSens = UIS.MouseDeltaSensitivity;

--// Weapon Parts
local AimPart = Gun:WaitForChild('AimPart');
local Grip = Gun:WaitForChild('Grip');
local FirePart = Gun:WaitForChild('FirePart');
local Mag = Gun:WaitForChild('Mag');
local Bolt = Gun:WaitForChild('Bolt');

--// States
local IsAiming = false;
local IsReloading = false;
local IsSprinting = false;
local Mouse1Holding = false;
local CanShoot = true;
local IsSprintKeyDown = false;
local CanSprint = false;
local isIdle = false;

local L_86_ = false;

local CurrentGunRecoil;
local CurrentCamRecoil;
local CurrentKickback;

local CurrentCamShake;

local FireType = ClientConfig.FireMode;
local CurrentFOV = 70;

local DebrisFolder = Instance.new("Folder");
DebrisFolder.Name = "BulletModel: " .. Player.Name;
DebrisFolder.Parent = workspace;

local L_102_

local AmmoInMag = ClientConfig.Ammo
local TotalAmmo = ClientConfig.StoredAmmo * ClientConfig.MagCount

IgnoreList = {
	Character,
	DebrisFolder,
	Camera
}

local RayParams = RaycastParams.new();
RayParams.FilterType = Enum.RaycastFilterType.Exclude;
RayParams.FilterDescendantsInstances = IgnoreList;

--// Events
local Equipped = Events:WaitForChild('Equipped')

--// Math
local LeanOffset = CFrame.Angles(0, 0, 0)

--// Functions
function MakeFakeArms()
	Arms = Instance.new("Model")
	Arms.Name = "Arms"
	Arms.Parent = Camera

	local L_172_ = Instance.new("Humanoid")
	L_172_.MaxHealth = 0
	L_172_.Health = 0
	L_172_.Name = ""
	L_172_.Parent = Arms
		
	if Character:FindFirstChild("Shirt") then
		local L_177_ = Character:FindFirstChild("Shirt"):clone()
		L_177_.Parent = Arms
	end
	
	local L_173_ = Character:FindFirstChild("Right Arm"):clone()
	for _, L_179_forvar2 in pairs(L_173_:GetChildren()) do
		if L_179_forvar2:IsA('Motor6D') then
			L_179_forvar2:Destroy()
		end
	end
	L_173_.Name = "Right Arm"
	L_173_.FormFactor = "Custom"
	L_173_.Size = Vector3.new(0.8, 2.5, 0.8)
	L_173_.Transparency = 0.0
	
	local L_174_ = Instance.new("Motor6D")
	L_174_.Part0 = L_173_
	L_174_.Part1 = Character:FindFirstChild("Right Arm")
	L_174_.C0 = CFrame.new()
	L_174_.C1 = CFrame.new()
	L_174_.Parent = L_173_	
	L_173_.Parent = Arms
		
	local L_175_ = Character:FindFirstChild("Left Arm"):clone()
	L_175_.Name = "Left Arm"
	L_175_.FormFactor = "Custom"
	L_175_.Size = Vector3.new(0.8, 2.5, 0.8)
	L_175_.Transparency = 0.0	
	
	local L_176_ = Instance.new("Motor6D")
	L_176_.Part0 = L_175_
	L_176_.Part1 = Character:FindFirstChild("Left Arm")
	L_176_.C0 = CFrame.new()
	L_176_.C1 = CFrame.new()
	L_176_.Parent = L_175_	
	L_175_.Parent = Arms
end

function RemoveArmModel()
	if Arms then
		Arms:Destroy()
		Arms = nil
	end
end

function CreateShell()
	local shell = Gun.Shell:clone()
	if shell:FindFirstChild('Shell') then
		shell.Shell:Destroy()
	end
	shell.CFrame =  Gun.Chamber.CFrame
	shell.Velocity = Gun.Chamber.CFrame.lookVector * 30 + Vector3.new(0, 4, 0)
	--shell.RotVelocity = Vector3.new(-10,40,30)
	shell.CanCollide = false
	shell.Parent = DebrisFolder

	game:GetService("Debris"):AddItem(shell, 1)

	task.delay(0.5, function()
		if Effects:FindFirstChild('ShellCasing') then
			local shellCasing = Effects.ShellCasing:clone()
			shellCasing.Parent = Player.PlayerGui
			shellCasing:Play();

			game:GetService('Debris'):AddItem(shellCasing, shellCasing.TimeLength)
		end
	end)
end

function UpdateAmmo()
	Ammo.Text = AmmoInMag
	AmmoBG.Text = Ammo.Text
	
	MagCount.Text = '| ' .. math.ceil(TotalAmmo / ClientConfig.StoredAmmo)
	MagCountBG.Text = MagCount.Text
end

Gun.Equipped:Connect(function()
	MakeFakeArms()
		
	MainGUI = Player.PlayerGui.MainGui
	AmmoFrame = MainGUI:WaitForChild('GameGui'):WaitForChild('AmmoFrame')
	Ammo = AmmoFrame:WaitForChild('Ammo')
	AmmoBG = AmmoFrame:WaitForChild('AmmoBackground')
	MagCount = AmmoFrame:WaitForChild('MagCount')
	MagCountBG = AmmoFrame:WaitForChild('MagCountBackground')
	Title = AmmoFrame:WaitForChild('Title')
	
	Title.Text = Gun.Name
	UpdateAmmo()
	
	-- AnimBase = AnimBaseParam
	-- AnimBaseW = AnimBaseWParam
	-- RightArmW = RAW
	-- LeftArmW = LAW
	-- NeckClone = CloneNeckJoint
	L_49_ = Bolt.Bolt
	
	if ClientConfig.FirstPersonOnly then
		Player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
	--uis.MouseIconEnabled = false
	Camera.FieldOfView = 70
	L_15_ = true
end)

--// Connections
Equipped.OnClientEvent:Connect(function(L_191_arg1, _, AnimBaseParam, AnimBaseWParam, RAW, LAW, CloneNeckJoint)
	if L_191_arg1 and not L_15_ then
		MakeFakeArms()
		
		MainGUI = Player.PlayerGui.MainGui
		AmmoFrame = MainGUI:WaitForChild('GameGui'):WaitForChild('AmmoFrame')
		Ammo = AmmoFrame:WaitForChild('Ammo')
		AmmoBG = AmmoFrame:WaitForChild('AmmoBackground')
		MagCount = AmmoFrame:WaitForChild('MagCount')
		MagCountBG = AmmoFrame:WaitForChild('MagCountBackground')
		Title = AmmoFrame:WaitForChild('Title')
		
		Title.Text = Gun.Name
		UpdateAmmo()
		
		AnimBase = AnimBaseParam
		AnimBaseW = AnimBaseWParam
		RightArmW = RAW
		LeftArmW = LAW
		NeckClone = CloneNeckJoint
		L_49_ = Bolt.Bolt
		
		if ClientConfig.FirstPersonOnly then
			Player.CameraMode = Enum.CameraMode.LockFirstPerson
		end
		--uis.MouseIconEnabled = false
		Camera.FieldOfView = 70
		L_15_ = true
	elseif L_15_ then
		IsAiming = false
		IsSprinting = false
		IsReloading = false
		Shooting = false
		
		CurrentFOV = 70
		
		RemoveArmModel()
		
		MainGUI:Destroy()	
		
		for L_198_forvar1, L_199_forvar2 in pairs(IgnoreList) do
			if L_199_forvar2 ~= Character and L_199_forvar2 ~= Camera and L_199_forvar2 ~= DebrisFolder then
				table.remove(IgnoreList, L_198_forvar1)
			end
		end
		
		if Character:FindFirstChild('Right Arm') and Character:FindFirstChild('Left Arm') then
			Character['Right Arm'].LocalTransparencyModifier = 0
			Character['Left Arm'].LocalTransparencyModifier = 0
		end	

		CanShoot = true
		
		Player.CameraMode = Enum.CameraMode.Classic
		UIS.MouseIconEnabled = true		
		Camera.FieldOfView = 70
		L_15_ = false
		UIS.MouseDeltaSensitivity = MouseDeltaSens
	end
end)

--// Firemode Functions
function CreateBullet(L_200_arg1)
	local L_201_ = FirePart.Position
	local L_202_ = (Mouse.Hit.p - L_201_).Unit
	local L_203_ = CFrame.Angles(math.rad(math.random(-L_200_arg1, L_200_arg1)), math.rad(math.random(-L_200_arg1, L_200_arg1)), math.rad(math.random(-L_200_arg1, L_200_arg1)))
	L_202_ = L_203_ * L_202_	
	local L_204_ = CFrame.new(L_201_, L_201_ + L_202_)	
		
	local L_205_ = Instance.new("Part", DebrisFolder)
	game.Debris:AddItem(L_205_, 10)
	L_205_.Shape = Enum.PartType.Ball
	L_205_.Size = Vector3.new(1, 1, 12)
	L_205_.Name = "Bullet"
	L_205_.TopSurface = "Smooth"
	L_205_.BottomSurface = "Smooth"
	L_205_.BrickColor = BrickColor.new("Bright green")
	L_205_.Material = "Neon"
	L_205_.CanCollide = false
		--Bullet.CFrame = FirePart.CFrame + (Grip.CFrame.p - Grip.CFrame.p)
	L_205_.CFrame = L_204_
		
	local L_206_ = Instance.new("Sound")
	L_206_.SoundId = "rbxassetid://341519743"
	L_206_.Looped = true
	L_206_:Play()
	L_206_.Parent = L_205_
	L_206_.Volume = 0.4
	L_206_.MaxDistance = 30
	
	L_205_.Transparency = 1
	local L_208_ = Instance.new('BodyForce', L_205_)
		
	--> Bullet force
	L_208_.Force = ClientConfig.BulletPhysics
	L_205_.Velocity = L_202_ * ClientConfig.BulletSpeed
		
	local L_209_ = Instance.new('Attachment', L_205_)
	L_209_.Position = Vector3.new(0.1, 0, 0)
	local L_210_ = Instance.new('Attachment', L_205_)
	L_210_.Position = Vector3.new(-0.1, 0, 0)
		
	if ClientConfig.TracerEnabled == true then
		local L_212_ = Instance.new('Trail', L_205_)
		L_212_.Attachment0 = L_209_
		L_212_.Attachment1 = L_210_
		L_212_.Transparency = NumberSequence.new(ClientConfig.TracerTransparency)
		L_212_.LightEmission = ClientConfig.TracerLightEmission
		L_212_.TextureLength = ClientConfig.TracerTextureLength
		L_212_.Lifetime = ClientConfig.TracerLifetime
		L_212_.FaceCamera = ClientConfig.TracerFaceCamera
		L_212_.Color = ColorSequence.new(ClientConfig.TracerColor.Color)
	end
		
	if Gun:FindFirstChild('Shell') then
		CreateShell()	
	end	
		
	task.delay(0.2, function()
		L_205_.Transparency = 0
	end)
	
	return L_205_
end

function CheckForHumanoid(L_213_arg1)
	local L_214_ = false
	local L_215_ = nil
	if L_213_arg1 then
		if (L_213_arg1.Parent:FindFirstChild("Humanoid") or L_213_arg1.Parent.Parent:FindFirstChild("Humanoid")) then
			L_214_ = true
			if L_213_arg1.Parent:FindFirstChild('Humanoid') then
				L_215_ = L_213_arg1.Parent.Humanoid
			elseif L_213_arg1.Parent.Parent:FindFirstChild('Humanoid') then
				L_215_ = L_213_arg1.Parent.Parent.Humanoid
			end
		else
			L_214_ = false
		end	
	end
	return L_214_, L_215_
end

local function FireRaycast(BulletSpread)
	local RandomAngle = CFrame.Angles(
		math.rad(math.random(-BulletSpread, BulletSpread)),
		math.rad(math.random(-BulletSpread, BulletSpread)),
		math.rad(math.random(-BulletSpread, BulletSpread))
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
				--> TODO: head damage
				Humanoid:TakeDamage(ClientConfig.HeadDamage);
			elseif (RayHitInstance.Name == 'HumanoidRootPart' or RayHitInstance.Name == 'Torso') then
				--> TODO: base damage
				Humanoid:TakeDamage(ClientConfig.BaseDamage);
			else
				--> TODO: limb damage
				Humanoid:TakeDamage(ClientConfig.LimbDamage);
			end
		end
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

local AnimBaseC1 = nil
local AnimBaseC0 = nil

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

		-- if AmmoInMag <= 0 and not ClientConfig.CanSlideLock then
		-- 	BoltBackAnim()
		-- 	BoltForwardAnim()
		-- end
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
		if AnimBaseC0 == nil or AnimBaseC1 == nil then
			AnimBaseC0 = AnimBaseW.C0
			AnimBaseC1 = AnimBaseW.C1
		end
		
		Camera.CFrame = Camera.CFrame:Lerp(Camera.CFrame * RecoilAddition, 0.2)
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
				0.05
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
				math.rad(CurrentCamRecoil * math.random(0, CurrentCamShake)),
				math.rad(CurrentCamRecoil * math.random(-CurrentCamShake, CurrentCamShake)),
				math.rad(CurrentCamRecoil * math.random(-CurrentCamShake, CurrentCamShake))
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
		
		NeckClone.C0 = HRP.CFrame:toObjectSpace(
			HRP.CFrame *
			CFrame.new(0, 1.5, 0) *
			CFrame.new(Humanoid.CameraOffset)
		);
		NeckClone.C1 = CFrame.Angles(-math.asin(Camera.CFrame.LookVector.Y), 0, 0);
		UIS.MouseIconEnabled = false;
	end
end)

--// Input Connections
UIS.InputBegan:Connect(function(Input, GPE)
	if not GPE and L_15_ then
		if (Input.UserInputType == Enum.UserInputType.MouseButton2 and
			ClientConfig.CanAim and
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
		if (Input.UserInputType == Enum.UserInputType.MouseButton2 and ClientConfig.CanAim) then
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

function EquipAnim()
	ClientConfig.EquipAnim(Character, AnimationSpeed, {
		AnimBaseW
	});
end;

function UnequipAnim()
	ClientConfig.UnequipAnim(Character, AnimationSpeed, {
		AnimBaseW
	});
end;

function FireModeAnim()
	ClientConfig.FireModeAnim(Character, AnimationSpeed, {
		AnimBaseW,
		LeftArmW,
		RightArmW,
		Grip
	});
end

function ReloadAnim()
	ClientConfig.ReloadAnim(Character, AnimationSpeed, {
		[1] = false,
		[2] = RightArmW,
		[3] = LeftArmW,
		[4] = Mag,
		[5] = false,
		[6] = Grip
	});
end;

function BoltingBackAnim()
	ClientConfig.BoltingBackAnim(Character, AnimationSpeed, {
		L_49_
	});
end

function BoltingForwardAnim()
	ClientConfig.BoltingForwardAnim(Character, AnimationSpeed, {
		L_49_
	});
end

function BoltBackAnim()
	ClientConfig.BoltBackAnim(Character, AnimationSpeed, {
		L_49_,
		LeftArmW,
		RightArmW,
		AnimBaseW,
		Bolt
	});
end

function BoltForwardAnim()
	ClientConfig.BoltForwardAnim(Character, AnimationSpeed, {
		L_49_,
		LeftArmW,
		RightArmW,
		AnimBaseW,
		Bolt
	});
end

function InspectAnim()
	ClientConfig.InspectAnim(Character, AnimationSpeed, {
		LeftArmW,
		RightArmW
	});
end

function nadeReload()
	ClientConfig.nadeReload(Character, AnimationSpeed, {
		RightArmW,
		LeftArmW
	});
end

function AttachAnim()
	ClientConfig.AttachAnim(Character, AnimationSpeed, {
		RightArmW,
		LeftArmW
	});
end

function PatrolAnim()
	ClientConfig.PatrolAnim(Character, AnimationSpeed, {
		RightArmW,
		LeftArmW
	});
end