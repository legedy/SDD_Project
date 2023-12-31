--!strict

-- Pathfinder
-- Crazyman32
-- February 7, 2017

-- Updated November 28, 2020
-- > Fixed deprecated API usage
-- > Added types

--[[
	
	This utilizes the nodes created with the Node Map plugin.
	
	
	Pathfinder:Init()
	
		> Must be called before using FindPath

	
	path = Pathfinder:FindPath(startPosition, endPosition)
	
		> If found, returns array of Vector3 positions
		> If not found, returns nil
	
--]]



local Pathfinder = {}

export type Node = {
	Position: Vector3;
	Neighbors: {Node};
	F: number;
	G: number;
	H: number;
	Parent: Node?;
}

export type Path = {Vector3}

local PathNodes: {Node}
local BakedPaths = {};
local AllNodes = {};

function BuildNodes()
	local inGamePathNodes = game:GetService('ReplicatedStorage').nodes

	local NodeFolder = inGamePathNodes:GetChildren();

	local nodes: {Node} = {}
	local dict = {}

	-- Get nodes:
	for _,v in NodeFolder do
		if (v:IsA("Vector3Value")) then
			local node: Node = {
				Position = v.Value;
				Neighbors = {};
				F = 0;
				G = 0;
				H = 0;
				Parent = nil;
			}

			table.insert(AllNodes, v.Value)
			table.insert(nodes, node)
			dict[v] = node
		end
	end
	-- Get node neighbors:
	for _,v in NodeFolder do
		if (v:IsA("Vector3Value")) then
			local node = dict[v]
			for _,k in v:GetChildren() do
				if (k:IsA("ObjectValue")) then
					local neighborNode = dict[k.Value]
					table.insert(node.Neighbors, neighborNode)
					table.insert(neighborNode.Neighbors, node)
				end
			end
		end
	end
	inGamePathNodes:Destroy()
	PathNodes = nodes
end


function Pathfinder:FindNearestNode(position: Vector3)
	local dist, nearestId = math.huge, nil
	for NodeId, Node in ipairs(PathNodes) do
		local d = (position - Node.Position).Magnitude
		if (d < dist) then
			dist, nearestId = d, NodeId;
		end
	end
	return nearestId
end

function Pathfinder:FindBakedPath(startPosition: Vector3 | number, goalPosition: Vector3 | number): Path?
	local startNode = if (typeof(startPosition) == "Vector3") then self:FindNearestNode(startPosition) else PathNodes[startPosition]

	return BakedPaths[startNode][goalPosition]
end

function Pathfinder:FindPath(startPosition: Vector3 | number, goalPosition: Vector3): Path?

	assert(PathNodes, "Pathfinder not yet initialized")

	local path = {}
	local pathFound = false

	local startNode = if (typeof(startPosition) == "Vector3") then self:FindNearestNode(startPosition) else PathNodes[startPosition]
	local goalNode = if (typeof(goalPosition) == "Vector3") then self:FindNearestNode(goalPosition) else PathNodes[goalPosition]

	local open: {[Node]: boolean} = {[startNode] = true}
	local closed: {[Node]: boolean} = {}

	-- Find node with lowest F score within the "open" list:
	local function FindLowestFNode(): Node
		local lowestF, node = math.huge, nil
		for n in pairs(open) do
			if (n.F < lowestF) then
				lowestF, node = n.F, n
			end
		end
		return node
	end

	-- Find path via A* algorithm:
	while (next(open)) do

		-- Find node with lowest F score in open list.
		-- Switch that node from open list to closed list.
		local node = FindLowestFNode()
		open[node] = nil
		closed[node] = true

		-- If the node we just got is the goal node, we found the path!
		if (node == goalNode) then
			pathFound = true
			break
		end

		-- Scan through all neighbors of this node.
		for _,neighbor in ipairs(node.Neighbors) do
			-- If it's not closed, let's examine it.
			if (not closed[neighbor]) then
				-- If it's not in the open list, let's add it to the list and do some calculations on it.
				if (not open[neighbor]) then
					open[neighbor] = true
					neighbor.Parent = node
					neighbor.G = node.G + (neighbor.Position - node.Position).Magnitude
					neighbor.H = (neighbor.Position - goalNode.Position).Magnitude
					neighbor.F = (neighbor.G + neighbor.H)
				else
					-- If it is on the open list and is a good pick for the next path, let's redo some of the calculations
					if (neighbor.G < node.G) then
						neighbor.Parent = node
						neighbor.G = node.G + (neighbor.Position - node.Position).Magnitude
						neighbor.F = (neighbor.G + neighbor.H)
					end
				end
			end
		end

	end

	-- Backtrace path:
	if (pathFound) then
		local node = goalNode
		while (node) do
			table.insert(path, 1, node.Position)
			node = node.Parent
		end
	end

	-- Reset nodes:
	local function ResetNodeDictionary(dict)
		for node in pairs(dict) do
			node.F = 0
			node.G = 0
			node.H = 0
			node.Parent = nil
		end
	end
	ResetNodeDictionary(open)
	ResetNodeDictionary(closed)

	return (pathFound and path or nil)

end

function Pathfinder:Init()
	BuildNodes()

	--> Bake paths for all combinations of nodes:
	for i,v in PathNodes do
		local CurrentPathTo = {};
		BakedPaths[i] = CurrentPathTo;

		for ii, vv in PathNodes do
			local path = self:FindPath(i, ii);

			CurrentPathTo[ii] = path
		end
		
		task.wait()
	end

	return AllNodes, BakedPaths;
end


return Pathfinder