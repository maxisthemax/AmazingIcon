-------------------------------------------------------------------------
--Created by Mario Mraz
--28miStudio
--mraz.mario28@gmail.com

--CoronaSDK version 2014 was used for this template.

--You are not allowed to publish this template to the Google Play as it is. 
--You need to work on it, improve it and replace the graphics. 

-------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
display.setDefault("background", 1, 1, 1)

local composer = require("composer")
composer.recycleOnSceneChange = true 

_G.backgroundColour = {1,1,1} 		
_G.textColour = {0,0,0} 					
_G.masterVolume = 1 					
_G.platform = system.getInfo( "platformName" )


_G.leaderboardInfo = {
	android = "CgkIkMCgvqkDEAIQAQ"
}
_G.scoring = require("asset.scoring")


local sqlite3 = require("sqlite3")
local dbPath = system.pathForFile("gameinfo.db3", system.DocumentsDirectory)
local db = sqlite3.open(dbPath)
local playerSetup = [[
    CREATE TABLE playerInfo(id INTEGER PRIMARY KEY autoincrement, highscore, volume, adsRemoved );
    INSERT INTO playerInfo VALUES(NULL, '0', '1', 'false');
]]
db:exec(playerSetup)

for row in db:nrows("SELECT * FROM playerInfo") do 
    end
db:close()

local sounds = {}
sounds["select"] = audio.loadSound("sounds/select.mp3")
sounds["score"] = audio.loadSound("sounds/score.mp3")
sounds["collect"] = audio.loadSound("sounds/point.mp3")
sounds["gameover"] = audio.loadSound("sounds/gameover.mp3")

function playSound(name)
  if sounds[name] ~= nil then 
    audio.play(sounds[name])
  end
end

local AdMob = require("ads")
local interstitialAppID = "ca-app-pub-1646953303228130/4431601400" -- Interstitial
if platform == "Android" then
    adMobId = "ca-app-pub-1646953303228130/2954868202" -- Banner
end

local function adMobListener(event)
  print("ADMOB AD - Event: " .. event.response) 
end
AdMob.init( "admob", adMobId, adMobListener )


function showAdMobbAd()

    AdMob.show( "banner", {x=0, y=10000 })
    AdMob.show( "interstitial", { appId=interstitialAppID } )
  end

composer.gotoScene( "scenes.menu", "fade", 400 )
