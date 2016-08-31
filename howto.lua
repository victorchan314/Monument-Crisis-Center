local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

local backButton
local navBar

local function linkToVolunteer( event )
	system.openURL( "http://monumentcrisiscenter.org/support-us/volunteer/" )
	return true
end

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
Volunteers are central to the success of the Monument Crisis Center, donating over 20,000 hours of service a year. While programs are planned by staff, nearly every service the Center offers is executed with the assistance of individuals and groups who donate their time, skills and expertise.  Participants in the volunteer program come from schools, service clubs, religious affiliations, small businesses, corporations and range in age from 5 to 95.

We offer volunteer opportunities for each of our programs, including: Food Room Distribution, Food Program Intake, Resource and Referral, English language Learners, Employment Workshop, Administrative Assistance, Senior Moments, and a variety of donation drives. For volunteer requirements, our sign-up form, and more details, please visit our website.
]],
			x = display.contentCenterX,
			y = display.contentHeight / 40,
			width = display.contentWidth * 9 / 10,
			height = 0,
			font = mccapp.font,
		}
		summary.anchorY = 0
		summary:setFillColor( 0, 0, 0 )
		scrollView:insert( summary )

		local volunteerButton = widget.newButton{
			x = display.contentCenterX,
			y = summary.height + 20,
			onRelease = linkToVolunteer,
			label = "Sign Up Now!",
			labelColor = { 
				default = { 1, 1, 1 },
				over = { 1, 1, 1 },
			},
			font = mccapp.font,
			fontSize = 50,
			shape = "roundedRect",
			fillColor = {
				default = { 0.051, 0.255, 1 },
				over = { 0.604, 0.714, 1 },
			},
			width = display.contentWidth * 4 / 5,
			height = 150,
			cornerRadius = 25,
		}
		volunteerButton.anchorY = 0
		scrollView:insert( volunteerButton )

		scrollView:setScrollHeight( summary.height + 20 + volunteerButton.height + 20 )
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