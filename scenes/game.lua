-------------------------------------------------------------------------
--Created by Mario Mraz
--28miStudio
--mraz.mario28@gmail.com

--CoronaSDK version 2014 was used for this template.

--You are not allowed to publish this template to the Google Play as it is. 
--You need to work on it, improve it and replace the graphics. 

-------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local physics = require ("physics")	
physics.setDrawMode( "normal" ) 
physics.start()
physics.setGravity(0,0) 
local screenGroup
local bgGroup
local gameGroup
local uiGroup
local _W = display.contentWidth
local _H = display.contentHeight
local mF = math.floor 
local mR = math.random 
local mAbs = math.abs 
local mSin = math.sin 
local background
local text_score
local player 
local tutorial
local touchAllowed = true 
local isGameOver = false
local tutorialActive = true
local currentScore = 0 
local bestScore = 0 
local worldGravity = 30 
local jump = -0.15		
local sidePower = 0.03	

local sectionGapWidth = 100	
local sectionGapHeight = 320
local sectionGapTracking = 0 
local sectionBlockAmount = 2 
local sectionSpeed = 1.2	
local nextSectionWidth = 0  
local useColour = 1 	
local colorInt = 0 	
local colorMax = 3	
local lineColors = {
	{84/255, 172/255, 210/255},  -- line Color
	{147/255, 101/255, 184/255},
	{97/255, 189/255, 109/255},
}
local backgroundTouched
local updateScore 
local gameOver
local gameTick
local onCollision
local makeSection


-----------------------------------------------
--*** Other Functions ***
-----------------------------------------------
local function shakeScreen()
	local function moveScreen() 
        screenGroup.x = math.random(1, 8)
        screenGroup.y = math.random(1, 8) 
    end
    local function resetScreen()
        screenGroup.x = 0
        screenGroup.y = 0
    end
    for i=1, 15 do timer.performWithDelay(10*(i-1), moveScreen) end
    timer.performWithDelay(150, resetScreen)
end

function gameOver()
	playSound("gameover")
	isGameOver = true
	touchAllowed = false
	shakeScreen()
	local dbPath = system.pathForFile("gameinfo.db3", system.DocumentsDirectory)
	local db = sqlite3.open(dbPath)

	for row in db:nrows("SELECT * FROM playerInfo WHERE id = 1") do
		bestScore = tonumber(row.highscore)
	end
	if currentScore > bestScore then 
		bestScore = currentScore
		scoring.setHighScore(bestScore) 
	end

	local update = "UPDATE playerInfo SET highscore='" .. bestScore .."' WHERE id=1"
	db:exec(update)	
	db:close()
	timer.performWithDelay(1000, function()
		composer.gotoScene( "scenes.gameOver", {effect="crossFade", time=200, params={currentScore=currentScore, bestScore=bestScore}} )
	end, 1)
end

function updateScore()
	currentScore = currentScore + 1
	text_score.text = currentScore
	playSound("score")

	colorInt = colorInt + 1
	if colorInt >= colorMax then 
		colorInt = 0
		useColour = useColour + 1

		if useColour > #lineColors then 
			useColour = 1
		end
	end
end

function makeSection()
		local width_1, width_2 
	if nextSectionWidth ~= 0 then 
		width_1 = nextSectionWidth
	else
		width_1 = mR(20, (_W-40)-sectionGapWidth )
	end
	width_2 = _W - width_1 - sectionGapWidth
	nextSectionWidth = mR(20, (_W-40)-sectionGapWidth )	

	local horizontal_1 = display.newRect(gameGroup,0,0,width_1,24)
	horizontal_1.anchorX = 0 
	horizontal_1.anchorY = 1
	horizontal_1:setFillColor(lineColors[useColour][1], lineColors[useColour][2], lineColors[useColour][3])
	horizontal_1.id = "block"
	physics.addBody(horizontal_1, "static")

	local horizontal_2 = display.newRect(gameGroup,horizontal_1.x + horizontal_1.width + sectionGapWidth,0,width_2,24)
	horizontal_2.anchorX = 0 
	horizontal_2.anchorY = 1
	horizontal_2:setFillColor(lineColors[useColour][1], lineColors[useColour][2], lineColors[useColour][3])
	horizontal_2.id = "block"
	physics.addBody(horizontal_2, "static")

	local horizontal_sensor = display.newRect(gameGroup,horizontal_1.x+horizontal_1.width,horizontal_1.y,sectionGapWidth,12)
	horizontal_sensor.anchorX = 0
	horizontal_sensor.anchorY = 1
	horizontal_sensor.isVisible = false
	horizontal_sensor.isHitTestable = true 
	horizontal_sensor.id = "point"
	physics.addBody(horizontal_sensor, "static", {isSensor=true})
	local xOffset = 5
	local x_1 = mR( width_1-xOffset, width_1+sectionGapWidth+xOffset )
	local x_2 = mR( width_1-xOffset, width_1+sectionGapWidth+xOffset )

	local yOffset = math.round(320/(sectionBlockAmount+1))

	local block_1 = display.newRect(gameGroup, x_1, horizontal_1.y - horizontal_1.height - yOffset, 24, 24)
	block_1:setFillColor(lineColors[useColour][1], lineColors[useColour][2], lineColors[useColour][3])
	block_1.id = "block"
	physics.addBody(block_1, "static")

	local block_2 = display.newRect(gameGroup, x_2, block_1.y - block_1.height/2 - yOffset, 24, 24)
	block_2:setFillColor(lineColors[useColour][1], lineColors[useColour][2], lineColors[useColour][3])
	block_2.id = "block"
	physics.addBody(block_2, "static")
end

function backgroundTouched(event)
	local t = event.target
	if event.phase == "began" and touchAllowed == true then 
		display.getCurrentStage():setFocus( t )
		t.isFocus = true

		if tutorialActive == true then 
			tutorialActive = false 
			physics.setGravity(0,worldGravity)
			display.remove(tutorial)
			tutorial = nil
		end

		local Power = sidePower
		if event.x < _W*0.5 then 
			Power = -sidePower
		end

		player:setLinearVelocity(0,0)
		player:applyLinearImpulse( Power, jump, player.x, player.y )

	elseif t.isFocus then 
		if event.phase == "ended" then 
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
		end
	end
	return true
end

local lastYPos = _H*0.5 
function gameTick(event)
	if isGameOver == false then 
		local w = player.width/2
		if player.x + w  > _W then 
			player.x = _W - w 

		elseif player.x - w  < 0 then 
			player.x = w 
		end

		local h = player.height/2
		if player.y + h > _H then 
			gameOver()
		end
		
		if player.y < _H*0.5 then 
			local dif = math.ceil( (lastYPos - player.y)*sectionSpeed ) 
			player.y = _H*0.5
			lastYPos = player.y 

			for i=gameGroup.numChildren, 1, -1 do
				gameGroup[i]:translate(0,dif)
				if gameGroup[i].y - gameGroup[i].height > _H then 
					display.remove(gameGroup[i])
					gameGroup[i] = nil 
				end
			end

			sectionGapTracking = sectionGapTracking + dif
			if sectionGapTracking >= sectionGapHeight then 
				sectionGapTracking = 0 
				makeSection()
			end
		end
	end
end

function onCollision(event)
	if event.object1 and event.object2 and isGameOver == false then  -- Make sure its only called once.
		if event.object1.id == "block" and event.object2.id == "player" or event.object1.id == "player" and event.object2.id == "block" then 	
			gameOver()
		elseif event.object1.id == "point" and event.object2.id == "player" or event.object1.id == "player" and event.object2.id == "point" then 	
			if event.object1.id == "point" then 
				display.remove(event.object1)
				event.object1 = nil
			else
				display.remove(event.object2)
				event.object2 = nil
			end
			updateScore()
		end
	end
end

function scene:create( event )
	screenGroup = self.view
	bgGroup = display.newGroup()
	gameGroup = display.newGroup()
	uiGroup = display.newGroup()
	screenGroup:insert(bgGroup)
	screenGroup:insert(gameGroup)
	screenGroup:insert(uiGroup)
	background = display.newRect(bgGroup,_W*0.5,_H*0.5,_W,_H)
	background:setFillColor(backgroundColour[1],backgroundColour[2],backgroundColour[3])

	text_score = display.newText({parent=uiGroup,text=currentScore,font=native.systemFont,fontSize=22})
	text_score.anchorX = 1
	text_score.anchorY = 0
	text_score.x = _W-8
	text_score.y = 4
	text_score:setFillColor(textColour[1],textColour[2],textColour[3])

	player = display.newImageRect(uiGroup, "images/player.png", 32, 32)
	player.x = _W*0.5
	player.y = _H*0.7
	player:setFillColor(38 / 255, 38 / 255, 38 / 255) -- brick color 
	player.id = "player"
	player.isFixedRotation = true

	local w = player.width/2
	local h = player.height/2
	local playerShape = { 0,-h, w,0, 0,h, -w,0 }
	physics.addBody(player, "dynamic",{shape=playerShape, bounce=0.5, density=0.019})

	tutorial = display.newImageRect(uiGroup, "images/tutorial.png", 160, 140)
	tutorial.x = player.x 
	tutorial.y = player.y - 12

	makeSection()
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
       elseif ( phase == "did" ) then
        background:addEventListener("touch",backgroundTouched)
        Runtime:addEventListener("enterFrame",gameTick)
    		Runtime:addEventListener("collision",onCollision)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
         physics.stop()
        Runtime:removeEventListener("enterFrame",gameTick)
		Runtime:removeEventListener("onCollision",onCollision)

    elseif ( phase == "did" ) then
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
