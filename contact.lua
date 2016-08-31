local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

local backButton
local navBar

local call = "call.png"

local function goBack( event )
	if event.phase == "ended" then
		composer.hideOverlay( "slideRight", 250 )
	end
	return true
end

local function callPhone( event )
	if event.phase == "ended" then
		print( "Calling phone number!" )
		--system.openURL( "tel:925-825-7751" ),
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

		local contactTitle = display.newText{
			text = [[Monument Crisis Center]],
			x = display.contentCenterX,
			y = display.contentHeight / 40,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.fontBold,
			fontSize = 48,
		}
		contactTitle.anchorY = 0
		contactTitle:setFillColor( 0, 0, 0 )
		scrollView:insert( contactTitle )

		local callButton = widget.newButton{
			x = display.contentWidth * 8 / 10,
			y = display.contentHeight / 40 + 80,
			width = 36,
			height = 36,
			onRelease = callPhone,
			defaultFile = call,
			overFile = call,
		}
		callButton.anchorY = 0
		scrollView:insert( callButton )local contact = display.newText{
			text = [[General Line: (925)-825-7751]],
			x = display.contentCenterX,
			y = display.contentHeight / 40 + 80,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.font,
			--fontSize = 10,
		}
		contact.anchorY = 0
		contact:setFillColor( 0, 0, 0 )
		scrollView:insert( contact )

		local contact = display.newText{
			text = [[
For questions regarding volunteering
Tel: (925)-825-7751 ext. 126
Email: volunteer@monumentcrisiscenter.org

Sandra Scherer
Executive Director
sscherer@monumentcrisiscenter.org
ext. 105

Liz Torres
Community Resource and Referral Manager
Education & Health Workshop Coordinator
ltorres@monumentcrisiscenter.org
ext. 110

Danny Scherer
Logistics Manager
Social Media Director
Disaster Preparedness Coordinator
dscherer@monumentcrisiscenter.org
ext. 108

Josemar Hernandez
Pantry Services Supervisor
Summer Day Camp & CSJO Program Coordinator
jhernandez@monumentcrisiscenter.org
ext. 104

Yolanda Gonzalez
Operations Manager
ygonzalez@monumentcrisiscenter.org
ext. 102

Bertha Lopez
After School Cafe Coordinator
afterschoolcafe2350@gmail.com

Sabrina Santos
Community Engagement Coordinator
AmeriCorps VISTA
volunteer@monumentcrisiscenter.org
ext. 126

Contact the board at
board@monumentcrisiscenter.org
]],
			x = display.contentCenterX,
			y = display.contentHeight / 40 + 160,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.font,
			fontSize = 24,
		}
		contact.anchorY = 0
		contact:setFillColor( 0, 0, 0 )
		scrollView:insert( contact )
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