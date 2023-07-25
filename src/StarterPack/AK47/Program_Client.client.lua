repeat
	wait()
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
local L_17_ = true

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

local L_53_ = game.ReplicatedStorage:FindFirstChild('SoundIso_Network') or nil
local L_54_
if L_53_ then
	L_54_ = L_53_:WaitForChild('EventConnection')
end

--// Weapon Parts
local AimPart = Gun:WaitForChild('AimPart')
local Grip = Gun:WaitForChild('Grip')
local FirePart = Gun:WaitForChild('FirePart')
local L_60_
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
local isBoltBack = false
local isBoltForward = false
local isIdle = false
local isInspecting = false
local isInputBlocked = false
local isInMenu = false
local isFiringModeChanging = false

local hasExplosiveEnabled = false
local previousFireMode = true
local L_85_ = true

local L_86_ = false

local L_89_
local L_90_
local L_91_

local L_92_ = ClientConfig.FireMode

local L_93_ = 0
local L_94_ = false
local L_95_ = true
local L_96_ = false

local L_97_ = 70

--// Tables
local L_98_ = {
	
	"285421759";
	"151130102";
	"151130171";
	"285421804";
	"287769483";
	"287769415";
	"285421687";
	"287769261";
	"287772525";
	"287772445";
	"287772351";
	"285421819";
	"287772163";
	
}

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

local L_103_ = ClientConfig.Ammo
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
	Ammo.Text = L_103_
	AmmoBG.Text = Ammo.Text
	
	MagCount.Text = '| ' .. math.ceil(TotalAmmo / ClientConfig.StoredAmmo)
	MagCountBG.Text = MagCount.Text
	
	if L_92_ == 1 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0.7
		Mode3.BackgroundTransparency = 0.7
		Mode4.BackgroundTransparency = 0.7
		Mode5.BackgroundTransparency = 0.7
	elseif L_92_ == 2 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0
		Mode5.BackgroundTransparency = 0
	elseif L_92_ == 3 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0.7
		Mode5.BackgroundTransparency = 0.7
	elseif L_92_ == 4 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0
		Mode5.BackgroundTransparency = 0.7
	elseif L_92_ == 5 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0.7
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0.7
		Mode5.BackgroundTransparency = 0.7
	elseif L_92_ == 6 then
		Mode1.BackgroundTransparency = 0
		Mode2.BackgroundTransparency = 0.7
		Mode3.BackgroundTransparency = 0
		Mode4.BackgroundTransparency = 0
		Mode5.BackgroundTransparency = 0.7
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
		
		if Gun:FindFirstChild('FirePart2') then
			L_60_ = Gun.FirePart2
		end
		
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
		
	if not hasExplosiveEnabled then
		L_208_.Force = ClientConfig.BulletPhysics
		L_205_.Velocity = L_202_ * ClientConfig.BulletSpeed
	else
		L_208_.Force = ClientConfig.ExploPhysics
		L_205_.Velocity = L_202_ * ClientConfig.ExploSpeed
	end
		
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
		
	if Gun:FindFirstChild('Shell') and not hasExplosiveEnabled then	
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
	local L_217_, L_218_, L_219_
	local L_220_ = AimPart.Position;
	local L_221_ = L_216_arg1.Position;
	local L_222_ = 0

	local L_223_ = hasExplosiveEnabled	
	
	while true do
		RenderStep:wait()
		L_221_ = L_216_arg1.Position;
		L_222_ = L_222_ + (L_221_ - L_220_).magnitude
		L_217_, L_218_, L_219_ = workspace:FindPartOnRayWithIgnoreList(Ray.new(L_220_, (L_221_ - L_220_)), IgnoreList);
		local L_224_ = Vector3.new(0, 1, 0):Cross(L_219_)
		local L_225_ = math.asin(L_224_.magnitude) -- division by 1 is redundant
		if L_222_ > ClientConfig.BulletDecay then
			L_216_arg1:Destroy()
			break
		end
		if L_217_ and (L_217_ and L_217_.Transparency >= 1 or L_217_.CanCollide == false) and L_217_.Name ~= 'Right Arm' and L_217_.Name ~= 'Left Arm' and L_217_.Name ~= 'Right Leg' and L_217_.Name ~= 'Left Leg' and L_217_.Name ~= 'Armor' then
			table.insert(IgnoreList, L_217_)
		end
	
		if L_217_ then
			L_224_ = Vector3.new(0, 1, 0):Cross(L_219_)
			L_225_ = math.asin(L_224_.magnitude) -- division by 1 is redundant
		
			ServerFXEvent:FireServer(L_218_)
		
			local L_226_ = CheckForHumanoid(L_217_)
			if L_226_ == false then
				L_216_arg1:Destroy()
				HitEvent:InvokeServer(L_218_, L_224_, L_225_, L_219_, "Part", L_217_)
			elseif L_226_ == true then
				L_216_arg1:Destroy()
				HitEvent:InvokeServer(L_218_, L_224_, L_225_, L_219_, "Human", L_217_)
			end
		end
	
		if L_217_ and L_223_ then
			ExplosionEvent:FireServer(L_218_)
		end
	
		if L_217_ then
			local L_229_, L_230_ = CheckForHumanoid(L_217_)
			if L_229_ then
				CreateOwner:FireServer(L_230_)
				if ClientConfig.AntiTK then
					if game.Players:FindFirstChild(L_230_.Parent.Name) and game.Players:FindFirstChild(L_230_.Parent.Name).TeamColor ~= Player.TeamColor or L_230_.Parent:FindFirstChild('Vars') and game.Players:FindFirstChild(L_230_.Parent:WaitForChild('Vars'):WaitForChild('BotID').Value) and Player.TeamColor ~= L_230_.Parent:WaitForChild('Vars'):WaitForChild('teamColor').Value then
						if L_217_.Name == 'Head' then
							DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
							local L_231_ = Effects:WaitForChild('BodyHit'):clone()
							L_231_.Parent = Player.PlayerGui
							L_231_:Play()
							game:GetService("Debris"):addItem(L_231_, L_231_.TimeLength)
						end
						if L_217_.Name ~= 'Head' and not (L_217_.Parent:IsA('Accessory') or L_217_.Parent:IsA('Hat')) then
							if L_217_.Name ~= 'Torso' and L_217_.Name ~= 'HumanoidRootPart' and L_217_.Name ~= 'Armor' then
								DamageEvent:FireServer(L_230_, ClientConfig.LimbDamage)
							elseif L_217_.Name == 'Torso' or L_217_.Name == 'HumanoidRootPart' and L_217_.Name ~= 'Armor'  then
								DamageEvent:FireServer(L_230_, ClientConfig.BaseDamage)
							elseif L_217_.Name == 'Armor' then
								DamageEvent:FireServer(L_230_, ClientConfig.ArmorDamage)
							end
							local L_232_ = Effects:WaitForChild('BodyHit'):clone()
							L_232_.Parent = Player.PlayerGui
							L_232_:Play()
							game:GetService("Debris"):addItem(L_232_, L_232_.TimeLength)
						end
						if (L_217_.Parent:IsA('Accessory') or L_217_.Parent:IsA('Hat')) then
							DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
							local L_233_ = Effects:WaitForChild('BodyHit'):clone()
							L_233_.Parent = Player.PlayerGui
							L_233_:Play()
							game:GetService("Debris"):addItem(L_233_, L_233_.TimeLength)
						end
					end
				else
					if L_217_.Name == 'Head' then
						DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
						local L_234_ = Effects:WaitForChild('BodyHit'):clone()
						L_234_.Parent = Player.PlayerGui
						L_234_:Play()
						game:GetService("Debris"):addItem(L_234_, L_234_.TimeLength)
					end
					if L_217_.Name ~= 'Head' and not (L_217_.Parent:IsA('Accessory') or L_217_.Parent:IsA('Hat')) then
						if L_217_.Name ~= 'Torso' and L_217_.Name ~= 'HumanoidRootPart' and L_217_.Name ~= 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.LimbDamage)
						elseif L_217_.Name == 'Torso' or L_217_.Name == 'HumanoidRootPart' and L_217_.Name ~= 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.BaseDamage)
						elseif L_217_.Name == 'Armor' then
							DamageEvent:FireServer(L_230_, ClientConfig.ArmorDamage)
						end
						local L_235_ = Effects:WaitForChild('BodyHit'):clone()
						L_235_.Parent = Player.PlayerGui
						L_235_:Play()
						game:GetService("Debris"):addItem(L_235_, L_235_.TimeLength)
					end
					if (L_217_.Parent:IsA('Accessory') or L_217_.Parent:IsA('Hat')) then
						DamageEvent:FireServer(L_230_, ClientConfig.HeadDamage)
						local L_236_ = Effects:WaitForChild('BodyHit'):clone()
						L_236_.Parent = Player.PlayerGui
						L_236_:Play()
						game:GetService("Debris"):addItem(L_236_, L_236_.TimeLength)
					end
				end	
			end
		end
	
		if L_217_ and L_217_.Parent:FindFirstChild("Humanoid") then
			return L_217_, L_218_;
		end
		L_220_ = L_221_;
	end
end

function fireSemi()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		
		if L_54_ then
			L_54_:FireServer(FirePart:WaitForChild('Fire').SoundId, FirePart)
		else
			FirePart:WaitForChild('Fire'):Play()	
		end
		ShootEvent:FireServer()
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		L_103_ = L_103_ - 1
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
					if L_103_ > 0 then
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

function fireExplo()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		if L_54_ then
			L_54_:FireServer(L_60_:WaitForChild('Fire').SoundId, L_60_)
		else
			L_60_:WaitForChild('Fire'):Play()	
		end
		ShootEvent:FireServer()
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		L_105_ = L_105_ - 1
		UpdateAmmo()
		RecoilFront = true
		local L_240_, L_241_ = spawn(function()
			CastRay(L_102_)
		end)
		
		delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)		
			
		CanShoot = false
		Shooting = false
	end
end

function fireShot()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		RecoilFront = true
		
		if L_54_ then
			L_54_:FireServer(FirePart:WaitForChild('Fire').SoundId, FirePart)
		else
			FirePart:WaitForChild('Fire'):Play()	
		end
		ShootEvent:FireServer()
		for L_243_forvar1 = 1, ClientConfig.ShotNum do
			spawn(function()
				L_102_ = CreateBullet(ClientConfig.BulletSpread)
			end)
			local L_244_, L_245_ = spawn(function()
				CastRay(L_102_)
			end)
		end
						
		for L_246_forvar1, L_247_forvar2 in pairs(FirePart:GetChildren()) do
			if L_247_forvar2.Name:sub(1, 7) == "FlashFX" then
				L_247_forvar2.Enabled = true
			end
		end
	
		delay(1 / 30, function()
			for L_248_forvar1, L_249_forvar2 in pairs(FirePart:GetChildren()) do
				if L_249_forvar2.Name:sub(1, 7) == "FlashFX" then
					L_249_forvar2.Enabled = false
				end
			end
		end)
		
		if ClientConfig.CanBolt == true then
			BoltingBackAnim()
			delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if L_103_ > 0 then
						BoltingForwardAnim()
					end
				end
			end)
		end
		
		delay(ClientConfig.Firerate / 2, function()
			Recoiling = false
			RecoilFront = false
		end)
		L_103_ = L_103_ - 1
		UpdateAmmo()
		wait(ClientConfig.Firerate)
		
		isInspecting = true
		BoltBackAnim()
		BoltForwardAnim()
		IdleAnim()
		isInspecting = false
		
		CanShoot = not JamCalculation()
		
		Shooting = false
	end
end

function fireBoltAction()
	if L_15_ then
		CanShoot = false
		Recoiling = true
		Shooting = true
		
		if L_54_ then
			L_54_:FireServer(FirePart:WaitForChild('Fire').SoundId, FirePart)
		else
			FirePart:WaitForChild('Fire'):Play()	
		end
		ShootEvent:FireServer()
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		L_103_ = L_103_ - 1
		UpdateAmmo()
		RecoilFront = true
		local L_250_, L_251_ = spawn(function()
			CastRay(L_102_)
		end)
						
		for L_253_forvar1, L_254_forvar2 in pairs(FirePart:GetChildren()) do
			if L_254_forvar2.Name:sub(1, 7) == "FlashFX" then
				L_254_forvar2.Enabled = true
			end
		end
	
		delay(1 / 30, function()
			for L_255_forvar1, L_256_forvar2 in pairs(FirePart:GetChildren()) do
				if L_256_forvar2.Name:sub(1, 7) == "FlashFX" then
					L_256_forvar2.Enabled = false
				end
			end
		end)
		
		if ClientConfig.CanBolt == true then
			BoltingBackAnim()
			delay(ClientConfig.Firerate / 2, function()
				if ClientConfig.CanSlideLock == false then
					BoltingForwardAnim()
				elseif ClientConfig.CanSlideLock == true then
					if L_103_ > 0 then
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
		
		isInspecting = true
		BoltBackAnim()
		BoltForwardAnim()
		IdleAnim()
		isInspecting = false
		
		CanShoot = not JamCalculation()
		
		Shooting = false
	end
end

function fireAuto()
	while not Shooting and L_103_ > 0 and Mouse1Holding and CanShoot and L_15_ do
		CanShoot = false
		Recoiling = true
		if L_54_ then
			L_54_:FireServer(FirePart:WaitForChild('Fire').SoundId, FirePart)
		else
			FirePart:WaitForChild('Fire'):Play()	
		end
		ShootEvent:FireServer()
		L_103_ = L_103_ - 1
		UpdateAmmo()
		Shooting = true
		RecoilFront = true
		L_102_ = CreateBullet(ClientConfig.BulletSpread)
		local L_257_, L_258_ = spawn(function()
			CastRay(L_102_)
		end)
					
		for L_260_forvar1, L_261_forvar2 in pairs(FirePart:GetChildren()) do
			if L_261_forvar2.Name:sub(1, 7) == "FlashFX" then
				L_261_forvar2.Enabled = true
			end
		end
	
		delay(1 / 30, function()
			for L_262_forvar1, L_263_forvar2 in pairs(FirePart:GetChildren()) do
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
					if L_103_ > 0 then
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

function fireBurst()
	if not Shooting and L_103_ > 0 and Mouse1Holding and L_15_ then
		for L_264_forvar1 = 1, ClientConfig.BurstNum do
			if L_103_ > 0 and Mouse1Holding then
				CanShoot = false
				Recoiling = true
				
				if L_54_ then
					L_54_:FireServer(FirePart:WaitForChild('Fire').SoundId, FirePart)
				else
					FirePart:WaitForChild('Fire'):Play()	
				end
				ShootEvent:FireServer()
				L_102_ = CreateBullet(ClientConfig.BulletSpread)
				local L_265_, L_266_ = spawn(function()
					CastRay(L_102_)
				end)
					
				for L_268_forvar1, L_269_forvar2 in pairs(FirePart:GetChildren()) do
					if L_269_forvar2.Name:sub(1, 7) == "FlashFX" then
						L_269_forvar2.Enabled = true
					end
				end
		
				delay(1 / 30, function()
					for L_270_forvar1, L_271_forvar2 in pairs(FirePart:GetChildren()) do
						if L_271_forvar2.Name:sub(1, 7) == "FlashFX" then
							L_271_forvar2.Enabled = false
						end
					end
				end)
			
				if ClientConfig.CanBolt == true then
					BoltingBackAnim()
					delay(ClientConfig.Firerate / 2, function()
						if ClientConfig.CanSlideLock == false then
							BoltingForwardAnim()
						elseif ClientConfig.CanSlideLock == true then
							if L_103_ > 0 then
								BoltingForwardAnim()
							end
						end
					end)
				end
			
				L_103_ = L_103_ - 1
				UpdateAmmo()
				RecoilFront = true
				delay(ClientConfig.Firerate / 2, function()
					Recoiling = false
					RecoilFront = false
				end)
				wait(ClientConfig.Firerate)
			
				CanShoot = not JamCalculation()
		
			end
			Shooting = true
		end
		Shooting = false
	end
end

function Shoot()
	if L_15_ and CanShoot then
		if L_92_ == 1 then
			fireSemi()
		elseif L_92_ == 2 then
			fireAuto()
		elseif L_92_ == 3 then
			fireBurst()	
		elseif L_92_ == 4 then
			fireBoltAction()
		elseif L_92_ == 5 then
			fireShot()
		elseif L_92_ == 6 then
			fireExplo()
		end
	end
end

--// Walk and Sway
local L_136_

local L_140_ = 0
local L_141_ = 0
local L_142_ = 35 --This is the limit of the mouse input for the sway
local L_143_ = -9 --This is the magnitude of the sway when you're unaimed
local L_144_ = -9 --This is the magnitude of the sway when you're aimed

--local Sprinting =false
local L_145_ = SpringModule.new(Vector3.new())
L_145_.s = 15
L_145_.d = 0.5

game:GetService("UserInputService").InputChanged:Connect(function(L_272_arg1) --Get the mouse delta for the gun sway
	if L_272_arg1.UserInputType == Enum.UserInputType.MouseMovement then
		L_140_ = math.min(math.max(L_272_arg1.Delta.x, -L_142_), L_142_)
		L_141_ = math.min(math.max(L_272_arg1.Delta.y, -L_142_), L_142_)
	end
end)

Mouse.Idle:Connect(function() --Reset the sway to 0 when the mouse is still
	L_140_ = 0
	L_141_ = 0
end)

local L_146_ = false
local L_147_ = CFrame.new()
local L_148_ = CFrame.new()

local L_149_ 
local L_150_
local L_151_
local L_152_

local L_153_
local L_154_
local L_155_

if not ClientConfig.TacticalModeEnabled then
	L_149_ = 0
	L_150_ = CFrame.new()
	L_151_ = 0.1
	L_152_ = 2
	
	L_153_ = 0
	L_154_ = .2
	L_155_ = 17
else
	L_149_ = 0
	L_150_ = CFrame.new()
	L_151_ = 0.05
	L_152_ = 2
	
	L_153_ = 0
	L_154_ = 0.09
	L_155_ = 11
end

local L_156_ = 0
local L_157_ = 5
local L_158_ = .3

local L_159_, L_160_ = 0, 0

local L_161_ = nil
local L_162_ = nil
local L_163_ = nil

Character.Humanoid.Running:Connect(function(L_273_arg1)
	if L_273_arg1 > 1 then
		L_146_ = true
	else
		L_146_ = false
	end
end)

--// Renders
local L_164_

RenderStep:Connect(function()
	if L_15_ then
		L_159_, L_160_ = L_159_ or 0, L_160_ or 0
		if L_162_ == nil or L_161_ == nil then
			L_162_ = AnimBaseW.C0
			L_161_ = AnimBaseW.C1
		end
		
		local L_274_ = (math.sin(L_153_ * L_155_ / 2) * L_154_)
		local L_275_ = (math.sin(L_153_ * L_155_) * L_154_)
		local L_276_ = CFrame.new(L_274_, L_275_, 0.02)
		
		local L_277_ = (math.sin(L_153_ * L_155_ / 2) * L_154_)
		local L_278_ = (math.sin(L_153_ * L_155_) * L_154_)
		local L_279_ = CFrame.new(L_274_, L_275_, 0.02) * CFrame.Angles((math.cos(L_153_ * L_155_) * L_154_), (math.cos(L_153_ * L_155_ / 2) * L_154_), 0)
		
		local L_280_ = (math.sin(L_149_ * L_152_ / 2) * L_151_)
		local L_281_ = (math.cos(L_149_ * L_152_) * L_151_)
		local L_282_ = CFrame.new(L_280_, L_281_, 0.02)
		
		if L_146_ then
			L_153_ = L_153_ + .017
			if ClientConfig.WalkAnimEnabled == true then
				if ClientConfig.TacticalModeEnabled then
					L_147_ = L_279_
				else
					L_147_ = L_276_
				end
			else
				L_147_ = CFrame.new()
			end
		else
			L_153_ = 0
			L_147_ = CFrame.new()
		end
		
		L_145_.t = Vector3.new(L_140_, L_141_, 0)
		local L_283_ = L_145_.p
		local L_284_ = L_283_.X / L_142_ * (IsAiming and L_144_ or L_143_)
		local L_285_ = L_283_.Y / L_142_ * (IsAiming and L_144_ or L_143_)
		
		Camera.CFrame = Camera.CFrame:lerp(Camera.CFrame * L_148_, 0.2)
		
		if IsAiming then
			L_136_ = CFrame.Angles(math.rad(-L_284_), math.rad(L_284_), math.rad(L_285_)) * CFrame.fromAxisAngle(Vector3.new(5, 0, -1), math.rad(L_284_))	
			L_149_ = 0
			L_150_ = CFrame.new()
		elseif IsAiming then
			L_136_ = CFrame.Angles(math.rad(-L_285_), math.rad(-L_284_), math.rad(-L_284_)) * CFrame.fromAxisAngle(AnimBase.Position, math.rad(-L_285_))
			L_149_ = L_149_ + 0.017			
			L_150_ = L_282_
		end
		
		if ClientConfig.SwayEnabled ==  true then
			AnimBaseW.C0 = AnimBaseW.C0:lerp(L_162_ * L_136_ * L_147_ * L_150_, 0.1)
		else
			AnimBaseW.C0 = AnimBaseW.C0:lerp(L_162_ * L_147_, 0.1)
		end		
		
		if IsSprinting and not IsExecutingAction and CanSprint and not IsAiming and not IsReloading and not Shooting then
			AnimBaseW.C1 = AnimBaseW.C1:lerp(AnimBaseW.C0 * ClientConfig.SprintPos, 0.1)
		elseif not IsSprinting and not IsExecutingAction and not CanSprint and not IsAiming and not IsReloading and not Shooting and not isFiringModeChanging then
			AnimBaseW.C1 = AnimBaseW.C1:lerp(CFrame.new() * L_134_, 0.05)
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
				AnimBaseW.C1 = AnimBaseW.C1:lerp(AnimBaseW.C0 * AimPart.CFrame:toObjectSpace(AnimBase.CFrame), ClientConfig.AimSpeed)
				
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Visible = true
				MainGUI:WaitForChild('Sense'):WaitForChild('Sensitivity').Text = MouseSens
				UIS.MouseDeltaSensitivity = MouseSens
			end
		elseif not IsAiming and not IsSprinting and L_15_ and not isFiringModeChanging then
			if (Character.Head.Position - Camera.CoordinateFrame.p).magnitude < 2 then
				AnimBaseW.C1 = AnimBaseW.C1:lerp(CFrame.new() * L_134_, ClientConfig.UnaimSpeed)
				
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
				L_148_ = CFrame.fromEulerAnglesXYZ(math.rad(L_90_ * math.random(0, ClientConfig.CamShake)), math.rad(L_90_ * math.random(-ClientConfig.CamShake, ClientConfig.CamShake)), math.rad(L_90_ * math.random(-ClientConfig.CamShake, ClientConfig.CamShake)))--CFrame.Angles(camrecoil,0,0)	
			else
				L_148_ = CFrame.fromEulerAnglesXYZ(math.rad(L_90_ * math.random(0, ClientConfig.AimCamShake)), math.rad(L_90_ * math.random(-ClientConfig.AimCamShake, ClientConfig.AimCamShake)), math.rad(L_90_ * math.random(-ClientConfig.AimCamShake, ClientConfig.AimCamShake)))
			end
			--cam.CoordinateFrame = cam.CoordinateFrame *  CFrame.fromEulerAnglesXYZ(math.rad(camrecoil*math.random(0,3)), math.rad(camrecoil*math.random(-1,1)), math.rad(camrecoil*math.random(-1,1)))
			AnimBaseW.C0 = AnimBaseW.C0:lerp(AnimBaseW.C0 * CFrame.new(0, 0, L_89_) * CFrame.Angles(-math.rad(L_91_), 0, 0), 0.3)
		elseif not Recoiling then	
			L_148_ = CFrame.Angles(0, 0, 0)
			AnimBaseW.C0 = AnimBaseW.C0:lerp(CFrame.new(), 0.2)
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
		if Input.UserInputType == (Enum.UserInputType.MouseButton2 or Input.KeyCode == Enum.KeyCode.ButtonL2) and not isFiringModeChanging and not isInMenu and not isInputBlocked and ClientConfig.CanAim and not isBoltForward and L_15_ and not IsReloading and not IsSprinting then
			if not IsAiming then
				if not AimMode then
					if ClientConfig.TacticalModeEnabled then
						L_154_ = 0.015
						L_155_ = 7
						Character:WaitForChild("Humanoid").WalkSpeed = 7
					else
						L_155_ = 10
						L_154_ = 0.008
						Character:WaitForChild("Humanoid").WalkSpeed = 10
					end
					
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
		
		if Input.KeyCode == ClientConfig.AlternateAimKey and not isFiringModeChanging and not isInMenu and not isInputBlocked and ClientConfig.CanAim and not isBoltForward and L_15_ and not IsReloading and not IsSprinting then
			if not IsAiming then
				if not AimMode then
					Character.Humanoid.WalkSpeed = 10
					L_155_ = 10
					L_154_ = 0.008
				end
				L_97_ = CurrenAimZoom
				L_133_.target = AimPart.CFrame:toObjectSpace(AnimBase.CFrame).p
				AimEvent:FireServer(true)
				IsAiming = true
			end
		end;
		
		if Input.UserInputType == (Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.ButtonR2) and not isFiringModeChanging and not isInputBlocked and CanShoot and L_15_ and not IsReloading and not IsSprinting and not isBoltForward then
			Mouse1Holding = true
			if not Shooting and L_15_ and not hasExplosiveEnabled then
				if L_103_ > 0 then			
					Shoot()
				end
			elseif not Shooting and L_15_ and hasExplosiveEnabled then
				if L_105_ > 0 then
					Shoot()
				end
			end
		end;
		
		if Input.KeyCode == (ClientConfig.LaserKey or Input.KeyCode == Enum.KeyCode.DPadRight) and L_15_ and ClientConfig.LaserAttached then
			Plugins.KeyDown[1].Plugin()
		end;
		
		if Input.KeyCode == (ClientConfig.LightKey or Input.KeyCode == Enum.KeyCode.ButtonR3) and L_15_ and ClientConfig.LightAttached then
			local L_317_ = Gun:FindFirstChild("FlashLight"):FindFirstChild('Light')
			L_317_.Enabled = not L_317_.Enabled
		end;
		
		if L_15_ and Input.KeyCode == (ClientConfig.FireSelectKey or Input.KeyCode == Enum.KeyCode.DPadUp) and not isFiringModeChanging and not IsExecutingAction and not isInMenu then
			IsExecutingAction = true
			if L_92_ == 1 then
				if Shooting then
					Shooting = false
				end
				if ClientConfig.AutoEnabled then
					L_92_ = 2
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.AutoEnabled and ClientConfig.BurstEnabled then
					L_92_ = 3
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled and ClientConfig.BoltAction then
					L_92_ = 4
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled and not ClientConfig.BoltAction and ClientConfig.ExplosiveEnabled then
					L_92_ = 6
					hasExplosiveEnabled = true
					previousFireMode = CanShoot
					CanShoot = L_85_
				elseif not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled and not ClientConfig.BoltAction and not ClientConfig.ExplosiveEnabled then
					L_92_ = 1
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				end
			elseif L_92_ == 2 then
				if Shooting then
					Shooting = false
				end
				if ClientConfig.BurstEnabled then
					L_92_ = 3
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BurstEnabled and ClientConfig.BoltAction then
					L_92_ = 4
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BurstEnabled and not ClientConfig.BoltAction and ClientConfig.ExplosiveEnabled then
					L_92_ = 6
					hasExplosiveEnabled = true
					previousFireMode = CanShoot
					CanShoot = L_85_
				elseif not ClientConfig.BurstEnabled and not ClientConfig.BoltAction and not ClientConfig.ExplosiveEnabled and ClientConfig.SemiEnabled then
					L_92_ = 1
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BurstEnabled and not ClientConfig.BoltAction and not ClientConfig.SemiEnabled then
					L_92_ = 2
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				end
			elseif L_92_ == 3 then
				if Shooting then
					Shooting = false
				end
				if ClientConfig.BoltAction then
					L_92_ = 4
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BoltAction and ClientConfig.ExplosiveEnabled then
					L_92_ = 6
					hasExplosiveEnabled = true
					previousFireMode = CanShoot
					CanShoot = L_85_
				elseif not ClientConfig.BoltAction and not ClientConfig.ExplosiveEnabled and ClientConfig.SemiEnabled then
					L_92_ = 1
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BoltAction and not ClientConfig.SemiEnabled and ClientConfig.AutoEnabled then
					L_92_ = 2
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.BoltAction and not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled then
					L_92_ = 3
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				end
			elseif L_92_ == 4 then
				if Shooting then
					Shooting = false
				end
				if ClientConfig.ExplosiveEnabled then
					L_92_ = 6
					hasExplosiveEnabled = true
					previousFireMode = CanShoot
					CanShoot = L_85_
				elseif not ClientConfig.ExplosiveEnabled and ClientConfig.SemiEnabled then
					L_92_ = 1
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and ClientConfig.AutoEnabled then
					L_92_ = 2
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled and ClientConfig.BurstEnabled then
					L_92_ = 3
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled then
					L_92_ = 4
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				end
			elseif L_92_ == 6 then
				if Shooting then
					Shooting = false
				end
				L_85_ = CanShoot
				if ClientConfig.SemiEnabled then
					L_92_ = 1
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and ClientConfig.AutoEnabled then
					L_92_ = 2
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled and ClientConfig.BurstEnabled then
					L_92_ = 3
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled and ClientConfig.BoltAction then
					L_92_ = 4
					hasExplosiveEnabled = false
					CanShoot = previousFireMode
				elseif not ClientConfig.SemiEnabled and not ClientConfig.AutoEnabled and not ClientConfig.BurstEnabled and not ClientConfig.BoltAction then
					L_92_ = 6
					hasExplosiveEnabled = true
					previousFireMode = CanShoot
					CanShoot = L_85_
				end
			end
			UpdateAmmo()
			FireModeAnim()
			IdleAnim()
			IsExecutingAction = false
		end;
		
		if Input.KeyCode == (Enum.KeyCode.F or Input.KeyCode == Enum.KeyCode.DPadDown) and not isFiringModeChanging and not isInputBlocked and not isInMenu and not IsSprinting and not IsExecutingAction and not IsAiming and not IsReloading and not Shooting and not isInspecting then			
			if not isBoltBack and not isBoltForward then
				isBoltForward = true
				Shooting = false
				CanShoot = false

				delay(0.6, function()
					if L_103_ ~= ClientConfig.Ammo and L_103_ > 0 then
						CreateShell()
					end
				end)	
				BoltBackAnim()
				isBoltBack = true
			elseif isBoltBack and isBoltForward then
				BoltForwardAnim()
				Shooting = false
				CanShoot = true
				if L_103_ ~= ClientConfig.Ammo and L_103_ > 0 then
					L_103_ = L_103_ - 1
				elseif L_103_ >= ClientConfig.Ammo then
					CanShoot = true
				end						
				isBoltBack = false
				isBoltForward = false
				IdleAnim()
				isIdle = false
			end
			UpdateAmmo()
		end;
		
		if Input.KeyCode == (Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.ButtonL3) and not isInMenu and not isInputBlocked and L_146_ then
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
				if ClientConfig.TacticalModeEnabled then
					L_154_ = 0.4
					L_155_ = 16
				else
					L_155_ = ClientConfig.SprintSpeed
					L_154_ = 0.4
				end
				Character.Humanoid.WalkSpeed = ClientConfig.SprintSpeed
			end
		end;
		
		if Input.KeyCode == (Enum.KeyCode.R or Input.KeyCode == Enum.KeyCode.ButtonX) and not isFiringModeChanging and not isInMenu and not isInputBlocked and L_15_ and not IsReloading and not IsAiming and not Shooting and not IsSprinting and not isBoltForward then		
			if not hasExplosiveEnabled then			
				if TotalAmmo > 0 and L_103_ < ClientConfig.Ammo then
					Shooting = false
					IsReloading = true
					
					for L_319_forvar1, L_320_forvar2 in pairs(game.Players:GetChildren()) do
						if L_320_forvar2 and L_320_forvar2:IsA('Player') and L_320_forvar2 ~= Player and L_320_forvar2.TeamColor == Player.TeamColor then
							if (L_320_forvar2.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).magnitude  <= 150 then
								if Head:FindFirstChild('AHH') and not Head.AHH.IsPlaying then
									ChangeIDEvent:FireServer(Head.AHH, L_100_[math.random(0, 23)])
								end
							end
						end
					end
					
					ReloadAnim()
					if L_103_ <= 0 then
						if not ClientConfig.CanSlideLock then
							BoltBackAnim()
							BoltForwardAnim()
						end
					end
					IdleAnim()
					CanShoot = true
					
					if L_103_ <= 0 then
						if (TotalAmmo - (ClientConfig.Ammo - L_103_)) < 0 then
							L_103_ = L_103_ + TotalAmmo
							TotalAmmo = 0
						else
							TotalAmmo = TotalAmmo - (ClientConfig.Ammo - L_103_)
							L_103_ = ClientConfig.Ammo
						end
					elseif L_103_ > 0 then
						if (TotalAmmo - (ClientConfig.Ammo - L_103_)) < 0 then
							L_103_ = L_103_ + TotalAmmo + 1
							TotalAmmo = 0
						else
							TotalAmmo = TotalAmmo - (ClientConfig.Ammo - L_103_)
							L_103_ = ClientConfig.Ammo + 0
						end
					end
	
					IsReloading = false
					if not isIdle then
						CanShoot = true
					end
				end;
			elseif hasExplosiveEnabled then
				if L_105_ > 0 then
					Shooting = false
					IsReloading = true
					nadeReload()
					IdleAnim()
					IsReloading = false
					CanShoot = true
				end
			end;
			UpdateAmmo()
		end;
		
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
		
		if Input.KeyCode == ClientConfig.InspectionKey and not isFiringModeChanging and not isInMenu then
			if not isInputBlocked then
				isInputBlocked = true
				InspectAnim()
				IdleAnim()
				isInputBlocked = false
			end
		end;
		
		if Input.KeyCode == ClientConfig.AttachmentKey and not isFiringModeChanging and not isInputBlocked then
			if L_15_ then
				if not isInMenu then
					IsSprinting = false
					IsAiming = false
					CanShoot = false
					isInMenu = true
					
					AttachAnim()
				elseif isInMenu then
					IsSprinting = false
					IsAiming = false
					CanShoot = true
					isInMenu = false
					
					IdleAnim()
				end
			end
		end;
			
		if Input.KeyCode == Enum.KeyCode.P and not isInputBlocked and not isInMenu and not IsAiming and not IsSprinting and not AimMode and not IsReloading and not Recoiling and not IsSprinting then
			if not isFiringModeChanging then
				isFiringModeChanging = true
				TweenService:Create(AnimBaseW, TweenInfo.new(0.2), {
					C1 = ClientConfig.SprintPos
				}):Play()
				wait(0.2)
				Stance:FireServer("Patrol", ClientConfig.SprintPos)
			else
				isFiringModeChanging = false
				TweenService:Create(AnimBaseW, TweenInfo.new(0.2), {
					C1 = CFrame.new()
				}):Play()
				wait(0.2)
				Stance:FireServer("Unpatrol")
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
					if ClientConfig.TacticalModeEnabled then
						L_154_ = 0.09
						L_155_ = 11
					else
						L_154_ = .2
						L_155_ = 17
					end
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
					L_155_ = 17
					L_154_ = .25
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
				if ClientConfig.TacticalModeEnabled then
					L_154_ = 0.09
					L_155_ = 11
				else
					L_154_ = .2
					L_155_ = 17
				end			
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