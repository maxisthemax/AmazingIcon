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
local overRect
local button_play
local button_leader
local button_iap
local button_home
local button_share
local scoreText1
local scoreText2
local rewardImage
local currentScore = 0 
local bestScore = 0 
local rewardTiers = {
    {score=3, image="images/reward1.png", width=64, height=64},
    {score=5, image="images/reward2.png", width=64, height=64},
    {score=10, image="images/reward3.png", width=64, height=64},
}

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

			local b = t.contentBounds
			if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
				playSound("select")
                
                       if id == "play" then 
                    composer.gotoScene( "scenes.game", {effect="crossFade", time=200} )
            
                elseif id == "home" then 
    				composer.gotoScene( "scenes.menu", {effect="crossFade", time=200} )

                elseif id == "leader" then 
                    scoring.showLeaderboards()

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

    if event.params ~= nil then 
        if event.params.currentScore ~= nil then 
            currentScore = event.params.currentScore
        end
        if event.params.bestScore ~= nil then 
            bestScore = event.params.bestScore
        end
    end

    background = display.newRect(bgGroup,_W*0.5,_H*0.5,_W,_H)
    background:setFillColor(backgroundColour[1],backgroundColour[2],backgroundColour[3])

    local gameover = display.newImageRect(bgGroup,"images/gameover.png",162,80)
    gameover.x = _W*0.5
    gameover.y = _H*0.22
    gameover.id = "gameover"

    overRect = display.newImageRect(bgGroup,"images/overRect.png", 230, 150)
    overRect.x = gameover.x
    overRect.y = mF(gameover.y + 10 + overRect.height/2 + 34)

    scoreText1 = display.newText({parent=bgGroup,text=currentScore,font=native.systemFont,fontSize=24,align="left"})
    scoreText1.anchorX = 0
    scoreText1.x = overRect.x - 80
    scoreText1.y = overRect.y - 18
    scoreText1:setFillColor(0)

    scoreText2 = display.newText({parent=bgGroup,text=bestScore,font=native.systemFont,fontSize=24,align="left"})
    scoreText2.anchorX = 0
    scoreText2.x = scoreText1.x 
    scoreText2.y = overRect.y + 39
    scoreText2:setFillColor(0)

    button_play = display.newImageRect(bgGroup,"images/button_play.png",80,72)
    button_play.x = _W*0.5
    button_play.y = _H*0.65
    button_play.id = "play"


    button_leader = display.newImageRect(bgGroup,"images/button_leader.png",60,52)
    button_leader.x = button_play.x + 40
    button_leader.y = button_play.y + 80
    button_leader.id = "leader"

    button_home = display.newImageRect(bgGroup,"images/button_home.png",60,52)
    button_home.x = button_leader.x - 80
    button_home.y = button_leader.y
    button_home.id = "home"
    
    --button_share = display.newImageRect(bgGroup,"images/button_share.png",60,52)
    --button_share.x = button_leader.x + 80
    --button_share.y = button_leader.y
    --button_share.id = "share"
    
    local gotReward = false
    local rewardX = overRect.x + 52
    local rewardY = overRect.y + 10

    for i=#rewardTiers, 1, -1 do 
        if currentScore >= rewardTiers[i].score then 
            gotReward = true 
            rewardImage = display.newImageRect(bgGroup,rewardTiers[i].image,rewardTiers[i].width,rewardTiers[i].height)
            break
        end
    end

    if gotReward == false then 
        rewardImage = display.newText({parent=bgGroup,text=":(",width=120,height=0,font=native.systemFont,fontSize=16,align="center"})
        rewardImage:setFillColor(0)
    end
    rewardImage.x = rewardX
    rewardImage.y = rewardY
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        composer.removeHidden()
        button_play:addEventListener("touch", buttonTouched)
        button_leader:addEventListener("touch", buttonTouched)
       
        button_home:addEventListener("touch", buttonTouched)
       

     
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
     
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