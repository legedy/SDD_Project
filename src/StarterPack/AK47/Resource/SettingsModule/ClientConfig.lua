local Tool = script.Parent.Parent.Parent
local Utilize = require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Utilities"))
local TweenJoint = Utilize.TweenJoint
local ts = game:GetService('TweenService')

local Settings = {

--// Positioning
	SprintPos = CFrame.new(0, 0, 0, 0.844756603, -0.251352191, 0.472449303, 0.103136979, 0.942750931, 0.317149073, -0.525118113, -0.219186768, 0.822318792);
	RightArmPos = CFrame.new(-0.902175903, 0.295501232, -1.32277012, 1, 0, 0, 0, 1.19248806e-08, 1, 0, -1, 1.19248806e-08);
	LeftArmPos = CFrame.new(1.06851184, 0.973718464, -2.29667926, 0.787567914, -0.220087856, 0.575584888, -0.615963876, -0.308488727, 0.724860668, 0.0180283934, -0.925416589, -0.378522098);
	GunPos = CFrame.new(0.284460306, -0.318524063, 1.06423128, 1, 0, 0, 0, -2.98023224e-08, -0.99999994, 0, 0.99999994, -2.98023224e-08);

--// Ammo Settings			
	Ammo = 30;
	StoredAmmo = 30;
	MagCount = 6; --  If you want infinate ammo, set to math.huge EX. MagCount = math.huge;
	
--// Damage Settings	
	BaseDamage = 120; -- Torso Damage
	LimbshotMultiplier = 1; -- Arms and Legs
	HeadshotMultiplier = 4;
	
--// Recoil Settings	
	GunRecoil = -0.3; -- How much the gun recoils backwards when not aiming
	CamRecoil = 1; -- How much the camera flicks when not aiming
	AimGunRecoil = -0.3; -- How much the gun recoils backwards when aiming
	AimCamRecoil = 0.8; -- How much the camera flicks when aiming
	
	CamShake = 1; -- Controls camera shake when firing
	AimCamShake = 0.5; -- Controls aim camera shake when firing
	
	Kickback = 0.2; -- Upward gun rotation when not aiming
	AimKickback = 0.15; -- Upward gun rotation when aiming
	
--// Handling Settings		
	Firerate = 60 / 700; -- 60 = 1 Minute, 700 = Rounds per that 60 seconds. DO NOT TOUCH THE 60!
	
	FireMode = 2; -- 1 = Semi, 2 = Auto
	
--// Firemode Settings
	SemiEnabled = true;
	AutoEnabled = true;
	
--// Aim|Zoom|Sensitivity Customization
	ZoomSpeed = 0.25; -- The lower the number the slower and smoother the tween
	AimZoom = 50; -- Default zoom
	AimSpeed = 0.45;
	UnaimSpeed = 0.35;
	CycleAimZoom = 4; -- Cycled zoom
	MouseSensitivity = 0.5; -- Number between 0.1 and 1
	SensitivityIncrement = 0.05; -- No touchy
	
--// Bullet Physics
	BulletPhysics = Vector3.new(0,55,0); -- Drop fixation: Lower number = more drop
	BulletSpeed = 2953; -- Bullet Speed
	BulletSpread = 1; -- How much spread the bullet has

-- Customization
	MouseSense = 0.5;
	
	SprintSpeed = 20;

--// KeyBindings
	AlternateAimKey = Enum.KeyCode.Z;
	InspectionKey = Enum.KeyCode.H;
	AttachmentKey = Enum.KeyCode.LeftControl;

		
--// Animations
	
	-- Idle Anim
	IdleAnim = function(char, speed, objs)
		TweenJoint(objs[2],  nil , CFrame.new(-0.902175903, 0.295501232, -1.32277012, 1, 0, 0, 0, 1.19248806e-08, 1, 0, -1, 1.19248806e-08), function(X) return math.sin(math.rad(X)) end, 0.25)
		TweenJoint(objs[3],  nil , CFrame.new(1.06851184, 0.973718464, -2.29667926, 0.787567914, -0.220087856, 0.575584888, -0.615963876, -0.308488727, 0.724860668, 0.0180283934, -0.925416589, -0.378522098), function(X) return math.sin(math.rad(X)) end, 0.25)
		task.wait(0.18)	
	end;
	
	ReloadAnim = function(char, speed, objs)
			ts:Create(objs[2],TweenInfo.new(0.5),{C1 = CFrame.new(-1.13045335, -0.385085344, -1.60160995, 0.996194661, -0.0871555507, -3.8096899e-09, -0.0435778052, -0.498097777, 0.866025209, -0.0754788965, -0.862729728, -0.500000358)}):Play()
			ts:Create(objs[3],TweenInfo.new(0.5),{C1 = CFrame.new(0.306991339, 0.173449978, -2.47386241, 0.596156955, -0.666716337, 0.447309881, -0.79129082, -0.393649101, 0.4678666, -0.135851175, -0.632874191, -0.762243152)}):Play()
			task.wait(0.5)		
			
			local MagC = objs[4]:clone()
			MagC:FindFirstChild("Mag"):Destroy()
			MagC.Parent = Tool
			MagC.Name = "MagC"
			local MagCW = Instance.new("Motor6D")
			MagCW.Part0 = MagC
			MagCW.Part1 = objs[1]:WaitForChild("Left Arm")
			MagCW.Parent = MagC
			MagCW.C1 = MagC.CFrame:toObjectSpace(objs[4].CFrame)
			objs[4].Transparency = 1
			
			objs[6]:WaitForChild("MagOut"):Play()
			
			ts:Create(objs[3],TweenInfo.new(0.4),{C1 = CFrame.new(-0.0507154427, -0.345223904, -3.19228816, 0.625797808, -0.752114773, 0.206640378, -0.779792726, -0.609173417, 0.144329756, 0.0173272491, -0.2514579, -0.967713058)}):Play()
			ts:Create(objs[2],TweenInfo.new(0.13),{C1 = CFrame.new(-1.13045335, -0.385085344, -1.63183177, 0.996194661, -0.0871555507, -3.8096899e-09, -0.0435778052, -0.498097777, 0.866025209, -0.0754788965, -0.862729728, -0.500000358)}):Play()
			task.wait(0.1)
			ts:Create(objs[2],TweenInfo.new(0.4),{C1 = CFrame.new(-1.13045335, -0.385085344, -1.60160995, 0.996194661, -0.0871555507, -3.8096899e-09, -0.0435778052, -0.498097777, 0.866025209, -0.0754788965, -0.862729728, -0.500000358)}):Play()
			ts:Create(objs[3],TweenInfo.new(0.5),{C1 = CFrame.new(-0.0507154427, -0.345223933, -3.1922884, 0.625797808, -0.752114773, 0.206640378, 0.0507019535, 0.303593874, 0.95145148, -0.778335571, -0.584939361, 0.2281221)}):Play()
			task.wait(0.55)
			objs[6]:WaitForChild("MagFall"):Play()
			task.wait(0.25)
			ts:Create(objs[3],TweenInfo.new(0.3),{C1 = CFrame.new(-1.23319471, 0.238857567, -2.20046425, 0.360941499, -0.928539753, -0.0868042335, -0.476528496, -0.263641387, 0.838697612, -0.801649332, -0.261356145, -0.53763473)}):Play()
			task.wait(0.22)
			ts:Create(objs[3],TweenInfo.new(0.3),{C1 = CFrame.new(-0.0507154427, -0.345223904, -3.19228816, 0.625797808, -0.752114773, 0.206640378, -0.779792726, -0.609173417, 0.144329756, 0.0173272491, -0.2514579, -0.967713058)}):Play()
			task.wait(0.22)
			objs[6]:WaitForChild('MagIn'):Play()
			ts:Create(objs[3],TweenInfo.new(0.2),{C1 = CFrame.new(0.306991339, 0.173449978, -2.47386241, 0.596156955, -0.666716337, 0.447309881, -0.79129082, -0.393649101, 0.4678666, -0.135851175, -0.632874191, -0.762243152)}):Play()
			task.wait(0.16)
			ts:Create(objs[2],TweenInfo.new(0.13),{C1 = CFrame.new(-1.13045335, -0.385085344, -1.51256108, 0.996194661, -0.0871555507, -3.8096899e-09, -0.0435778052, -0.498097777, 0.866025209, -0.0754788965, -0.862729728, -0.500000358)}):Play()
			ts:Create(objs[3],TweenInfo.new(0.13),{C1 = CFrame.new(0.306991339, 0.173449978, -2.37906742, 0.596156955, -0.666716337, 0.447309881, -0.79129082, -0.393649101, 0.4678666, -0.135851175, -0.632874191, -0.762243152)}):Play()
			task.wait(0.13)
			MagC:Destroy()
			objs[4].Transparency = 0
			TweenJoint(objs[3],  nil , CFrame.new(1.06851184, 0.973718464, -2.29667926, 0.787567914, -0.220087856, 0.575584888, -0.615963876, -0.308488727, 0.724860668, 0.0180283934, -0.925416589, -0.378522098), function(X) return math.sin(math.rad(X)) end, 0.25)
		end;
		
		-- Bolting Back
		BoltingBackAnim = function(char, speed, objs)
			TweenJoint(objs[1],  nil , CFrame.new(0, 0, 0.673770154, 1, 0, 0, 0, 1, 0, 0, 0, 1), function(X) return math.sin(math.rad(X)) end, 0.001)
		end;
		
		BoltingForwardAnim = function(char, speed, objs)
			TweenJoint(objs[1],  nil , CFrame.new(), function(X) return math.sin(math.rad(X)) end, 0.001)
		end;
	
	}

return Settings
