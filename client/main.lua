class = require("class")
require("LUBE")
local gui = require("Quickie")
local tserial = require("TSerial")
local camera = require("camera")

function onReceive(data)
    world = TSerial.unpack(data)
    loaded = true
end
--Menu stuff

local inputserver    = {text = "localhost"}
local inputusername    = {text = ""}
local menu = true

local buildmenu = false
local builditem = {text = ""}

function love.load()
    test = ""
    world = {}
    t = 0
    update = {command = "update"}
    updaterate = 1/30
    
    xres = 800
    yres = 600
    
    cam = camera(400,300)
        
    Background:init(100)
        --IMAGES
    images = {}
    images.ast10 = love.graphics.newImage("asteroid10.png") 
    images.ast15 = love.graphics.newImage("asteroid15.png")
    images.ast20 = love.graphics.newImage("asteroid20.png")
    images.ssv = love.graphics.newImage("station.png")
    images.ship = love.graphics.newImage("ship.png")
    images.bullet = love.graphics.newImage("star.png")
    starimage = love.graphics.newImage("star.png")
    pship = love.graphics.newQuad( 265, 921, 26, 23, 512, 1024 )    
--    shipimage = love.graphics.newImage("SHIPS.png")
    
    thrustimage = love.graphics.newImage("thrust.png")
end
function connecttoserver(server, username)
    port = 12345
    client = lube.udpClient()
    client.handshake = "shipgame"
    client.callbacks.recv = onReceive
    client:connect(server, port)
    connected = true
    update = {username = inputusername.text, command = "update", thrust = 0, turn = 0, shoot = 0}
    client:send(TSerial.pack({command="login", username=username}))
end

function love.update(dt)
    if connected then
        local username = inputusername.text
        client:update(dt)
        if loaded then
            cam.x = world[username].x or 400
            cam.y = world[username].y or 300
        end
        t = t + dt
        
        if love.keyboard.isDown("right") then
            update.turn = update.turn + dt
        end
        if love.keyboard.isDown("left") then
            update.turn = update.turn - dt
        end        
        if love.keyboard.isDown("up") then
            update.thrust = update.thrust + dt
        end
        if love.keyboard.isDown(" ") then
            update.shoot = update.shoot + dt
        end
        if t > updaterate then
            t = t - updaterate
            client:send(TSerial.pack(update))
            update = {username = inputusername.text, command = "update", thrust = 0, turn = 0, shoot = 0, build = "nothing"}
        end
            
    end
    if menu then
        gui.group.push{grow = "down", pos = {200, 80}}
        gui.group.push{grow = "right"}
		gui.Label{text = "Server:", size = {70}}
		gui.Input{info = inputserver, size = {300}}
		gui.group.pop{}
		gui.group.push{grow = "right"}
		gui.Label{text = "Username:", size = {70}}
		gui.Input{info = inputusername, size = {300}}
		gui.group.pop{}
		if gui.Button{text = "Connect"} then
		    menu = false
		    connecttoserver(inputserver.text, inputusername.text)
		end
	end
	if buildmenu then
	    
		gui.group.push{grow = "down", pos = {200, 80}}
		gui.group.push{grow = "right"}
		--gui.Label{text = "Build:", size = {70}}
		gui.Input{info = builditem, size = {300}}
		if gui.Button{text = "Build"} then
		    buildmenu = false
		    update.build = builditem.text
		    builditem.text = ""
		end
	end
  
end

function love.keypressed(key, code)
    if connected then
--        client:send(key)
		if key == "b" then
			buildmenu = true
		end
    end
    gui.keyboard.pressed(key, code)
end

function love.draw()
	gui.core.draw()
--	love.graphics.print(test, 0, 300)
    if connected then
        Background:draw()
        if loaded then
            hud()
        end
        cam:draw(drawobjects)
    end
end

function round(num)
    return math.floor(num +0.5)
end

function calcspeed(x, y)
    local speed = math.sqrt(x^2 + y^2)
    local angle = math.atan2(y,x)
    return speed, angle    
end
function hud()
    local username = inputusername.text
    local x, y = world[username].x, world[username].y 
--    local speed, angle = calcspeed(objects.ship.body:getLinearVelocity())
--    love.graphics.print("Coordinates:\nX: ".. round(x) .."\nY: ".. round(y) .. "\nSpeed: " .. round(speed) .. "\nFuel: ".. round(objects.ship.fuel), 10, 10)
    love.graphics.print("Coordinates:\nX: ".. round(x) .."\nY: ".. round(y), 10, 10)
--    love.graphics.circle("line", 780, 20, 10)
--    local sx = 780 + 10 * math.cos(angle)
--    local sy = 20 + 10 * math.sin(angle)
--    love.graphics.line(780, 20, sx, sy)
end

function drawobjects()
    for i, v in pairs(world) do
--        local p = v.angle
--        local tx = v.x + (18 * math.cos(p+math.rad(180)))
--        local ty = v.y + (18 * math.sin(p+math.rad(180)))
--        if v.img == "ship" then
--            love.graphics.drawq(shipimage, pship, v.x, v.y, v.angle, 1, 1, 26 / 2, 23 / 2)
--        else
            --love.graphics.draw(images[v.img], v.x - v.size / 2, v.y - v.size / 2, v.angle)
        if v.size ~= -1 then 
            love.graphics.draw(images[v.img], v.x, v.y, v.angle, 1, 1, v.size /2, v.size/2)
        else
            love.graphics.draw(images[v.img], v.x, v.y, v.angle, 1, 1, v.height /2, v.width /2)
        end
            --love.graphics.draw(images[v.img], v.x, v.y, v.angle)
--        end
--        if isthrusting then love.graphics.draw(tp, tx, ty) end
    end
end

Background = {}

function Background:init(numstars)
   self.numstars = numstars
   self.parallax = {}
   -- create stars
   for i = 1, numstars do
      local x, y = math.random(0, xres*1.2), math.random(0, yres*1.2)
      local depth = math.random(50, 90)/100
      local size = math.random(3,6)/10
      table.insert(self.parallax, {x, y, depth=depth, size=size})
   end
   
end

function Background:draw()
   -- local variables = faster!
   local starimage = starimage
   local campos = {x=cam.x, y=cam.y}
   local xres, yres = xres, yres
   local xarea, yarea = xres*1.2, yres*1.2
   
   for i, star in ipairs(self.parallax) do
      -- calculate new positions
      local x = (star[1]-campos.x*star.depth) % xarea
      local y = (star[2]-campos.y*star.depth) % yarea
      if x >= 0 and x <= xres and y >= 0 and y <= yres then
         -- only draw if actually onscreen
         love.graphics.draw(starimage, x, y, 0, star.size, star.size, 4, 4)
      end
   end
end
