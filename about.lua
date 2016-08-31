local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

--images
local toplogo = "logo.png"



local pageTitle
local params

local myList = nil



--
--function to display more information when a row is selected
--
local onRowTouch = function( event )
	if event.phase == "release" then
		local id = event.row.index
		local title = event.target.params.title
		local overlay = event.target.params.overlay
		local options = {
			effect = "slideLeft",
			time = 250,
			isModal = true,
			params = {
				title = title,
			},
		}
		if overlay == "subscribe" then
			system.openURL( "https://goo.gl/forms/fBOTBCwtwgxXPZ0x1" )
		else
			composer.showOverlay( overlay, options )
		end
	end
	return true
end


--
--function to create rows in the tableview
--
local function onRowRender( event )
	--print( "row render" )

	local row = event.row
	local id = row.index
	local title = row.params.title

--[[	row.bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight * 7 / 64 )
	row.bg.anchorX = 0
	row.bg.anchorY = 0
	row.bg:setFillColor( 1, 1, 1 )
	row:insert( row.bg )]]--

	row.bgLine = display.newRect( 0, 0, display.contentWidth, 2 )
	row.bgLine.anchorX = 0
	row.bgLine.anchorY = 0
	row.bgLine:setFillColor( 0.8, 0.8, 0.8 )
	row:insert( row.bgLine )

	if id == 7 then
		row.bgLine2 = display.newRect( 0, display.contentHeight * 7 / 64, display.contentWidth, 2 )
		row.bgLine2.anchorX = 0
		row.bgLine2.anchorY = 0
		row.bgLine2:setFillColor( 0.8, 0.8, 0.8 )
		row:insert( row.bgLine2 )
	end

	row.title = display.newText( title, 0, 0, mccapp.font, 36 )
	row.title.anchorX = 0
	row.title.anchorY = 0
	row.title.x = 20
	row.title.y = row.height / 2 - 36 / 2
	row.title:setFillColor( 0, 0, 0 )
	row:insert( row.title )
end


--
--load actual table view for all events in the feed
--
local function showTableView()
	--print( "Calling showTableview()" )
	local titles = { "About Us", "How to Volunteer", "Donate to MCC!", "Map", "Hours",  "Subscribe to our Email Newsletter", "Contact Us" }
	local overlays = { "background", "howto", "donate", "map", "hours", "subscribe", "contact" }
	for i = 1, table.getn(titles) do
		myList:insertRow{
			rowHeight = display.contentHeight * 7 / 64,
			isCategory = false,
			rowColor = {
				default = { 1, 1, 1 },
				over = { 0.8, 0.8, 0.8 },
			},
			params = {
				title = titles[i],
				overlay = overlays[i],
			},
		}
	end
--[[	myList:insertRow{
		rowHeight = display.contentHeight * 7 / 64,
		isCategory = false,
		rowColor = {
			default = { 1, 1, 1 },
			over = { 0.8, 0.8, 0.8 },
		},
		params = {
			title = "MCC Background",
		},
	}
	myList:insertRow{
		rowHeight = display.contentHeight * 7 / 64,
		isCategory = false,
		rowColor = {
			default = { 1, 1, 1 },
			over = { 0.8, 0.8, 0.8 },
		},
		params = {
			title = "Donate to MCC!",
		},
	}
	myList:insertRow{
		rowHeight = display.contentHeight * 7 / 64,
		isCategory = false,
		rowColor = {
			default = { 1, 1, 1 },
			over = { 0.8, 0.8, 0.8 },
		},
		params = {
			title = "Subscribe to our Email list!",
		},
	}]]--
end


--
--reloads tableView each time scene is called
--
local function purgeList( list )
	list:deleteAllRows()
end


--
--
--
local function tableViewListener( event )
	--print( "tableViewListener", event.phase, event.direction, event.limitReached, myList:getContentPosition() )
	return true
end



--
--actual scene functions
--
function scene:create( event )
	local sceneGroup = self.view

	params = event.params

	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1, 1, 1 )
	sceneGroup:insert( background )

	local navBar = widget.newNavigationBar( {
		--title = "Monument Crisis Center",
		background = toplogo,
		--backgroundColor = { 0.051, 0.255, 1 },
		titleColor = { 1, 1, 1 },
		font = mccapp.font,
		fontSize = display.contentWidth / 12,
		height = mccapp.toplogo.height - display.topStatusBarContentHeight,
	} )
	sceneGroup:insert( navBar )

	local box = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight - navBar.height - 50 )
	box:setFillColor( 1, 1, 1 )
	box.anchorY = 0
	box.y = navBar.height
	sceneGroup:insert( box )

	--create tableView
	myList = widget.newTableView{
		left = 0,
		top = navBar.height,
		width = display.contentWidth,
		height = mccapp.contentHeight,
		--isLocked = true,
		listener = tableViewListener,
		hideBackground = true,
		noLines = true,
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}
	sceneGroup:insert( myList )

end

function scene:show( event )
	local sceneGroup = self.view

	params = event.params

	pageTitle = params.pageTitle

	--show setup options
	if event.phase == "did" then
		print( "show setup" )
		showTableView()
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		--print( "exit scene" )
		purgeList( myList )
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	--print( "destroy scene" )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene