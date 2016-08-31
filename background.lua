local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

local backButton
local navBar

local function goBack( event )
	if event.phase == "ended" then
		composer.hideOverlay( "slideRight", 250 )
	end
	return true
end

function scene:create( event )
	local sceneGroup = self.view

	local title = event.params.title

	if title and title:len() > mccapp.titleLength then
		title = title:sub( 1, mccapp.titleLength - 3 ) .. "..." 
	end

	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor( 1, 1, 1 )
	sceneGroup:insert( background)

	local leftButton = {
		onEvent = goBack,
		width = display.contentWidth / 4,
		height = display.contentWidth / 10,
		defaultFile = "backbuttonwhite.png",
		overFile = "backbuttonwhite.png",
	}

	local titleX
	local titleLeft = nil
	if title and title:len() < mccapp.titleLength - 6 then
		titleX = display.contentCenterX
	else
		titleLeft = 15 + leftButton.width - 20
	end

	navBar = widget.newNavigationBar( {
		title = title,
		backgroundColor = { 0.051, 0.255, 1 },
		titleColor = { 1, 1, 1 },
		font = mccapp.font,
		fontSize = 48,
		height = mccapp.navBarHeight - display.topStatusBarContentHeight,
		leftButton = leftButton,
		titleX = titleX,
		titleLeft = titleLeft,
	} )
	sceneGroup:insert( navBar )

end

function scene:show( event )
	local sceneGroup = self.view

	local title = event.params.title

	if event.phase == "did" then
		local title = title
		if title then
			if title:len() > mccapp.titleLength then
				title = title:sub( 1, mccapp.titleLength - 3 ) .. "..."
			end
		else
			title = ""
		end
		navBar:setLabel( title )

		local scrollView = widget.newScrollView{
			left = 0,
			top = mccapp.navBarHeight,
			width = display.contentWidth,
			height = mccapp.contentHeight,
			horizontalScrollDisabled = true,
		}
		sceneGroup:insert( scrollView )

		local summary = display.newText{
			text = [[
Monument Crisis Center (MCC) is a community service center that serves the community in times of need. Clients can find food, classes, social activities, clothes--just about anything they might need at MCC. We rely on donations from donors and help from our volunteers, who put in thousands of hours of their personal time, to run this service.

We will use this mobile application to include updates on anything, from upcoming classes to activities to news and information in the event of a natural disaster. In the meantime, join our email list by filling out the Google form or donate on our website! Thank you!
]],
			x = display.contentCenterX,
			y = display.contentHeight / 40,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.font,
			--fontSize = 10,
		}
		summary.anchorY = 0
		summary:setFillColor( 0, 0, 0 )
		scrollView:insert( summary )
	end

end

function scene:hide( event )
	local sceneGroup = self.view

	--clean up objects, listeners, timers, etc.
	if event.phase == "will" then
		if background and background.removeSelf then
			background:removeSelf()
			background = nil
		end
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	print( "destroy overlay" )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene