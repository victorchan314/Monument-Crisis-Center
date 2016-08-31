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

local function markerListener( event )
	print( "type: ", event.type )
	print( "markerId: ", event.markerId )
	print( "lat: ", event.latitude )
	print( "long: ", event.longitude )
end

local function locationHandler( event )
	map:setRegion( event.latitude, event.longitude, 4 / 69, 4 / 69 * map.height / map.width )
	print( 4 / 69, 4 / 69 * map.height / map.width, map.height, map.width )
	local options = {
		title = "Monument Crisis Center",
		subtitle = "Social Services Organization",
		imageFile = "mapmarker.jpg",
		listener = markerListener,
	}
	local result, errorMessage = map:addMarker( event.latitude, event.longitude, options )
	if result then
		--print( "Monument Crisis Center marker added." )
	else
		print( errorMessage )
	end
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
			verticalScrollDisabled = true,
		}
		sceneGroup:insert( scrollView )

		local address = display.newText{
			text = [[
1990 Market Street
Concord, CA 94520
]],
			x = display.contentCenterX,
			y = display.contentHeight / 40,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.font,
		}
		address.anchorY = 0
		address:setFillColor( 0, 0, 0 )
		scrollView:insert( address )

		mapBox = display.newRect( display.contentCenterX, address.y + address.height, display.contentWidth * 9 / 10, mccapp.contentHeight - ( 2 * address.y + address.height ) )
		mapBox.anchorY = 0
		mapBox:setFillColor( 0.8, 0.8, 0.8 )
		scrollView:insert( mapBox )

		map = native.newMapView( display.contentCenterX, address.y + address.height, display.contentWidth * 9 / 10, mccapp.contentHeight - ( 2 * address.y + address.height ) )
		map.anchorY = 0
		if map then
			map.mapType = "standard"
			map:requestLocation( "1990 Market Street, Concord, CA 94520", locationHandler )
		else
			native.showAlert( "", "Maps are not available on this device.", { "Okay" } )
		end
	end

end

function scene:hide( event )
	local sceneGroup = self.view

	--clean up objects, listeners, timers, etc.
	if event.phase == "will" then
		if map and map.removeSelf then
			map:removeSelf()
			map = nil
		end
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