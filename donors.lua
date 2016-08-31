local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local widgetExtras = require( "widget-extras" )

local socket = require( "socket" )
local rss = require( "rss" )

local mccapp = require( "mccapp" )
widget.setTheme( mccapp.theme )

--images
local toplogo = "logo.png"



--
--rss feed
--
local feedName
local feedURL
local displayMode
local pageTitle
local icons
local params
local springStart
local needToReload
local spinner

local myList = nil
local stories = {}

local function testNetworkConnection()
	local testConnection = socket.connect( "www.google.com", 80 )
	if testConnection == nil then
		return false
	end
	testConnection:close()
	return true
end



--
--function to display more information when a row is selected
--
local onRowTouch = function( event )
	if event.phase == "release" then
		local id = event.row.index
		local story = event.target.params.story
		local params = {
			story = story
		}
		local options = {
			effect = "slideLeft",
			time = 250,
			isModal = true,
			params = params,
		}
		composer.showOverlay( displayMode, options )
	end
	return true
end


--
--function to create rows in the tableview
--
local function onRowRender( event )
	--print( "row render" )

	local row = event.row
	local story = event.row.params.story
	local id = row.index

	if id > #stories then return true end

--[[	row.bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight * 7 / 64 )
	row.bg.anchorX = 0
	row.bg.anchorY = 0
	row.bg:setFillColor( 1, 1, 1 )
	row:insert( row.bg )]]--

--[[	row.bgLine = display.newRect( 0, 0, display.contentWidth, 2 )
	row.bgLine.anchorX = 0
	row.bgLine.anchorY = 0
	row.bgLine:setFillColor( 0.8, 0.8, 0.8 )
	row:insert( row.bgLine )]]--

--[[	--renders row thumbnail
	local function thumbnailListener( event )
		if ( event.isError ) then
			print( "Network error - download failed" )
		else
			print( "got image" )
			event.target.alpha = 0
			local w = event.target.width
			local h = event.target.height
			local s = itemIcon.height / h
			event.target:scale( s, s )
			event.target.anchorX = 0
			event.target.anchorY = 0
			event.target.x = 2
			event.target.y = 4

			row:insert( event.target )
			transition.to( event.target, { time = 100, alpha = 1.0 } )
		end
		print( "RESPONSE: " .. event.response )
	end

	--checks to see if using embedded icons or something fixed
	if icons == "embedded" then
		--checks to see if there are enclosures and that they have entries
		if story.enclosures and #story.enclosures > 0 then
			local found = true
			local j = 0
			while j < #story.enclosures and found do
				j = j + 1
				local e = story.enclosures[j]
				--checks to see if it is a supported image, and if so creates a local filename for it and loads it
				if e.type == "image/jpeg" or e.type == "image/jpg" or e.type == "image/png" then
					local filename = string.format( "image_%d.%s", id, string.sub( e.type, string.find( e.type, "/" ) + 1 ) )
					display.loadRemoteImage( e.url, "GET", thumbnailListener, filename, system.CachesDirectory, 0, 0 )
				end
			end
		end
	--icon for left side of table view]]--
--[[	else
		row.icon = display.newImageRect( mccapp.icons, 12, row.height * 3 / 4, row.height * 3 / 4 )
		row.icon.x = row.height * 2 / 3
		row.icon.y = row.height / 2
		row:insert( row.icon )]]--
	--[[end]]--

	--calculate maximum length of title and creates it
	local titleLength = math.floor( display.contentWidth / 18 ) - 3
	--print( "titleLength ", titleLength )
	--print( "Screen width: ", display.contentWidth )
	local myTitle = story.title
	if string.len( myTitle ) > titleLength then
		myTitle = string.sub( story.title, 1, titleLength) .. "..."
	end
	row.title = display.newText( myTitle, 0, 0, mccapp.font, 36 )
	row.title.anchorX = 0
	row.title.anchorY = 0
	row.title:setFillColor( 0, 0, 0 )
	row.title.x = row.width / 15
	row.title.y = 20
	row:insert( row.title )

	--display publish time
	local timeStamp = string.match( story.pubDate, "%w+, %d+ %w+ %w+ %w+:%w+" )
	row.subtitle = display.newText( timeStamp, 0, 0, mccapp.font, 24 )
	row.subtitle.anchorX = 0
	row.subtitle:setFillColor( 0.4, 0.4, 0.4 )
	row.subtitle.x = row.width / 15
	row.subtitle.y = row.title.y + row.title.height + 15
	row:insert( row.subtitle )
end


--
--load actual table view for all events in the feed
--
local function showTableView()
	--print( "Calling showTableview()" )
	for i = 1, #stories do
		--print( "insert row: " .. i .. " [" .. stories[i].title .. "]" )
		myList:insertRow{
			rowHeight = display.contentHeight * 7 / 64,
			isCategory = false,
			rowColor = {
				default = { 1, 1, 1 },
				over = { 0.8, 0.8, 0.8 },
			},
			lineColor = { 0.102, 0.512, 0 },
			params = {
				story = stories[i]
			},
		}
	end
end


--
--reloads tableView each time scene is called
--
local function purgeList( list )
	list:deleteAllRows()
end


--check for network availability, download and parse RSS feed, load and display tableView; --use cached version if network is unavailable or download fails
function displayFeed( feedName, feedURL )
	--native.setActivityIndicator( true )
	--print( "entering displayFeed", feedName, feedURL )
	--process file and return information, then initialize tableView
	local function processRSSFeed( file, path )
		--native.setActivityIndicator( false )
		print( "Process RSS Feed", file, feedURL )
		local story = {}
		local feed = rss.feed( file, path )
		stories = feed.items
		--print( "Number of stories: " .. #stories )
		purgeList( myList )
		showTableView()
	end

	local function onAlertComplete( event )
		return true
	end

	--process the feed from the table
	local networkListener = function( event )
		processRSSFeed( feedName, system.CachesDirectory )
		return true
	end

	--download XML file, but if no network then check for cached version
	local isReachable = testNetworkConnection()
	if isReachable then
		network.download( feedURL, "GET", networkListener, feedName, system.CachesDirectory )
	else
		local path = system.pathForFile( feedName, system.CachesDirectory )
		local file, errorString = io.open( path, "r" )
		if file then
			print( "Using cached file", path )
			io.close( file )
			processRSSFeed( feedName, system.CachesDirectory )
		else
			local alert = native.showAlert( "Monument Crisis Center", "Feed temporarily unavailable.", { "OK" }, onAlertComplete )
		end
	end
	return true
end


--
--reload the table; cache buster to make sure it is updated
--
local function reloadTable()
	local cacheBustedURL = feedURL
	if string.find( cacheBustedURL, "%?" ) then
		cacheBustedURL = cacheBustedURL .. "&cacheBust=" .. tonumber( os.time() )
	else
		cacheBustedURL = cacheBustedURL .. "?cacheBust=" .. tonumber( os.time() )
	end
	displayFeed( feedName, cacheBustedURL )
end


--
--
--
local function tableViewListener( event )
	--print( "tableViewListener", event.phase, event.direction, event.limitReached, myList:getContentPosition() )
	if event.phase == "began" then
		springStart = event.y
		--print( "springStart", springStart)
		needToReload = false
		spinner.isVisible = true
		spinner:start()
	elseif event.phase == "moved" then
		if event.y > springStart + 100 then
			needToReload = true
		end
	elseif event.phase == nil and event.direction == "down" and event.limitReached == true and needToReload then
		needToReload = false
		reloadTable()
		spinner:stop()
		spinner.isVisible = false
	end
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
		height = mccapp.navBarHeight - display.topStatusBarContentHeight,
	} )
	sceneGroup:insert( navBar )

	--invisible reload button on top of status bar
	local reloadBar = display.newRect( display.contentCenterX, display.topStatusBarContentHeight * .05, display.contentWidth, display.topStatusBarContentHeight )
	reloadBar.isVisible = false
	reloadBar.isHitTestable = true
	reloadBar:addEventListener( "tap", reloadTable )

	local box = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, mccapp.contentHeight )
	box:setFillColor( 0.8, 0.8, 0.8 )
	box.anchorY = 0
	box.y = mccapp.navBarHeight
	sceneGroup:insert( box )

	spinner = widget.newSpinner( {
		width = 60,
		height = 60,
	} )
	spinner.x = display.contentCenterX
	spinner.y = mccapp.navBarHeight + 30
	spinner.isVisible = false
	sceneGroup:insert( spinner )

	--create tableView
	myList = widget.newTableView{
		left = 0,
		top = mccapp.navBarHeight,
		width = display.contentWidth,
		height = mccapp.contentHeight,
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

	feedName = params.feedName
	feedURL = params.feedURL
	displayMode = params.displayMode
	pageTitle = params.pageTitle
	icons = params.icons

	--fetch feed
	if event.phase == "did" then
		print( "show", feedName, feedURL )
		displayFeed( feedName, feedURL )
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