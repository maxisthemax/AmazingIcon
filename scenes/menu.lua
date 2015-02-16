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
local screenGroup
local bgGroup
local _W = display.contentWidth
local _H = display.contentHeight
local mR = math.random 
local mF = math.floor 
local background
local title
local button_rate
local button_play
local button_leader
local button_vol
local button_iap
local copyright
local physics = require ("physics") 
physics.setDrawMode( "normal" ) 
physics.start()
local copyrightText = "© 2015 28miStudio"
local useVolImage = "button_small_vol1"
if masterVolume == 0 then 
    useVolImage = "button_small_vol2"
end


-----------------------------------------------
--*** Other Functions ***
-----------------------------------------------
local function buttonTouched(event)
	local t = event.target
    local id = t.id 

	if event.phase == "began" then 
		display.getCurrentStage():setFocus( t )
		t.isFocus = true
		t.alpha = 0.7

	elseif t.isFocus then 
		if event.phase == "ended"  then 
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
			t.alpha = 1

			--Check bounds. If we are in it then click!
			local b = t.contentBounds
			if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
				playSound("select")

                if id == "play" then
                 physics.addBody( button_play, "dynamic" )
                 button_play:applyLinearImpulse( 0.5 , -0.5 , button_play.x, button_play.y )
    				     button_play.gravityScale =2
                 physics.addBody( button_rate, "dynamic" )
                 button_rate:applyLinearImpulse( -0.5 , -0.5 , button_play.x, button_play.y )
                 button_rate.gravityScale =2
                 physics.addBody( button_leader, "dynamic" )
                 button_leader:applyLinearImpulse( 0.5 , -0.5 , button_play.x, button_play.y )
                 button_leader.gravityScale =2                     				     
    				      local function listener( event )
    composer.gotoScene( "scenes.game", {effect="crossFade", time=500} )
end

timer.performWithDelay( 500, listener )
                 
                 elseif id == "leader" then 
                    scoring.showLeaderboards()

                elseif id == "vol" then 
                    -- Change the volume
                    if masterVolume == 1 then 
                        masterVolume = 0
                        useVolImage = "button_small_vol2"
                    else 
                        masterVolume = 1 
                        useVolImage = "button_small_vol1"
                    end
                    audio.setVolume(masterVolume)

                    -- Save to db
                    local dbPath = system.pathForFile("appInfo.db3", system.DocumentsDirectory)
                    local db = sqlite3.open(dbPath)
                    local update = "UPDATE playerInfo SET volume='" .. masterVolume .."' WHERE id=1"
                    db:exec(update)
                    db:close()

                    -- Change button
                    local x, y = button_vol.x, button_vol.y 
                    display.remove(button_vol)
                    
                    button_vol = display.newImageRect(bgGroup,"images/"..useVolImage..".png",36,36)
                    button_vol.x = x
                    button_vol.y = y
                    button_vol.id = "vol"
                    button_vol:addEventListener("touch", buttonTouched)

                elseif id == "rate" then 
                    local options =
                    {
                                          supportedAndroidStores = { "samsung", "google", "amazon" },
                    }
       
                end
			end
		end
	end
	return true
end


function scene:create( event )
	screenGroup = self.view

	bgGroup = display.newGroup()
	screenGroup:insert(bgGroup)

    -- Create the background
    background = display.newRect(bgGroup,_W*0.5,_H*0.5,_W,_H)
    background:setFillColor(backgroundColour[1],backgroundColour[2],backgroundColour[3])
	
	-- Set up the various sprites + text
	title = display.newImageRect(bgGroup,"images/title.png",180,80)
	title.x = _W*0.5 
	title.y = _H*0.25

    button_play = display.newImageRect(bgGroup,"images/button_play.png",100,92)
    button_play.x = _W*0.5--button_rate.x - 64
    button_play.y = _H*0.5--button_rate.y + 56
    button_play.id = "play"
  
	button_rate = display.newImageRect(bgGroup,"images/button_rate.png",80,72)
    button_rate.x = button_play.x - 60
    button_rate.y = button_play.y + 90
    button_rate.id = "rate"

    button_leader = display.newImageRect(bgGroup,"images/button_leader.png",80,72)
    button_leader.x = button_play.x + 60
    button_leader.y = button_rate.y
    button_leader.id = "leader"



    button_vol = display.newImageRect(bgGroup,"images/"..useVolImage..".png",36,36)
    button_vol.x = button_play.x + 0
    button_vol.y = button_rate.y + 56
    button_vol.id = "vol"

    copyright = display.newText({parent=bgGroup, text=copyrightText, x=_W*0.5, y=_H-70, font=native.systemFont, fontSize=10})
    copyright:setFillColor(textColour[1], textColour[2], textColour[3])
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        composer.removeHidden()

        -- Now give our buttons their touch listeners
        button_rate:addEventListener("touch", buttonTouched)
        button_play:addEventListener("touch", buttonTouched)
        button_leader:addEventListener("touch", buttonTouched)
        button_vol:addEventListener("touch", buttonTouched)

        -- Show ads if we are allowed
        showAdMobbAd()
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- Then add the listeners for the above functions
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene