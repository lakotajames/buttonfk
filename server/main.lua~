Class = require "class"
require "LUBE"
local tserial = require("TSerial")




function onConnect(ip, port)
  test = "Connection from " .. ip
end
function onReceive(data, ip, port)
    testdata = data
    local update = TSerial.unpack(data)
    local username = update.username
    if update.command == "login" then
        local username = update.username
        if not objects[username] then
            createuser(username)
        end
        
    end
    if update.command == "update" then
        local user = objects[username]
        user.body:setAngle(user.body:getAngle()+ update.turn*5)
        user.body:applyForce(update.thrust * 1000 * math.cos(user.body:getAngle()), update.thrust * 1000 * math.sin(user.body:getAngle()))
        if update.shoot > 0 then shoot(user, update.shoot) end    
        if update.build == "station" then 
            createstation(user)
        end
              
    end
end
function onDisconnect(ip, port)
  
end

function createuser(username)
    objects[username] = {}
    local user = objects[username]
    user.name = username
    user.body = love.physics.newBody(world, 400, 300, "dynamic")
    user.body:setMass(2500)
    user.body:setAngularDamping(2)
    user.size = -1
    user.width = 18
    user.height = 29
    user.shape = love.physics.newRectangleShape(user.width, user.height)
    user.fixture = love.physics.newFixture(user.body, user.shape)
    user.fuel = 1000
    user.img = "ship"
    user.bullets = 0
    user.firerate = 1
    user.firecooldown = 0
end

function shoot(user, update)
    if user.firecooldown < 0 then
        user.firecooldown = user.firecooldown + user.firerate
        user.bullets = user.bullets + 1
        if user.bullets == 11 then user.bullets = 1 end
        local bulletSpeed = 0.1
        local angle = user.body:getAngle()
        local startX = user.body:getX() + (user.width/2) * math.cos(angle)
        local startY = user.body:getY() + (user.height/2) * math.sin(angle)
    
        local bulletDx = bulletSpeed * math.cos(angle)
        local bulletDy = bulletSpeed * math.sin(angle)
        bulletname = user.name .. "_b_" .. user.bullets
        objects[bulletname] = {}
        local bullet = objects[bulletname]
        
        bullet.name = bullet
        bullet.body = love.physics.newBody(world, startX, startY, "dynamic")
        bullet.body:setMass(100000)
        bullet.size = 1
        bullet.shape = love.physics.newCircleShape(bullet.size/2)
        bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape)
        bullet.img = "bullet"
    
        bullet.body:applyLinearImpulse( bulletDx, bulletDy)
    else
        user.firecooldown = user.firecooldown - update    
    end
    
end

function love.load()

--game stuff
    love.physics.setMeter(50)
    world = love.physics.newWorld(0, 0, true)
    objects = {}
    astinit(10)
    bulletint = 0
    
--server stuff  
    t = 0
    updaterate = 1/30
    test = "test"
    testdata = "test"
    server = lube.udpServer()
    server.callbacks.recv = onReceive
    server.callbacks.connect = onConnect
    server.callbacks.disconnect = onDisconnect
    server.handshake = "shipgame"
    server:listen(12345)
end
function love.update(dt)
    server:update(dt)
    world:update(dt)
    t = t + dt
    if t > updaterate then
        t = t - updaterate 
        server:send(packagedata())
    end
end

function love.draw()
    love.graphics.print(test, 0, 0)
    love.graphics.print(testdata, 0, 20)
end

function packagedata()
    local package = {}
    for i, v in pairs(objects) do
        package[i] = {x = v.body:getX(), y = v.body:getY(), angle = v.body:getAngle(), img = v.img, size = v.size, width = v.width or 0, height = v.height or 0}
    end
    return TSerial.pack(package)
end
        
function astinitold(numasts)
   local numasts = numasts
   local xres,yres = 800,600
   -- create stars
   for i = 1, numasts do
      local x, y = math.random(0, xres), math.random(0, yres)
      local size = math.random(1,3) * 5 + 5
      local ast = "ast" .. i 
      objects[ast] = {}
      objects[ast].size = size
      objects[ast].body = love.physics.newBody(world, x, y, "dynamic")
      objects[ast].body:setMass(size)
      objects[ast].shape = love.physics.newCircleShape(size / 2)
      objects[ast].fixture = love.physics.newFixture(objects[ast].body, objects[ast].shape)
      objects[ast].img = "ast" .. size
   end
   
end

function astinit(numasts, xrange, yrange, xloc, yloc)
    
    local numasts = numasts
    local xres = xrange or 800
    local yres = yrange or 600
    local xloc = xloc or 0
    local yloc = yloc or 0
   -- create asteroids
    for i = 1, numasts do
        local x, y = math.random(xloc, xres), math.random(yloc, yres)
        local size = math.random(1,3) * 5 + 5
        local ast = "ast" .. i 
        objects[ast] = {}
        objects[ast].size = size
        objects[ast].body = love.physics.newBody(world, x, y, "dynamic")
        objects[ast].body:setMass(size)
        objects[ast].shape = love.physics.newCircleShape(size / 2)
        objects[ast].fixture = love.physics.newFixture(objects[ast].body, objects[ast].shape)
        objects[ast].img = "ast" .. size
    end
   
end

function createstation(user)
    local x = user.body:getX()
    local y = user.body:getY()
    objects.station = {}
    objects.station.size = 300 --???
    objects.station.body = love.physics.newBody(world, x, y, "dynamic")
    objects.station.body:setMass(2500)
    objects.station.shape = love.physics.newCircleShape(150)
    objects.station.fixture = love.physics.newFixture(objects.station.body, objects.station.shape)
    objects.station.img = "ssv"
    
end


