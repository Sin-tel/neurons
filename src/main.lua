require("agent")
require("qaudio")

io.stdout:setvbuf("no")



width = 1280
height = 720

love.window.setMode( width, height, {vsync = false} )
--love.window.setMode(width, height, { vsync = true, fullscreen = false, fullscreentype = "desktop", borderless = false, resizable = true } ) 

stop = false

time = 0
timer = 0

temp = 0

id = 1

prev = nil

edgeCount = 0


slomo = false

tweight = 1
decay_ = 1.0
tweight_ = 1.0

hpl = 0
hpr = 0

function clip(x)
	if(x <= -1) then
		return -2/3
	elseif(x >= 1) then
		return 2/3
	else
		return x-(x^3)/3
	end
end

function dsp(time)
	if stop and selected then
		decay = decay - (decay - decay_) * 0.002
		tweight = tweight - (tweight - tweight_) * 0.002

		for k,v in pairs(edges) do
			v[2].input = v[2].input + v[1].state*v[3]* tweight

			--[[if math.random() < 0.01 then
				v[3] = v[3] + love.math.randomNormal(0.02)
			end]]
		end

		local l = 0
		local r = 0

		for i,v in ipairs(agents) do
			v:audio()
			if i%2 == 0 then
				l = l + v.state
			else
				r = r + v.state
			end
		end
		l = 5*l / N
		r = 5*r / N

		hpr = hpr - (hpr - r)*0.01
		hpl = hpl - (hpl - l)*0.01

		l = l - hpl
		r = r - hpr


		

		return clip(l)*1.5, clip(r)*1.5
	else
		return 0,0
	end
end

function love.load()
	math.randomseed(os.time())
	local font = love.graphics.newFont( 17 )
	love.graphics.setFont(font)

	love.graphics.setLineWidth(1.2)
	love.graphics.setLineStyle("smooth")


	edges = {}

    agents = {}
	
	N = 70

	maxEdges = N*(N-1)*0.5

	local p = 7/N--7/N
	numEdges = p*maxEdges

	print(maxEdges, numEdges)

	gamma = 3.0--3.2
	alpha = 1 / (gamma - 1)
	
	for i = 1,N do
		agents[i] = Agent:new()
		--[[if i >= 2 then
			addEdge(agents[i],agents[i-1])
		end]]
	end

	Qaudio.load()
	Qaudio.setCallback(dsp)
end

function love.update(dt)
	time = time + dt
	timer = timer + dt

	dt = 1/500
	
	mouseX,mouseY = love.mouse.getPosition()
	

	temp = mouseX/width

	if stop then
		for i,v in ipairs(agents) do
			v:update(dt)
		end
	end

	-- for k,v in pairs(edges) do
			
	-- 	v[3] = v[3] + love.math.randomNormal(0.1)
	-- end

	if not stop then
		--[[local s = false
		while not s do
			s = addEdgePower()
		end]]

		--addEdgeRandom()

		local a = agents[math.random(#agents)]
		local b = agents[math.random(#agents)]
		for i = 1,7 do
			local c = agents[math.random(#agents)]
			local d1 = (a.x-b.x)^2 + (a.y-b.y)^2
			local d2 = (a.x-c.x)^2 + (a.y-c.y)^2
			if d2 < d1  then
				b = c
			end
		end

		if(a ~= b) then
			addEdge(a,b)
		end
	else
		for i = #agents,1,-1 do
			if(#agents[i].group == 0) then
				table.remove(agents,i)
			end
		end
	end
	

	if edgeCount >= numEdges and not stop then
		stop = true
		for i = #agents,1,-1 do
			if(#agents[i].group == 0) then
				table.remove(agents,i)
			end
		end
		selected = agents[math.random(#agents)]

		setRandomWeights()
	end

	if not slomo then
		Qaudio.update()
	else
		dsp()
	end

	decay_ = (mouseX / width)
	tweight_ = (mouseY / height)
	--print(decay)

	if(love.mouse.isDown(1) and selected) then
		selected.input = selected.input + math.random()*40-20
		selected.x = mouseX
		selected.y = mouseY
		print(selected.state, selected.smooth)
	end

	if(love.mouse.isDown(2)) then
		for i,v in ipairs(agents) do
			local l = math.sqrt((v.x-mouseX)^2 + (v.y-mouseY)^2)
			if l < 50 then
				v.fx = 5*(50-l)*(v.x-mouseX)/l
				v.fy = 5*(50-l)*(v.y-mouseY)/l
			end
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.14,0.14,0.14)
	--love.graphics.clear()
	love.graphics.setColor(0.0,1.0,0.0)
	

	love.graphics.setColor(1.0,1.0,1.0,0.8)

	for k,v in pairs(edges) do
		--print(k)
		local act = math.abs(v[1].state)*2+0.03
		local c = -v[3]*0.05
		local dx = v[2].x - v[1].x
		local dy = v[2].y - v[1].y
		local a = math.atan2(dy, dx)

		ox = 2*math.sin(a)
		oy = -2*math.cos(a)
		love.graphics.setColor(0.8+c,0.8-c,0.8 -c,0.33*act)
		love.graphics.line(v[1].x+ox, v[1].y+oy, v[2].x+ox, v[2].y+oy )
		love.graphics.circle("line", v[1].x+ox + dx*0.8, v[1].y+oy + dy*0.8, 3)
	end

	for i,v in ipairs(agents) do
		v:draw()
		if v == selected then
			love.graphics.setColor(0.8,0.8,0.8)
			love.graphics.circle("line", v.x, v.y, v.r+5)
		end
	end
	for i,v in ipairs(agents) do
		v:draw2()
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print( love.timer.getFPS())
end

function love.keypressed( key, isrepeat )
	if key == 'escape' then
		love.event.quit()
	elseif key == 'space' then
		slomo = not slomo
	elseif key == 'v' then
		for i,v in ipairs(agents) do
			v.decay = randomFreq()
			v.decay2 = randomFreq()
		end
	elseif key == 'b' then
		for k,v in pairs(edges) do
			
			v[3] = v[3] + love.math.randomNormal(0.1)
		end
	elseif key == 'n' then
		setRandomWeights()
	elseif key == 'm' then
		
		--agents = {}
		edges = {}
		id=1
		--[[for i = 1,N do
			agents[i] = Agent:new()
		end]]
		for i,v in ipairs(agents) do
			v.group = {}
		end
		edgeCount = 0
		stop = false
	elseif key == 'r' then
		
		for i,v in ipairs(agents) do
			if math.random() < 0.1 then
				v.smooth = math.random()-0.5
			end
			--v.input = v.input + math.random()*40-20

		end

	end
end

function setRandomWeights()
	for k,v in pairs(edges) do
		local w = love.math.randomNormal(3, -3)

		v[3] = w
	end
	for i,v in ipairs(agents) do
		v.decay = randomFreq()
		v.decay2 = randomFreq()
	end
end

function randomFreq()
	return 0.5*math.random()^5
end

function love.mousepressed(x, y, button, istouch)
	
	d = 1000
	for i,v in ipairs(agents) do
		local dist = math.sqrt((mouseX - v.x)^2 + (mouseY - v.y)^2)
		if dist < d then
			selected = v
			d = dist
		end
	end
end

function addEdgeRandom(x,y)
	local a = agents[math.random(#agents)]
	local b = agents[math.random(#agents)]

	if(a ~= b) then
		addEdge(a,b)
	end
	return true
end

function addEdgePower(x,y)
	local a = agents[math.random(#agents)]
	local b = agents[math.random(#agents)]

	local p = a.theta * b.theta
	

	if(a ~= b) then
		if math.random() < p then
			addEdge(a,b)
			return true
		end
	end
	return false
end

function addEdge(a,b)
	local i1 = a.id
	local i2 = b.id


	local i  = i1 .. "," .. i2
	if not edges[i] then
		local w = 0
		edges[i] = {a,b, w}

		table.insert(a.group, b)
		table.insert(b.group, a)

		edgeCount = edgeCount + 1
	end
end

function removeEdge(a)
	local gr = a.group
	local nb = gr[math.random(#gr)]
	if(nb) then

		for j,b in ipairs(nb.group) do
			if(b == a) then
				table.remove(nb.group, j)
				break
			end
		end
		for j,b in ipairs(a.group) do
			if(b == nb) then
				table.remove(a.group, j)
				break
			end
		end


		local i1 = a.id
		local i2 = nb.id

		edges[i1 .. "," .. i2] = nil

		edgeCount = edgeCount -1

	end
end

function getNeighbor(a,n,visited)
	--print(n)
	local vs = visited or {}
	vs[a.id] = true
	for i,v in ipairs(a.group) do
		if not vs[v] then
			if (n <= 1) then
				return v
			else
				return getNeighbor(v,n-1,vs)
			end
		end
	end
end
