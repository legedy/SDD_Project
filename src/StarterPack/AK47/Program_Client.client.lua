repeat
	task.wait()
until game.Players.LocalPlayer.Character
wait(0.5)

--// Variables
local Gun = script.Parent
local Player = game.Players.LocalPlayer
local Character = Player.Character
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local Torso = Character:WaitForChild('Torso')
local Head = Character:WaitForChild('Head')
local HRP = Character:WaitForChild('HumanoidRootPart')

--// Services
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

--// Declarables
local L_15_ = false
local L_16_ = false

local GunResources = Gun:WaitForChild('Resource')
local Effects = GunResources:WaitForChild('FX')
local Events = GunResources:WaitForChild('Events')
local Modules = GunResources:WaitForChild('Modules')
local SettingsModules = GunResources:WaitForChild('SettingsModule')
local ClientConfig = require(SettingsModules:WaitForChild("ClientConfig"))

local AmmoFrame
local Ammo
local AmmoBG
local MagCount
local MagCountBG
local DistDisplay
local Title
local Mode1
local Mode2
local Mode3
local Mode4
local Mode5

local MainGUI

local AnimBase
local AnimBaseW
local RightArmW
local LeftArmW
local NeckClone
local L_49_

local CurrenAimZoom = ClientConfig.AimZoom

local MouseSens = ClientConfig.MouseSensitivity
local MouseDeltaSens = UIS.MouseDeltaSensitivity

--// Weapon Parts
local AimPart = Gun:WaitForChild('AimPart')
local Grip = Gun:WaitForChild('Grip')
local FirePart = Gun:WaitForChild('FirePart')
local Mag = Gun:WaitForChild('Mag')
local Bolt = Gun:WaitForChild('Bolt')

--// States
local IsAiming = false
local AimMode = false --> how aim affects recoil and stuff
local IsReloading = false
local IsSprinting = false
local Mouse1Holding = false
local CanShoot = true
local IsExecutingAction = false
local IsSprintKeyDown = false
local CanSprint = false
local isBoltForward = false
local isIdle = false
local isInputBlocked = false
local isInMenu = false

local L_86_ = false

local L_89_
local L_90_
local L_91_

local FireType = ClientConfig.FireMode
local L_93_ = 0
local L_97_ = 70

local L_99_ = {
	
	"2282590559";
	"2282583154";
	"2282584222";
	"2282584708";
	"2282585118";
	"2282586860";
	"2282587182";
	"2282587628";
	"2282588117";
	"2282588433";
	"2282576973";
	"2282577954";
	"2282578595";
	"2282579272";
	"2282579760";
	"2282580279";
	"2282580551";
	"2282580935";
	"2282582377";
	"2282582717";
	"2282449653";
		
}

local L_100_ = {
	
	"2297264589";
	"2297264920";
	"2297265171";
	"2297265394";
	"2297266410";
	"2297266774";
	"2297267106";
	"2297267463";
	"2297267748";
	"2297268261";
	"2297268486";
	"2297268707";
	"2297268894";
	"2297269092";
	"2297269542";
	"2297269946";
	"2297270243";
	"2297270591";
	"2297270984";
	"2297271381";
	"2297271626";
	"2297272112";
	"2297272424";
	
}

local L_101_ = workspace:FindFirstChild("BulletModel: " .. Player.Name) or Instance.new("Folder", workspace)
L_101_.Name = "BulletModel: " .. Player.Name

local L_102_

local AmmoInMag = ClientConfig.Ammo
local TotalAmmo = ClientConfig.StoredAmmo * ClientConfig.MagCount

local L_105_ = ClientConfig.ExplosiveAmmo

IgnoreList = {
	Character,
	L_101_,
	Camera
}

--// Services
local RenderStep = RunService.RenderStepped;
local UIS = game:GetService('UserInputService')

--// Events
local Equipped = Events:WaitForChild('Equipped')
local ShootEvent = Events:WaitForChild('ShootEvent')
local DamageEvent = Events:WaitForChild('DamageEvent')
local CreateOwner = Events:WaitForChild('CreateOwner')
local Stance = Events:WaitForChild('Stance')
local HitEvent = Events:WaitForChild('HitEvent')
local KillEvent = Events:WaitForChild('KillEvent')
local AimEvent = Events:WaitForChild('AimEvent')
local ExplosionEvent = Events:WaitForChild('ExploEvent')
local AttachEvent = Events:WaitForChild('AttachEvent')
local ServerFXEvent = Events:WaitForChild('ServerFXEvent')
local ChangeIDEvent = Events:WaitForChild('ChangeIDEvent')

--// Modules
local UtilitiesModule = require(Modules:WaitForChild("Utilities"))
local SpringModule = require(Modules:WaitForChild("Spring"))
local Plugins = require(Modules:WaitForChild("Plugins"))

local L_130_ = UtilitiesModule.TweenJoint

--// Math

local L_133_ = SpringModule.new(Vector3.new())
L_133_.s = 30
L_133_.d = 0.55
	
local L_134_ = CFrame.Angles(0, 0, 0)

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
	shell.Parent = L_101_

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

-- 100 == 1  0 == 0  1/0.5

function JamCalculation()
	local L_182_ = (math.random(1, 100) <= ClientConfig.JamChance)

	if (L_182_) then
		isIdle = true
	end

	return L_182_;
end

function TracerCalculation()
	return (math.random(1, 100) <= ClientConfig.TracerChance)
end

function ScreamCalculation()
	return (math.random(1, 100) <= ClientConfig.SuppressCalloutChance)
end

function UpdateAmmo()
	Ammo.Text = AmmoInMag
	AmmoBG.Text = Ammo.Text
	
	MagCount.Text = '| ' .. math.ceil(TotalAmmo / ClientConfig.StoredAmmo)
	MagCountBG.Text = MagCount.Text
	
	if FireType == 1 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0.7
		Mode3.BackgroundTransparency = 0.7
		Mode4.BackgroundTransparency = 0.7
		Mode5.BackgroundTransparency = 0.7
	elseif FireType == 2 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0
		Mode5.BackgroundTransparency = 0
	end
	
end

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
		DistDisplay = AmmoFrame:WaitForChild('DistDisp')
		Title = AmmoFrame:WaitForChild('Title')
		Mode1 = AmmoFrame:WaitForChild('Mode1')
		Mode2 = AmmoFrame:WaitForChild('Mode2')
		Mode3 = AmmoFrame:WaitForChild('Mode3')
		Mode4 = AmmoFrame:WaitForChild('Mode4')
		Mode5 = AmmoFrame:WaitForChild('Mode5')
		
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
		
		L_97_ = 70
		
		RemoveArmModel()
		
		MainGUI:Destroy()	
		
		for L_198_forvar1, L_199_forvar2 in pairs(IgnoreList) do
			if L_199_forvar2 ~= Character and L_199_forvar2 ~= Camera and L_199_forvar2 ~= L_101_ then
				table.remove(IgnoreList, L_198_forvar1)
			end
		end
		
		if Character:FindFirstChild('Right Arm') and Character:FindFirstChild('Left Arm') then
			Character['Right Arm'].LocalTransparencyModifier = 0
			Character['Left Arm'].LocalTransparencyModifier = 0
		end	

		isInMenu = false
		CanShoot = true
		
		Player.CameraMode = Enum.CameraMode.Classic
		UIS.MouseIconEnabled = true		
		Camera.FieldOfView = 70
		L_15_ = false
		UIS.MouseDeltaSensitivity = MouseDeltaSens
		Mouse.Icon = "http://www.roblox.com/asset?id=0"
		Mouse.TargetFilter = nil
	end
end)

--// Firemode Functions
function CreateBullet(L_200_arg1)
	local L_201_ = FirePart.Position
	local L_202_ = (Mouse.Hit.p - L_201_).unit
	local L_203_ = CFrame.Angles(math.rad(math.random(-L_200_arg1, L_200_arg1)), math.rad(math.random(-L_200_arg1, L_200_arg1)), math.rad(math.random(-L_200_arg1, L_200_arg1)))
	L_202_ = L_203_ * L_202_	
	local L_204_ = CFrame.new(L_201_, L_201_ + L_202_)	
		
	local L_205_ = Instance.new("Part", L_101_)
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
			
	local L_211_ = TracerCalculation()
		
	if ClientConfig.TracerEnabled == true and L_211_ then
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
		
	delay(0.2, function()
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

function CastRay(L_216_arg1)
	local HitObject, HitPosition, HitNormal
	local AimPartPos = AimPart.Position;
	local L_221_ = L_216_arg1.Position;
	local BulletDistTravelled = 0
	
	while true do
		RenderStep:Wait()
		L_221_ = L_216_arg1.Position;
		BulletDistTravelled = BulletDistTravelled + (L_221_ - AimPartPos).magnitude
		HitObject, HitPosition, HitNormal = workspace:FindPartOnRayWithIgnoreList(Ray.new(AimPartPos, (L_221_ - AimPartPos)), IgnoreList);
		
		local L_224_ = Vector3.new(0, 1, 0):Cross(HitNormal)
		local L_225_ = math.asin(L_224_.Magnitude) -- division by 1 is redundant


		if BulletDistTravelled > ClientConfig.BulletDecay then
			L_216_arg1:Destroy()
			break
		end

		if HitObject and (HitObject and HitObject.Transparency >= 1 or HitObject.CanCollide == false) and HitObject.Name ~= 'Right Arm' and HitObject.Name ~= 'Left Arm' and HitObject.Name ~= 'Right Leg' and HitObject.Name ~= 'Left Leg' and HitObject.Name ~= 'Armor' then
			table.insert(IgnoreList, HitObject)
		end
	
		if HitObject then
		
			ServerFXEvent:FireServer(HitPosition)
		
			local L_226_ = CheckForHumanoid(HitObject)
			if L_226_ == false then
				L_216_arg1:Destroy()
				HitEvent:InvokeServer(HitPosition, L_224_, L_225_, HitNormal, "Part", HitObject)
			elseif L_226_ == true then
				L_216_arg1:Destroy()
				HitEvent:InvokeServer(HitPosition, L_224_, L_225_, HitNormal, "Human", HitObject)
			end
		end
	
		if HitObject then
			local L_229_, L_230_ = CheckForHumanoid(HitObject)
			if L_229_ then
				CreateOwner:FireServer(L_230_)
				if ClientConfig.AntiTK then
					if game.Players:FindFirstChild(L_230_.Parent.Name) and game.Players:FindFirstChild(L_230_.Parent.Name).TeamColor ~= Player.TeamColor or L_230_.Parent:FindFirstChild('Vars') and game.Players:FindFirstChild(L_230_.Parent:WaitForChild('Vars'):WaitForChild('BotID').Value) and Player.TeamColor ~= L_230_.Parent:WaitForChild('Vars'):WaitForChild('teamColor').Value then
						if HitObject.Name == 'Head' then
							DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
							local L_231_ = Effects:WaitForChild('BodyHit'):clone()
							L_231_.Parent = Player.PlayerGui
							L_231_:Play()
							game:GetService("Debris"):addItem(L_231_, L_231_.TimeLength)
						end
						if HitObject.Name ~= 'Head' and not (HitObject.Parent:IsA('Accessory') or HitObject.Parent:IsA('Hat')) then
							if HitObject.Name ~= 'Torso' and HitObject.Name ~= 'HumanoidRootPart' and HitObject.Name ~= 'Armor' then
								DamageEvent:FireServer(L_230_, ClientConfig.LimbDamage)
							elseif HitObject.Name == 'Torso' or HitObject.Name == 'HumanoidRootPart' and HitObject.Name ~= 'Armor'  then
								DamageEvent:FireServer(L_230_, ClientConfig.BaseDamage)
							elseif HitObject.Name == 'Armor' then
								DamageEvent:FireServer(L_230_, ClientConfig.ArmorDamage)
							end
							local L_232_ = Effects:WaitForChild('BodyHit'):clone()
							L_232_.Parent = Player.PlayerGui
							L_232_:Play()
							game:GetService("Debris"):addItem(L_232_, L_232_.TimeLength)
						end
						if (HitObject.Parent:IsA('Accessory') or HitObject.Parent:IsA('Hat')) then
							DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
							local L_233_ = Effects:WaitForChild('BodyHit'):clone()
							L_233_.Parent = Player.PlayerGui
							L_233_:Play()
							game:GetService("Debris"):addItem(L_233_, L_233_.TimeLength)
						end
					end
				else
					if HitObject.Name == 'Head' then
						DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
						local L_234_ = Effects:WaitForChild('BodyHit'):clone()
						L_234_.Parent = Player.PlayerGui
						L_234_:Play()
						game:GetService("Debris"):addItem(L_234_, L_234_.TimeLength)
					end
					if HitObject.Name ~= 'Head' and not (HitObject.Parent:IsA('Accessory') or HitObject.Parent:IsA('Hat')) then
						if HitObject.Name ~= 'Torso' and HitObject.Name ~= 'HumanoidRootPart' and HitObject.Name ~= 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.LimbDamage)
						elseif HitObject.Name == 'Torso' or HitObject.Name == 'HumanoidRootPart' and HitObject.Name ~= 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.BaseDamage)
						elseif HitObject.Name == 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.ArmorDamage)
						end
						local L_235_ = Effects:WaitForChild('BodyHit'):clone()
						L_235_.Parent = Player.PlayerGui
						L_235_:Play()
						game:GetService("Debris"):addItem(L_235_, L_235_.TimeLength)
					end
					if (HitObject.Parent:IsA('Accessory') or HitObject.Parent:IsA('Hat')) then
						DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
						local L_236_ = Effects:WaitForChild('BodyHit'):clone()
						L_236_.Parent = Player.PlayerGui
						L_236_:Play()
						game:GetService("Debris"):addItem(L_236_, L_236_.TimeLength)
					end
				end	
			end
		end
	
		if HitObject and HitObject.Parent:FindFirstChild("Humanoid") then
			return HitObject, HitPosition;
		end
		AimPartPos = L_221_;
	end
end

function fireSemi()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		
		FirePart:WaitForChild('Fire'):Play()
		ShootEvent:FireServer()
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		AmmoInMag = AmmoInMag - 1
		UpdateAmmo()
		RecoilFront = true
		task.spawn(function()
			CastRay(L_102_)
		end)
		
		if ClientConfig.CanBolt == true then
			BoltingBackAnim()
			delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if AmmoInMag > 0 then
						BoltingForwardAnim()
					end
				end
			end)
		end
		
		delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)		
		
		wait(ClientConfig.Firerate)
		
		CanShoot = not JamCalculation()
		Shooting = false
	end
end

function fireAuto()
	while not Shooting and AmmoInMag > 0 and Mouse1Holding and CanShoot and L_15_ do
		CanShoot = false
		Recoiling = true

		FirePart:WaitForChild('Fire'):Play()
		ShootEvent:FireServer()
		AmmoInMag = AmmoInMag - 1
		UpdateAmmo()
		Shooting = true
		RecoilFront = true
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		local L_257_, L_258_ = spawn(function()
			CastRay(L_102_)
		end)
					
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
			delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if AmmoInMag > 0 then
						BoltingForwardAnim()
					end
				end
			end)
		end
		
		
		delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)
		wait(ClientConfig.Firerate)
		
		CanShoot = not JamCalculation()
		
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
local L_136_

local SwayX = 0
local SwayY = 0
local SwayDeltaLimit = 35 --This is the limit of the mouse input for the sway
local UnaimedSway = -9 --This is the magnitude of the sway when you're unaimed
local AimedSway = -9 --This is the magnitude of the sway when you're aimed

--local Sprinting =false
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
local L_147_ = CFrame.new()
local RecoilAddition = CFrame.new()

local L_149_ = 0
local L_150_ = CFrame.new()
local L_151_ = 0.05
local L_152_ = 2

local SwayTime = 0
local VerticalSwayAmp = 0.09
local SwaySpeed = 11

local L_159_, L_160_ = 0, 0

local L_161_ = nil
local L_162_ = nil

Character.Humanoid.Running:Connect(function(L_273_arg1)
	if L_273_arg1 > 1 then
		IsMoving = true
	else
		IsMoving = false
	end
end)

RenderStep:Connect(function(deltaTime)
	if L_15_ then
		L_159_, L_160_ = L_159_ or 0, L_160_ or 0
		if L_162_ == nil or L_161_ == nil then
			L_162_ = AnimBaseW.C0
			L_161_ = AnimBaseW.C1
		end
		
		local L_274_ = (math.sin(SwayTime * SwaySpeed / 2) * VerticalSwayAmp)
		local L_275_ = (math.sin(SwayTime * SwaySpeed) * VerticalSwayAmp)

		local L_279_ =
			CFrame.new(
				L_274_,
				L_275_,
				0.02
			) * CFrame.Angles(
				(math.cos(SwayTime * SwaySpeed) * VerticalSwayAmp),
				(math.cos(SwayTime * SwaySpeed / 2) * VerticalSwayAmp),
				0
			);
		
		local L_280_ = (math.sin(L_149_ * L_152_ / 2) * L_151_)
		local L_281_ = (math.cos(L_149_ * L_152_) * L_151_)
		local L_282_ = CFrame.new(L_280_, L_281_, 0.02)
		
		if IsMoving then
			SwayTime = SwayTime + deltaTime
			L_147_ = L_279_
		else
			SwayTime = 0
			L_147_ = CFrame.new()
		end
		
		SwaySpring.t = Vector3.new(SwayX, SwayY, 0)
		local SwaySpringPosition = SwaySpring.p
		local SwayFinalX = SwaySpringPosition.X / SwayDeltaLimit * (IsAiming and AimedSway or UnaimedSway)
		local SwayFinalY = SwaySpringPosition.Y / SwayDeltaLimit * (IsAiming and AimedSway or UnaimedSway)
		
		Camera.CFrame = Camera.CFrame:Lerp(Camera.CFrame * RecoilAddition, 0.2)
		
		if IsAiming then
			L_136_ =
				CFrame.Angles(
					math.rad(-SwayFinalX),
					math.rad(SwayFinalX),
					math.rad(SwayFinalY)
				) * CFrame.fromAxisAngle(
					Vector3.new(5, 0, -1),
					math.rad(SwayFinalX)
				);
			L_149_ = 0
			L_150_ = CFrame.new()
		else
			L_136_ = CFrame.Angles(math.rad(-SwayFinalY), math.rad(-SwayFinalX), math.rad(-SwayFinalX)) * CFrame.fromAxisAngle(AnimBase.Position, math.rad(-SwayFinalY))
			L_149_ = L_149_ + 0.017
			L_150_ = L_282_
		end
		
		--> Sway
		AnimBaseW.C0 = AnimBaseW.C0:Lerp(L_162_ * L_136_ * L_147_ * L_150_, 0.1)
		
		if IsSprinting and not IsExecutingAction and CanSprint and not IsAiming and not IsReloading and not Shooting then
			AnimBaseW.C1 = AnimBaseW.C1:Lerp(AnimBaseW.C0 * ClientConfig.SprintPos, 0.1)
		elseif not IsSprinting and not IsExecutingAction and not CanSprint and not IsAiming and not IsReloading and not Shooting then
			AnimBaseW.C1 = AnimBaseW.C1:Lerp(CFrame.new() * L_134_, 0.05)
		end
		
		
		if IsAiming and not IsSprinting then
			if not AimMode then
				L_90_ = ClientConfig.AimCamRecoil
				L_89_ = ClientConfig.AimGunRecoil
				L_91_ = ClientConfig.AimKickback
			elseif AimMode then
				if L_93_ == 1 then
					L_90_ = ClientConfig.AimCamRecoil / 1.5
					L_89_ = ClientConfig.AimGunRecoil / 1.5
					L_91_ = ClientConfig.AimKickback / 1.5
				end
				
				if L_93_ == 2 then
					L_90_ = ClientConfig.AimCamRecoil / 2
					L_89_ = ClientConfig.AimGunRecoil / 2
					L_91_ = ClientConfig.AimKickback / 2
				end
			end
			
			if (Character.Head.Position - Camera.CoordinateFrame.p).magnitude < 2 then
				AnimBaseW.C1 = AnimBaseW.C1:Lerp(AnimBaseW.C0 * AimPart.CFrame:toObjectSpace(AnimBase.CFrame), ClientConfig.AimSpeed)
				
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Visible = true
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Text = MouseSens
				UIS.MouseDeltaSensitivity = MouseSens
			end
		elseif not IsAiming and not IsSprinting and L_15_ then
			if (Character.Head.Position - Camera.CoordinateFrame.p).magnitude < 2 then
				AnimBaseW.C1 = AnimBaseW.C1:Lerp(CFrame.new() * L_134_, ClientConfig.UnaimSpeed)
				
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Visible = false
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Text = MouseSens
				UIS.MouseDeltaSensitivity = MouseDeltaSens
			end	
			
			if not AimMode then
				L_90_ = ClientConfig.camrecoil
				L_89_ = ClientConfig.gunrecoil
				L_91_ = ClientConfig.Kickback
			elseif AimMode then
				if L_93_ == 1 then
					L_90_ = ClientConfig.camrecoil / 1.5
					L_89_ = ClientConfig.gunrecoil / 1.5
					L_91_ = ClientConfig.Kickback / 1.5
				end
				
				if L_93_ == 2 then
					L_90_ = ClientConfig.camrecoil / 2
					L_89_ = ClientConfig.gunrecoil / 2
					L_91_ = ClientConfig.Kickback / 2
				end
			end	
		end
		
		if Recoiling then
			if not IsAiming then
				RecoilAddition = CFrame.fromEulerAnglesXYZ(math.rad(L_90_ * math.random(0, ClientConfig.CamShake)), math.rad(L_90_ * math.random(-ClientConfig.CamShake, ClientConfig.CamShake)), math.rad(L_90_ * math.random(-ClientConfig.CamShake, ClientConfig.CamShake)))--CFrame.Angles(camrecoil,0,0)	
			else
				RecoilAddition = CFrame.fromEulerAnglesXYZ(math.rad(L_90_ * math.random(0, ClientConfig.AimCamShake)), math.rad(L_90_ * math.random(-ClientConfig.AimCamShake, ClientConfig.AimCamShake)), math.rad(L_90_ * math.random(-ClientConfig.AimCamShake, ClientConfig.AimCamShake)))
			end
			--cam.CoordinateFrame = cam.CoordinateFrame *  CFrame.fromEulerAnglesXYZ(math.rad(camrecoil*math.random(0,3)), math.rad(camrecoil*math.random(-1,1)), math.rad(camrecoil*math.random(-1,1)))
			AnimBaseW.C0 = AnimBaseW.C0:Lerp(AnimBaseW.C0 * CFrame.new(0, 0, L_89_) * CFrame.Angles(-math.rad(L_91_), 0, 0), 0.3)
		elseif not Recoiling then	
			RecoilAddition = CFrame.Angles(0, 0, 0)
			AnimBaseW.C0 = AnimBaseW.C0:Lerp(CFrame.new(), 0.2)
		end
		
		if AimMode then
			Character:WaitForChild('Humanoid').Jump = false
		end
		
		if L_15_ then
			Camera.FieldOfView = Camera.FieldOfView * (1 - ClientConfig.ZoomSpeed) + (L_97_ * ClientConfig.ZoomSpeed)
			if (Character.Head.Position - Camera.CoordinateFrame.p).magnitude >= 2 then
				L_90_ = ClientConfig.AimCamRecoil
				L_89_ = ClientConfig.AimGunRecoil
				L_91_ = ClientConfig.AimKickback
				
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Visible = true
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Text = MouseSens
				UIS.MouseDeltaSensitivity = MouseSens
			elseif (Character.Head.Position - Camera.CoordinateFrame.p).magnitude < 2 and not IsAiming and not AimMode then
				L_90_ = ClientConfig.camrecoil
				L_89_ = ClientConfig.gunrecoil
				L_91_ = ClientConfig.Kickback
				
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Visible = false
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Text = MouseSens
				UIS.MouseDeltaSensitivity = MouseDeltaSens
			end
		end
		
		if L_15_ and ClientConfig.CameraGo then --and (char.Head.Position - cam.CoordinateFrame.p).magnitude < 2 then
			Mouse.TargetFilter = game.Workspace
			local L_286_ =  Character:WaitForChild("HumanoidRootPart").CFrame * CFrame.new(0, 1.5, 0) * CFrame.new(Character:WaitForChild("Humanoid").CameraOffset)
			NeckClone.C0 = HRP.CFrame:toObjectSpace(L_286_)
			NeckClone.C1 = CFrame.Angles(-math.asin((Mouse.Hit.p - Mouse.Origin.p).unit.y), 0, 0)
			UIS.MouseIconEnabled = false	
		end
		
		if L_15_ and (Character.Head.Position - Camera.CoordinateFrame.p).magnitude >= 2 then
			if Mouse.Icon ~= "http://www.roblox.com/asset?id=" .. ClientConfig.TPSMouseIcon then
				Mouse.Icon = "http://www.roblox.com/asset?id=" .. ClientConfig.TPSMouseIcon
			end
			UIS.MouseIconEnabled = true
			
			if Character:FindFirstChild('Right Arm') and Character:FindFirstChild('Left Arm') then
				Character['Right Arm'].LocalTransparencyModifier = 1
				Character['Left Arm'].LocalTransparencyModifier = 1
			end
		end;
	end
end)

--// Input Connections
UIS.InputBegan:Connect(function(Input, GPE)
	if not GPE and L_15_ then
		if Input.UserInputType == Enum.UserInputType.MouseButton2 and not isInMenu and not isInputBlocked and ClientConfig.CanAim and not isBoltForward and L_15_ and not IsReloading and not IsSprinting then
			if not IsAiming then
				if not AimMode then
					VerticalSwayAmp = 0.015
					SwaySpeed = 7
					Character:WaitForChild("Humanoid").WalkSpeed = 7
				end
				
				if (Character.Head.Position - Camera.CoordinateFrame.p).magnitude <= 2 then
					L_97_ = CurrenAimZoom
				end
				L_133_.target = AimPart.CFrame:toObjectSpace(AnimBase.CFrame).p
				AimEvent:FireServer(true)				
				IsAiming = true
			end
		end;
		
		if Input.KeyCode == Enum.KeyCode.A and L_15_ then
			L_134_ = CFrame.Angles(0, 0, 0.1)
		end;
		
		if Input.KeyCode == Enum.KeyCode.D and L_15_ then
			L_134_ = CFrame.Angles(0, 0, -0.1)
		end;
		
		if Input.KeyCode == ClientConfig.AlternateAimKey and not isInMenu and not isInputBlocked and ClientConfig.CanAim and not isBoltForward and L_15_ and not IsReloading and not IsSprinting then
			if not IsAiming then
				if not AimMode then
					Character.Humanoid.WalkSpeed = 10
					SwaySpeed = 10
					VerticalSwayAmp = 0.008
				end
				L_97_ = CurrenAimZoom
				L_133_.target = AimPart.CFrame:toObjectSpace(AnimBase.CFrame).p
				AimEvent:FireServer(true)
				IsAiming = true
			end
		end;
		
		if Input.UserInputType == (Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.ButtonR2) and not isInputBlocked and CanShoot and L_15_ and not IsReloading and not IsSprinting and not isBoltForward then
			Mouse1Holding = true
			if not Shooting and L_15_ then
				if AmmoInMag > 0 then			
					Shoot()
				end
			elseif not Shooting and L_15_ then
				if L_105_ > 0 then
					Shoot()
				end
			end
		end;
		
		if Input.KeyCode == (Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.ButtonL3) and not isInMenu and not isInputBlocked and IsMoving then
			IsSprintKeyDown = true
			if L_15_ and not IsExecutingAction and not IsSprinting and IsSprintKeyDown and not AimMode and not isBoltForward then
				Shooting = false
				IsAiming = false
				IsSprinting = true
						
				delay(0, function()
					if IsSprinting and not IsReloading then
						IsAiming = false
						CanSprint = true
					end
				end)
				L_97_ = 80

				VerticalSwayAmp = 0.4
				SwaySpeed = 16
				Character.Humanoid.WalkSpeed = ClientConfig.SprintSpeed
			end
		end;
		
		if Input.KeyCode == (Enum.KeyCode.R or Input.KeyCode == Enum.KeyCode.ButtonX) and not isInMenu and not isInputBlocked and L_15_ and not IsReloading and not IsAiming and not Shooting and not IsSprinting and not isBoltForward then
			if TotalAmmo > 0 and AmmoInMag < ClientConfig.Ammo then
				Shooting = false
				IsReloading = true
				
				ReloadAnim()
				if AmmoInMag <= 0 and not ClientConfig.CanSlideLock then
					BoltBackAnim()
					BoltForwardAnim()
				end
				IdleAnim()
				CanShoot = true
				
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

				IsReloading = false
				if not isIdle then
					CanShoot = true
				end
			end;
		end;
		UpdateAmmo()
		
		if Input.KeyCode == Enum.KeyCode.RightBracket and IsAiming then
			if (MouseSens < 1) then
				MouseSens = MouseSens + ClientConfig.SensitivityIncrement
			end
		end
		
		if Input.KeyCode == Enum.KeyCode.LeftBracket and IsAiming then
			if (MouseSens > 0.1) then
				MouseSens = MouseSens - ClientConfig.SensitivityIncrement
			end
		end
		
		if Input.KeyCode == (Enum.KeyCode.T or Input.KeyCode == Enum.KeyCode.DPadLeft) and Gun:FindFirstChild("AimPart2") then
			if not L_86_ then
				AimPart = Gun:WaitForChild("AimPart2")
				CurrenAimZoom = ClientConfig.CycleAimZoom
				if IsAiming then
					L_97_ = ClientConfig.CycleAimZoom
				end
				L_86_ = true
			else
				AimPart = Gun:FindFirstChild("AimPart")
				CurrenAimZoom = ClientConfig.AimZoom
				if IsAiming then
					L_97_ = ClientConfig.AimZoom
				end
				L_86_ = false
			end;
		end;
		
		if Input.KeyCode == ClientConfig.InspectionKey and not isInMenu then
			if not isInputBlocked then
				isInputBlocked = true
				InspectAnim()
				IdleAnim()
				isInputBlocked = false
			end
		end;
	end
end)

UIS.InputEnded:Connect(function(Input, GPE)
	if not GPE and L_15_ then
		if Input.UserInputType == (Enum.UserInputType.MouseButton2 or Input.KeyCode == Enum.KeyCode.ButtonL2) and not isInputBlocked and ClientConfig.CanAim and not isInMenu then
			if IsAiming then
				if not AimMode then
					Character:WaitForChild("Humanoid").WalkSpeed = 16
					VerticalSwayAmp = 0.09
					SwaySpeed = 11
				end	
				L_97_ = 70
				L_133_.target = Vector3.new()
				AimEvent:FireServer(false)
				IsAiming = false
			end
		end;
		
		if Input.KeyCode == Enum.KeyCode.A and L_15_ then
			L_134_ = CFrame.Angles(0, 0, 0)
		end;
		
		if Input.KeyCode == Enum.KeyCode.D and L_15_ then
			L_134_ = CFrame.Angles(0, 0, 0)
		end;
		
		if Input.KeyCode == ClientConfig.AlternateAimKey and not isInputBlocked and ClientConfig.CanAim then
			if IsAiming then
				if not AimMode then
					Character.Humanoid.WalkSpeed = 16
					SwaySpeed = 17
					VerticalSwayAmp = .25
				end	
				L_97_ = 70
				L_133_.target = Vector3.new()
				AimEvent:FireServer(false)
				IsAiming = false
			end
		end;
		
		if Input.UserInputType == (Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.ButtonR2) and not isInputBlocked then
			Mouse1Holding = false				
			if Shooting then
				Shooting = false
			end
		end;
		
		if Input.KeyCode == Enum.KeyCode.E and L_15_ then
			local L_323_ = MainGUI:WaitForChild('GameGui')
			if L_16_ then
				L_323_:WaitForChild('AmmoFrame').Visible = false
				L_16_ = false
			end
		end;
		
		if Input.KeyCode == (Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.ButtonL3) and not isInputBlocked and not IsExecutingAction and not AimMode then -- SPRINT
			IsSprintKeyDown = false
			if IsSprinting and not IsAiming and not Shooting and not IsSprintKeyDown then
				IsSprinting = false
				CanSprint = false
				L_97_ = 70
			
				Character.Humanoid.WalkSpeed = 16
				VerticalSwayAmp = 0.09
				SwaySpeed = 11
			end
		end;
	end
end)

UIS.InputChanged:Connect(function(L_324_arg1, L_325_arg2)
	if not L_325_arg2 and L_15_ and ClientConfig.FirstPersonOnly and IsAiming then
		if L_324_arg1.UserInputType == Enum.UserInputType.MouseWheel then
			if L_324_arg1.Position.Z == 1 and (MouseSens < 1) then
				MouseSens = MouseSens + ClientConfig.SensitivityIncrement
			elseif L_324_arg1.Position.Z == -1 and (MouseSens > 0.1) then
				MouseSens = MouseSens - ClientConfig.SensitivityIncrement
			end
		end
	end
end)

UIS.InputChanged:Connect(function(L_326_arg1, L_327_arg2)
	if not L_327_arg2 and L_15_ then
		local L_328_, L_329_ = workspace:FindPartOnRayWithIgnoreList(Ray.new(AimPart.CFrame.p, (AimPart.CFrame.lookVector).unit * 10000), IgnoreList);
		if L_328_ then
			local L_330_ = (L_329_ - Torso.Position).magnitude
			DistDisplay.Text = math.ceil(L_330_) .. ' m'
		end
	end
end)

--// Event Connections
AimEvent.OnClientEvent:Connect(function(L_331_arg1, L_332_arg2)
	if L_331_arg1 ~= Player then
		local L_333_ = L_331_arg1.Character
		local L_334_ = L_333_.AnimBase.AnimBaseW
		local L_335_ = L_334_.C1
		if L_332_arg2 then
			L_130_(L_334_,  nil , L_333_.Head.CFrame, function(L_336_arg1)
				return math.sin(math.rad(L_336_arg1))
			end, 0.25)
		elseif not L_332_arg2 then
			L_130_(L_334_,  nil , L_335_, function(L_337_arg1)
				return math.sin(math.rad(L_337_arg1))
			end, 0.25)
		end
	end
end)

ServerFXEvent.OnClientEvent:Connect(function(L_338_arg1, L_339_arg2)
	if MainGUI and L_339_arg2 ~= Player and ClientConfig.CanCallout then
		if (Character.HumanoidRootPart.Position - L_338_arg1).magnitude <= 10 then
			local L_340_ = ScreamCalculation()
			if L_340_ then
				if Head:FindFirstChild('AHH') and not Head.AHH.IsPlaying then
					ChangeIDEvent:FireServer(Head.AHH, L_99_[math.random(0, 21)])
				end
			end
		end
	end
end)

--// UI Tween Info
local L_166_ = TweenInfo.new(
	1,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local L_167_ = {
	TextTransparency = 1
}



--[[killEvent.OnClientEvent:Connect(function()
	KillText.TextTransparency = 0
	delay(2, function()
		local testTween = tweenService:Create(KillText,killInfo,killGoals)
		testTween:Play()
	end)
end)]]--

--// Animations
local L_168_

function IdleAnim(L_341_arg1)
	ClientConfig.IdleAnim(Character, L_168_, {
		AnimBaseW,
		RightArmW,
		LeftArmW
	});
end;

function EquipAnim(L_342_arg1)
	ClientConfig.EquipAnim(Character, L_168_, {
		AnimBaseW
	});
end;

function UnequipAnim(L_343_arg1)
	ClientConfig.UnequipAnim(Character, L_168_, {
		AnimBaseW
	});
end;

function FireModeAnim(L_344_arg1)
	ClientConfig.FireModeAnim(Character, L_168_, {
		AnimBaseW,
		LeftArmW,
		RightArmW,
		Grip
	});
end

function ReloadAnim(L_345_arg1)
	ClientConfig.ReloadAnim(Character, L_168_, {
		[1] = false,
		[2] = RightArmW,
		[3] = LeftArmW,
		[4] = Mag,
		[5] = false,
		[6] = Grip
	});
end;

function BoltingBackAnim(L_346_arg1)
	ClientConfig.BoltingBackAnim(Character, L_168_, {
		L_49_
	});
end

function BoltingForwardAnim(L_347_arg1)
	ClientConfig.BoltingForwardAnim(Character, L_168_, {
		L_49_
	});
end

function BoltingForwardAnim(L_348_arg1)
	ClientConfig.BoltingForwardAnim(Character, L_168_, {
		L_49_
	});
end

function BoltBackAnim(L_349_arg1)
	ClientConfig.BoltBackAnim(Character, L_168_, {
		L_49_,
		LeftArmW,
		RightArmW,
		AnimBaseW,
		Bolt
	});
end

function BoltForwardAnim(L_350_arg1)
	ClientConfig.BoltForwardAnim(Character, L_168_, {
		L_49_,
		LeftArmW,
		RightArmW,
		AnimBaseW,
		Bolt
	});
end

function InspectAnim(L_351_arg1)
	ClientConfig.InspectAnim(Character, L_168_, {
		LeftArmW,
		RightArmW
	});
end

function nadeReload(L_352_arg1)
	ClientConfig.nadeReload(Character, L_168_, {
		RightArmW,
		LeftArmW
	});
end

function AttachAnim(L_353_arg1)
	ClientConfig.AttachAnim(Character, L_168_, {
		RightArmW,
		LeftArmW
	});
end

function PatrolAnim(L_354_arg1)
	ClientConfig.PatrolAnim(Character, L_168_, {
		RightArmW,
		LeftArmW
	});
end