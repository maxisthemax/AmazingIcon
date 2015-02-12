-------------------------------------------------------------------------
--Created by Mario Mraz
--28miStudio
--mraz.mario28@gmail.com

--CoronaSDK version 2014 was used for this template.

--You are not allowed to publish this template to the Google Play as it is. 
--You need to work on it, improve it and replace the graphics. 

-------------------------------------------------------------------------
local aspectRatio = display.pixelHeight / display.pixelWidth

application =
{
    content =
    {
            width = aspectRatio > 1.5 and 320 or math.ceil(480 / aspectRatio),
            height = aspectRatio < 1.5 and 480 or math.ceil(320 * aspectRatio),
            scale = "letterbox",
			fps = 60,
			imageSuffix =
			{
				["@2x"] = 1.5,
			},
    },
}
