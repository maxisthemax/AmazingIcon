
-- Please note that setting up iTunes connect / Google play for Leaderboards can be a tricky process.
-- This template does not go into detail on how to set them up but it needs to be done for this to work.
-- Extra reading:
-- http://docs.coronalabs.com/daily/api/library/gameNetwork/index.html


--Localise
local M = {}
local gameNetwork = require "gameNetwork"
local loggedIntoGC = false


--Start off by loggin the user into Gamecenter or GPGC
local function initCallback( event )
    if platform == "Android" then 
      local function loginListener() loggedIntoGC = true end
      if not event.isError then gameNetwork.request( "login", { userInitiated=true, listener=loginListener } ) end
    else
      if event.data then loggedIntoGC = true
      else loggedIntoGC = false end
  end
end

local function onSystemEvent( event ) 
    if event.type == "applicationStart" or event.type == "applicationResume" then
      if platform == "Android" then gameNetwork.init( "google", initCallback ) 
      else gameNetwork.init( "gamecenter", initCallback ) end 
        return true
    end
end
Runtime:addEventListener( "system", onSystemEvent )


--Set a highscore
local function setHighScore( score )  -- int, int 
  -- Called after a request has been sent.
  local function onGameNetworkRequestResult( event )
      if event.type ~= nil and event.type == "setHighScore" then print("Score submitted") end
  end

  -- Update the player's high score, but only if they are logged in
  if loggedIntoGC == true then 
    local leaderboardToUse = leaderboardInfo.iOS
    if platform == "Android" then leaderboardToUse = leaderboardInfo.android end 

    gameNetwork.request( "setHighScore",
    {
        localPlayerScore = { category = leaderboardToUse, value = tonumber(score) },
        listener = onGameNetworkRequestResult,
    })
  else
    print("User is not logged in")
  end
end
M.setHighScore = setHighScore


--Show the leaderboards
local function showLeaderboards()
  if loggedIntoGC == true then 
    local function onGameNetworkPopupDismissed( event ) end
    if platform == "Android" then 
      gameNetwork.show( "leaderboards" )    
    else 
      gameNetwork.show( "leaderboards", { leaderboard = {timeScope="AllTime"}, listener=onGameNetworkPopupDismissed } ) 
    end
  else
    print("User is not logged in")
  end
end
M.showLeaderboards = showLeaderboards 


-- return
return M
