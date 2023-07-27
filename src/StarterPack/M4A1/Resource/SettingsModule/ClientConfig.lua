local Tool = script.Parent.Parent.Parent
local Utilize = require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Utilities"))
local TweenJoint = Utilize.TweenJoint

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
	BaseDamage = 140; -- Torso Damage
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
		wait(0.18)	
	end;
	
	-- Reload Anim
	ReloadAnim = function(char, speed, objs)
		TweenJoint(objs[2],  nil , CFrame.new(-0.630900264, 0.317047596, -1.27966166, 0.985866964, -0.167529628, -7.32295247e-09, 0, -4.37113883e-08, 1, -0.167529613, -0.985867023, -4.30936176e-08), function(X) return math.sin(math.rad(X)) end, 0.5)
		TweenJoint(objs[3],  nil , CFrame.new(0.436954767, 0.654289246, -1.82817471, 0.894326091, -0.267454475, 0.358676374, -0.413143814, -0.185948789, 0.891479254, -0.171734676, -0.945458114, -0.276796043), function(X) return math.sin(math.rad(X)) end, 0.5)
		wait(0.3)		
		
		local MagC = objs[1]:WaitForChild("Mag"):clone()
		MagC:FindFirstChild("Mag"):Destroy()
		MagC.Parent = objs[1]
		MagC.Name = "MagC"
		local MagCW = Instance.new("Motor6D")
		MagCW.Part0 = MagC
		MagCW.Part1 = objs[1]:WaitForChild("Left Arm")
		MagCW.Parent = MagC
		MagCW.C1 = MagC.CFrame:toObjectSpace(objs[4].CFrame)
		objs[4].Transparency = 1
		
		objs[6]:WaitForChild("MagOut"):Play()		
		
		TweenJoint(objs[3],  nil , CFrame.new(0.436954767, 0.654289246, -3.00337243, 0.894326091, -0.267454475, 0.358676374, -0.413143814, -0.185948789, 0.891479254, -0.171734676, -0.945458114, -0.276796043), function(X) return math.sin(math.rad(X)) end, 0.3)
		TweenJoint(objs[2],  nil , CFrame.new(-0.630900264, 0.317047596, -1.27966166, 0.985866964, -0.167529628, -7.32295247e-09, 0.0120280236, 0.0707816631, 0.997419298, -0.16709727, -0.983322799, 0.0717963576), function(X) return math.sin(math.rad(X)) end, 0.1)
		wait(0.1)
		TweenJoint(objs[2],  nil , CFrame.new(-1.11434817, 0.317047596, -0.672240019, 0.658346057, -0.747599542, -0.0876094475, 0.0672011375, -0.0575498641, 0.996078312, -0.749709547, -0.661651671, 0.0123518109), function(X) return math.sin(math.rad(X)) end, 0.3)
		wait(0.4)
		objs[6]:WaitForChild('MagSlide'):Play()
		TweenJoint(objs[3],  nil , CFrame.new(-0.273085892, 0.654289246, -1.48434556, 0.613444746, -0.780330896, 0.121527649, -0.413143814, -0.185948789, 0.891479254, -0.673050761, -0.597081661, -0.43645826), function(X) return math.sin(math.rad(X)) end, 0.3)
		wait(0.2)
		
		MagC:Destroy()
		objs[4].Transparency = 0
		wait(0.05)
		TweenJoint(objs[3],  nil , CFrame.new(0.436954767, 0.654289246, -1.82817471, 0.894326091, -0.267454475, 0.358676374, -0.413143814, -0.185948789, 0.891479254, -0.171734676, -0.945458114, -0.276796043), function(X) return math.sin(math.rad(X)) end, 0.5)
		wait(0.05)
		TweenJoint(objs[3],  nil , CFrame.new(0.436954767, 0.654289246, -3.00337243, 0.894326091, -0.267454475, 0.358676374, -0.413143814, -0.185948789, 0.891479254, -0.171734676, -0.945458114, -0.276796043), function(X) return math.sin(math.rad(X)) end, 0.3)
		wait(0.05)
		TweenJoint(objs[3],  nil , CFrame.new(-0.273085892, 0.654289246, -1.48434556, 0.613444746, -0.780330896, 0.121527649, -0.413143814, -0.185948789, 0.891479254, -0.673050761, -0.597081661, -0.43645826), function(X) return math.sin(math.rad(X)) end, 0.3)
		wait(0.04)
		
		
		objs[6]:WaitForChild('MagIn'):Play()
		
		wait(0.3)
		MagC:Destroy()
		objs[4].Transparency = 0
	end;
		
	-- Bolting Back
	BoltingBackAnim = function(char, speed, objs)
			TweenJoint(objs[1],  nil , CFrame.new(0, 0, 0.673770154, 1, 0, 0, 0, 1, 0, 0, 0, 1), function(X) return math.sin(math.rad(X)) end, 0.05)
		end;
		
		BoltingForwardAnim = function(char, speed, objs)
			TweenJoint(objs[1],  nil , CFrame.new(), function(X) return math.sin(math.rad(X)) end, 0.05)
		end;
	
	}

return Settings
