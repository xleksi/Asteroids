require "globals"

local love = require "love" -- Importing the Love2D framework (not required but looks cute)

--Importing things from the other classes
local Player = require "objects/Player"
local Game = require "states/Game"
local Menu = require "states/Menu"

--Seed for random asteroid generation (cos random can be not very random sometimes in lua)
math.randomseed(os.time())

function love.load()
    love.mouse.setVisible(false)
    mouse_x, mouse_y = 0, 0
    
    --Creating instances
    player = Player()
    game = Game()
    menu = Menu(game, player)
end

-- KEYBINDINGS --
function love.keypressed(key)
    if game.state.running then
        if key == "w" or key == "up" or key == "kp8" then
            player.thrusting = true
        end

        if key == "space" or key == "down" or key == "kp5" then
            player:shootLazer()
        end

        if key == "escape" then
            game:changeGameState("paused")
        end
    elseif game.state.paused then
        if key == "escape" then
            game:changeGameState("running")
        end
    end
end

function love.keyreleased(key)
    if key == "w" or key == "up" or key == "kp8" then
        player.thrusting = false
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if game.state.running then
            player:shootLazer()
        else
        	clickedMouse = true
        end
    end
end
-- KEYBINDINGS --

function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition() --updating mouse pos

    -- Update game elements based on game state
    if game.state.running then
        player:movePlayer(dt)

        for ast_index, asteroid in pairs(asteroids) do
            if not player.exploading and not player.invincible then
            	--Collision detection between player and asteroids
                if calculateDistance(player.x, player.y, asteroid.x, asteroid.y) < player.radius + asteroid.radius then
                    player:expload()
                    destroy_ast = true
                end
            else
                player.exploadTime = player.exploadTime - 1

                if player.exploadTime == 0 then
                    if player.lives -1 <= 0 then
                        game:changeGameState("ended")
                        return
                    end

                    player = Player(player.lives - 1)
                end
            end
            	-- Collision detection between lasers and asteroids
            for _, lazer in pairs(player.lazers) do
                if calculateDistance(lazer.x, lazer.y, asteroid.x, asteroid.y) < asteroid.radius then
                    lazer:expload() -- delete lazer
                    asteroid:destroy(asteroids, ast_index, game)
                end
            end

            if destroy_ast then
            	if player.lives - 1 <= 0 then
            	    if player.exploadTime == 0 then
            	        destroy_ast = false
                		asteroid:destroy(asteroids, ast_index, game) -- delete asteroid and split into more asteroids
            	    end
            	else
            		destroy_ast = false
                	asteroid:destroy(asteroids, ast_index, game)
            	end
            end

            asteroid:move(dt)
        end

        if #asteroids == 0 then
            game.level = game.level + 1
            game:startNewGame(player)
        end

    elseif game.state.menu then
    	menu:run(clickedMouse)

        clickedMouse = false
    end
end

function love.draw()
    if game.state.running or game.state.paused then
        player:drawLives(game.state.paused) -- draw player lives to screen
        player:draw(game.state.paused)
        -- drawing asteroids
        for _, asteroid in pairs(asteroids) do
            asteroid:draw(game.state.paused)
        end

        game:draw(game.state.paused)
    elseif game.state.menu then
        menu:draw()
	elseif game.state.ended then
	    game:draw()
    end


    love.graphics.setColor(1, 1, 1, 1)
    
    if not game.state.running then -- draw cursor if not in running state
        love.graphics.circle("fill", mouse_x, mouse_y, 10)
    end

    love.graphics.print(love.timer.getFPS(), 10, 10)
end