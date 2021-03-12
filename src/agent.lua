Agent = {}

decay = 0.9

function Agent:new(x,y)
	local new = {}
	setmetatable(new,self)
	self.__index = self

	new.x = math.random()*width
	new.y = math.random()*height

	new.xp = new.x
	new.yp = new.y

	new.r = 6
	new.d = 6

	new.theta = math.pow(id,-alpha)

	new.fx = 0
	new.fy = 0

	new.c = 0

	new.state = 0
	new.input = 0.5
	new.smooth = 0.5

	new.decay = 0.1

	new.group = group or {}

	new.id = id
	id = id+1
	
	return new
end



function Agent:audio()
	local d = self.decay*decay + self.decay2*(1.0-decay)
	local s = math.min(d,1.0)

	--local b = 10
	--local rand = math.exp(-b)*math.tan(math.pi*(math.random()-.5))
	local rand = math.random()*0.02
	--[[local rand = -math.log(math.random())*0.1
	local r = math.random()
	if r < 0.01 then
		rand = -rand
	end
	if r > 0.02 then
		rand = 0
	end]]
	local inp = self.input + rand

	self.smooth = self.smooth - (self.smooth - inp)*s
	self.input = 0
	local a = self.smooth

	-- soft threshold
	a = a - 0.2*math.tanh(5*a)

	--[[if a < -THRESHOLD then
		a = a + THRESHOLD
	elseif a > THRESHOLD then
		a = a - THRESHOLD
	else
		a = 0
	end]]

	

	--self.state = 1.0 / (1.0 + math.exp(-a)) - 0.5
	self.state = math.tanh(a)

	--self.state = math.sin(0.04*a + 0.1)

	--a = a/4.5
	--self.state = a/(1.0+a*a) + 0.5

	--self.state = math.min(1,math.max(0,a))

	--self.state = a/(1+math.abs(a))
end

function Agent:update(dt)

	self.c = #self.group
	
	self.d = 3.0*self.r

	local xp = self.x
	local yp = self.y

	local fx = self.fx+love.math.randomNormal(2, 0)
	local fy = self.fy+love.math.randomNormal(2, 0)

	self.fx = 0
	self.fy = 0

	for i,v in ipairs(self.group) do
		
			local lx = v.x - self.x
			local ly = v.y - self.y
			local l = math.sqrt(lx*lx + ly*ly)

			local d = 2*math.min(self.d,v.d)

			local l2 = l-d
			fx = fx + .3*l2*lx/l
			fy = fy + .3*l2*ly/l
		
	end
	for i,v in ipairs(agents) do
		--if(math.abs(self.id - v.id) > 3) then
		if(v ~= self) then
			local lx = v.x - self.x
			local ly = v.y - self.y
			local l = math.sqrt(lx*lx+ly*ly)
			l = math.max(1,l)
			if(l < 200) then
				fx = fx - 30000*lx/(l*l*l)
				fy = fy - 30000*ly/(l*l*l)
				--fx = fx - 200*lx/(l*l)
				--fy = fy - 200*ly/(l*l)
			end
		end
	end

	local f = 0.06
	self.x = (2.0-f)*self.x - (1.0-f)*self.xp + fx*1000*dt*dt
	self.y = (2.0-f)*self.y - (1.0-f)*self.yp + fy*1000*dt*dt


	self.x = math.min(width,self.x)
	self.x = math.max(0,self.x)

	self.y = math.min(height,self.y)
	self.y = math.max(0,self.y)


	local xs = self.x - xp
	local ys = self.y - yp


	self.xp = xp
	self.yp = yp
end 

function Agent:draw()

	local c = math.abs(self.state)


	love.graphics.setColor(0.0, 1.0*c, 0.8*c )

	love.graphics.circle("fill", self.x, self.y, self.r)
	love.graphics.setColor(1,1,1)
	love.graphics.circle("line", self.x, self.y, self.r)
end


function Agent:draw2()

	local c = math.abs(self.state)


	love.graphics.setColor(0.0, 1.0, 0.8, 0.005*c*c)

	
	love.graphics.circle("fill", self.x, self.y, self.r*3)
	love.graphics.circle("fill", self.x, self.y, self.r*5)
end