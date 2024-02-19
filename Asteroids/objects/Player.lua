require "globals"

local love = require "love"

local Lazer = require "objects/Lazer"

function Player(numLives)
    local SHIP_SIZE = 30
    local EXPLOAD_DUR = 3
    local VIEW_ANGLE = math.rad(90)
    local LAZER_DISTANCE = 0.75
    local MAX_LAZERS = 10
    local USABLE_BLINKS = 5 * 2

    return {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        radius = SHIP_SIZE / 2,
        angle = VIEW_ANGLE,
        rotation = 0,
        exploadTime = 0,
        exploading = false,
        thrusting = false,
        invincible = true,
        invincibleSeen = true,
        timeBlinked = USABLE_BLINKS,
        lazers = {},
        thrust = {
            x = 0,
            y = 0,
            speed = 5,
            bigFlame = false,
            flame = 2.0
        },
        lives = numLives or 3,

        drawFlameThrust = function (self, fillType, color)
        	if self.invincibleSeen then
        	    table.insert(color, 0.25)
        	end

            love.graphics.setColor(color)

            --Calculating polygon (to draw it)
            love.graphics.polygon(
                fillType,
                self.x - self.radius * (2 / 3 * math.cos(self.angle) + 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) - 0.5 * math.cos(self.angle)),
                self.x - self.radius * self.thrust.flame * math.cos(self.angle),
                self.y + self.radius * self.thrust.flame * math.sin(self.angle),
                self.x - self.radius * (2 / 3 * math.cos(self.angle) - 0.5 * math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) + 0.5 * math.cos(self.angle))
            )
        end,

        shootLazer = function (self)
            if (#self.lazers <= MAX_LAZERS) then
                -- lazer spawn from front of ship
                table.insert(self.lazers, Lazer(
                    self.x + ((4 / 3) * self.radius) * math.cos(self.angle),
                    self.y -  ((4 / 3) * self.radius) * math.sin(self.angle),
                    self.angle
                ))
            end
        end,

        destroyLazer = function (self, index)
            table.remove(self.lazers, index)
        end,

        draw = function (self, faded)
            local opacity = 1
            
            if faded then
                opacity = 0.2
            end

            love.graphics.setColor(1, 1, 1, opacity)

            love.graphics.polygon(
                "fill",
                self.x + ((4 / 3) * self.radius) * math.cos(self.angle),
                self.y -  ((4 / 3) * self.radius) * math.sin(self.angle),
                self.x - self.radius * (2 / 3 * math.cos(self.angle) + math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) - math.cos(self.angle)),
                self.x - self.radius * (2 / 3 * math.cos(self.angle) - math.sin(self.angle)),
                self.y + self.radius * (2 / 3 * math.sin(self.angle) + math.cos(self.angle))
            )

            --Making sure that player thrust wont be drawn
            if not self.exploading then
                if self.thrusting then
                    if not self.thrust.bigFlame then
                        self.thrust.flame = self.thrust.flame - 1 / love.timer.getFPS()
    
                        if self.thrust.flame < 1.5 then
                            self.thrust.bigFlame = true
                        end
                    else
                        self.thrust.flame = self.thrust.flame + 1 / love.timer.getFPS()
    
                        if self.thrust.flame > 2.5 then
                            self.thrust.bigFlame = false
                        end
                    end

                    self:drawFlameThrust("fill", {255/255 ,102/255 ,25/255})
                    self:drawFlameThrust("line", {1, 0.16, 0}) 
                end

                if showDebugging then
                    love.graphics.setColor(1, 0, 0)
    
                    love.graphics.rectangle( "fill", self.x - 1, self.y - 1, 2, 2 )
                    
                    love.graphics.circle("line", self.x, self.y, self.radius)
                end

                --How player when invincible looks
                if self.invincibleSeen then
                    love.graphics.setColor(1, 0, 0, faded and opacity or 0.25)
                else
                	love.graphics.setColor(0, 0, 1, opacity)
                end
                --How player when invincible looks


                -- Drawing a ship(triangle)
                love.graphics.polygon(
                    "line", -- ship
                    -- the 4 / 3 and 2 / 3 is to find the center of the triangle correctly
                    self.x + ((4 / 3) * self.radius) * math.cos(self.angle),
                    self.y -  ((4 / 3) * self.radius) * math.sin(self.angle),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) + math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) - math.cos(self.angle)),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) - math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) + math.cos(self.angle))
                )
                -- Drawing a ship(triangle)


                -- draw lazers
                for _, lazer in pairs(self.lazers) do
                    lazer:draw(faded)
                end

            else -- draw explosion of the ship
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 1.5)

                love.graphics.setColor(1, 158/255, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 1)

                love.graphics.setColor(1, 234/255, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * 0.5)
            end
        end,

        drawLives = function(self, faded)
        	local opacity = 1
            
            if faded then
                opacity = 0.2
            end
            --yellow
            if self.lives == 2 then
            	love.graphics.setColor(1, 1, 0.5, opacity)
            --red
            elseif self.lives == 1 then
            	love.graphics.setColor(1, 0.2, 0.2, opacity)
            else
            	love.graphics.setColor(1, 1, 1, opacity)
            end	

            local x_pos, y_pos = 45, 30

            --Drawing Hearts
            for i = 1, self.lives do
	        local x_offset = (i * x_pos)
	        local heartSize = 20

	        if self.exploading and i == self.lives then
	            love.graphics.setColor(1, 0, 0, opacity)
	        end

	        -- Coordinates for drawing a heart shape
	        local heartX = x_offset + heartSize * math.sin(math.pi / 4) * math.sin(math.pi / 4)
	        local heartY = y_pos - heartSize * math.sin(math.pi / 4) * math.cos(math.pi / 4)

	        love.graphics.polygon(
	            "fill",
	            heartX,
	            heartY,
	            heartX + heartSize * math.cos(math.pi / 4) * math.sin(math.pi / 4),
	            heartY - heartSize * math.cos(math.pi / 4) * math.cos(math.pi / 4),
	            heartX + 2 * heartSize * math.cos(math.pi / 4) * math.sin(math.pi / 4),
	            heartY,
	            heartX,
	            heartY + 2 * heartSize * math.sin(math.pi / 4) * math.sin(math.pi / 4),
	            heartX - 2 * heartSize * math.cos(math.pi / 4) * math.sin(math.pi / 4),
	            heartY,
	            heartX - heartSize * math.cos(math.pi / 4) * math.sin(math.pi / 4),
	            heartY - heartSize * math.cos(math.pi / 4) * math.cos(math.pi / 4)
	        )
	        -- Coordinates for drawing a heart shape
	    end
        end,

        movePlayer = function (self, dt)
        	--Handling player invincibility
        	if self.invincible then
        	    self.timeBlinked = self.timeBlinked - dt * 2

        	    if math.ceil(self.timeBlinked) % 2 == 0 then
                    self.invincibleSeen = false
        		else
        			self.invincibleSeen = true
        		end

        		if self.timeBlinked <= 0 then
        		    self.invincible = false
        		end
        	else
        		self.timeBlinked = USABLE_BLINKS
        		self.invincibleSeen = false
        	end

            self.exploading = self.exploadTime > 0

            -- Handle ship movement and rotation
            if not self.exploading then
                local FPS = love.timer.getFPS()
                local friction = 0.7

                self.rotation = 360 / 180 * math.pi / FPS

                if love.keyboard.isDown("a") or love.keyboard.isDown("left") or love.keyboard.isDown("kp4") then
                    self.angle = self.angle + self.rotation
                end
                
                if love.keyboard.isDown("d") or love.keyboard.isDown("right") or love.keyboard.isDown("kp6") then
                    self.angle = self.angle - self.rotation
                end

                if self.thrusting then
                    self.thrust.x = self.thrust.x + self.thrust.speed * math.cos(self.angle) / FPS
                    self.thrust.y = self.thrust.y - self.thrust.speed * math.sin(self.angle) / FPS
                else
                    if self.thrust.x ~= 0 or self.thrust.y ~= 0 then
                        self.thrust.x = self.thrust.x - friction * self.thrust.x / FPS
                        self.thrust.y = self.thrust.y - friction * self.thrust.y / FPS
                    end
                end

                --Wrapping
                self.x = self.x + self.thrust.x
                self.y = self.y + self.thrust.y

                if self.x + self.radius < 0 then
                    self.x = love.graphics.getWidth() + self.radius
                elseif self.x - self.radius > love.graphics.getWidth() then
                    self.x = -self.radius
                end

                if self.y + self.radius < 0 then
                    self.y = love.graphics.getHeight() + self.radius
                elseif self.y - self.radius > love.graphics.getHeight() then
                    self.y = -self.radius
                end
                --Wrapping
            end

            -- Update lazer positions and check for distance limit
            for index, lazer in pairs(self.lazers) do
                if (lazer.distance > LAZER_DISTANCE * love.graphics.getWidth()) and (lazer.exploading == 0) then
                    lazer:expload()
                end
                
                if lazer.exploading == 0 then
                    lazer:move()
                elseif lazer.exploading == 2 then
                    self.destroyLazer(self, index)
                end
            end
        end,
		-- to explode the ship
        expload = function (self)
            self.exploadTime = math.ceil(EXPLOAD_DUR * love.timer.getFPS())
        end
    }
end

return Player