local mob = script.Parent
local humanoid = mob.Humanoid

local walkAnim = script.Animation
local walkAnimTrack = humanoid.Animator:LoadAnimation(walkAnim)

humanoid.Running:Connect(function(speed)
	if speed > 0 then
		if not walkAnimTrack.IsPlaying then
			walkAnimTrack:Play()
		end
	else
		if walkAnimTrack.IsPlaying then
			walkAnimTrack:Stop()
		end
	end
end)

script.Parent.HumanoidRootPart:SetNetworkOwner(game.Players.PlayerAdded:Wait())