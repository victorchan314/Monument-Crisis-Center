local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

local webView
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

	local story = event.params.story

	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor( 1, 1, 1 )
	sceneGroup:insert( background)

	local title = story.title
	if title and title:len() > mccapp.titleLength then
		title = title:sub( 1, mccapp.titleLength - 3 ) .. "..." 
	end

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
		height = mccapp.toplogo.height - display.topStatusBarContentHeight,
		leftButton = leftButton,
		titleX = titleX,
		titleLeft = titleLeft,
	} )
	sceneGroup:insert( navBar )

end

function scene:show( event )
	local sceneGroup = self.view

	local story = event.params.story

	if event.phase == "did" then
		local title = story.title
		if title then
			if title:len() > mccapp.titleLength then
				title = title:sub( 1, mccapp.titleLength - 3 ) .. "..."
			end
		else
			title = ""
		end
		navBar:setLabel( title )

		--writing out the story body
		local path = system.pathForFile( "story.html", system.TemporaryDirectory )

		--io.open opens a file at the path and returns nil if no file is found
		local fh, errStr = io.open( path, "w" )

		--write out headers to make sure content fits into window, then dump body
		if fh then
			print( "Created file" )
			fh:write( "<!doctype html>\n<html>\n<head>\n<meta charset=\"utf-8\">" )
			fh:write( "<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>\n" )
			fh:write( "<style type=\"text/css\">\n html { -webkit-text-size-adjust: none; font-family: HelveticaNeue-Light, Helvetica, Droid-Sans, Arial, san-serif; font-size: 1.1em; } h1 {font-size:1.25em;} p {font-size:0.9em; } </style>" )
			fh:write( "</head>\n<body>\n" )
			if story.title then
				fh:write( "<h1>" .. story.title .. "</h1>\n" )
			end
			if story.content_encoded then
				fh:write( story.content_encoded )
			elseif story.description then
				fh:write( story.description )
			end
			fh:write( "\n</body>\n</html>\n" )
			io.close( fh )
		else
			print( "Create file failed!" )
		end

		--handler to deal with clicking on any anchor tags in above HTML
		local function webListener( event )
			if event.url then
				print( "showWebPopup callback" )
				local url = event.url
				local i, _ = string.find( url, "http:" ) or string.find( url, "https:" ) or string.find( url, "mail:to" )
				if i ~= nil then
					url = string.sub( url, i )
					print( "url: " .. url )
					system.openURL( url )
				end
			end

			if event.errorCode then
				native.showAlert( "Error!", event.errorMessage, { "OK" } )
			end

			return true
		end

		--turn off activity indicator and show webview
		--native.setActivityIndicator( false )
		webView = native.newWebView( display.contentCenterX, mccapp.navBarHeight, display.contentWidth, mccapp.contentHeight )
		webView.anchorY = 0

		webView:request( "story.html", system.TemporaryDirectory )

		webView:addEventListener( "urlRequest", webListener )
	end

end

function scene:hide( event )
	local sceneGroup = self.view

	--clean up objects, listeners, timers, etc.
	if event.phase == "will" then
		if webView and webView.removeSelf then
			webView:removeSelf()
			webView = nil
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