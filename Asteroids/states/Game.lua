require "globals"

local love = require "love"

local Text = require "../components/Text"
local Asteroids = require "../objects/Asteroid"

function Game()
    return {
        level = 1,
        state = {
            menu = true,
            paused = false,
            running = false,
            ended = false
        },
        screenText = {},
        gameOverShowing = false,

        changeGameState = function (self, state)
            self.state.menu = state == "menu"
            self.state.paused = state == "paused"
            self.state.running = state == "running"
            self.state.ended = state == "ended"

            if self.state.ended then
            	self:gameOver()
            end
        end,

         -- Display "GAME OVER"
        gameOver = function(self)
        	self.screenText = {
        		Text(
        			"GAME OVER",
        			0,
        			love.graphics.getHeight() * 0.4,
        			"h1",
        			true,
        			true,
        			love.graphics.getWidth(),
        			"center"
        		)
        	}

        	self.gameOverShowing = true
        end,

        draw = function (self, faded)
        	local opacity = 1

        	if faded then
        	    opacity = 0.5
        	end

        	for index, text in pairs(self.screenText) do
        		if self.gameOverShowing then
                    self.gameOverShowing = text:draw(self.screenText, index)
                    --After "Game Over" switching to the menu
                    if not self.gameOverShowing then
                    	self:changeGameState("menu")
                    end
                else
                	text:draw(self.screenText, index)
        		end
        	end

            if faded then
                Text(
                    "PAUSED",
                    0,
                    love.graphics.getHeight() * 0.4,
                    "h1",
                    false,
                    false,
                    love.graphics.getWidth(),
                    "center",
                    1
                ):draw()
            end
        end,

        startNewGame = function (self, player)
        	if player.lives <=0 then
        	    self:changeGameState("ended")
        	    return
        	else
        		self:changeGameState("running")
        	end

        	local num_asteroids = 0
            asteroids = {}
            self.screenText = {Text(
                "Level " .. self.level,
                0,
                love.graphics.getHeight() * 0.25,
                "h1",
                true,
                true,
                love.graphics.getWidth(),
                "center"
            )}

        
              -- Create asteroids at random positions
            for i = 1, num_asteroids + self.level do
            	local as_x
            	local as_y

            	-- Asteroids are not near the player at the start
            	repeat
                    as_x = math.floor(math.random(love.graphics.getWidth()))
                    as_y = math.floor(math.random(love.graphics.getHeight()))
                until calculateDistance(player.x, player.y, as_x, as_y) > ASTEROID_SIZE * 2 + player.radius

            	table.insert(asteroids, 1, Asteroids(as_x, as_y, ASTEROID_SIZE, self.level, true))
            end
        end
    }
end

return Game