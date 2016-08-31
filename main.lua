--Victor Chan
--Monument Crisis Center Mobile Application
--iPhone screen is 640x1136



--
--load Composer
--
local composer = require( "composer" )
local widget = require( "widget" )
local mccapp = require( "mccapp" )


--scale for display depending on devices
mccapp.scale = display.contentHeight / display.contentWidth

--max length for navigation bar titles
mccapp.titleLength = 21


--
--load pictures, fonts, styles
--
local bglogo = "bglogo.png"
local logo = "logo.png"
local tabBarBackground = "tabbarbg.png"
local tabBarOver = "tabbarover.png"
local tabBarDefault = "tabbardefault.png"
local aboutOver = "aboutbuttonover.png"
local aboutDefault = "aboutbuttondefault.png"

local systemFonts = native.getFontNames()
local searchString = "helvetica"

local font
local fontBold

for i, fontName in ipairs( systemFonts ) do
	local j, k = string.find( string.lower( fontName ), string.lower( searchString ) )
	if j ~= nil then
		font = "Helvetica"
		break
	end
	font = native.systemFont
end

local searchString = "helvetica-bold"

for i, fontName in ipairs( systemFonts ) do
	local j, k = string.find( string.lower( fontName ), string.lower( searchString ) )
	if j ~= nil then
		fontBold = "Helvetica-Bold"
		break
	end
	fontBold = native.systemFontBold
end

mccapp.font = native.newFont( font, 34 )
mccapp.fontBold = native.newFont( fontBold, 34 )

print( mccapp.font, mccapp.fontBold )

if system.getInfo( "platformName" ) == "Android" then
	mccapp.theme = "widget_theme_android"
else
	mccapp.theme = "widget_theme_ios7"
	local coronaBuild = system.getInfo( "build" )
	if tonumber( coronaBuild:sub( 6, 12 ) ) < 1206 then
		mccapp.theme = "widget_theme_ios"
	end
end

widget.setTheme( mccapp.theme )


--code to not print stuff if not debugging
local debugMode = true

reallyPrint = print
function print(...)
	if debugMode then
		reallyPrint(unpack(arg))
	end
end



--
--switching between screens
--
mccapp.tabBar = {}

function mccapp.showScreenClients( event )
	--reallyPrint( "Clients selected!" )
	mccapp.tabBar:setSelected(1)
	local options = {
		feedName = "clientsfeed.xml",
		--feedURL = "http://finance.yahoo.com/rss/industry?s=yhoo",
		--feedURL = "https://coronalabs.com/feed",
		feedURL = "clientsfeed.xml",
		icons = "fixed",
		displayMode = "webpage",
		pageTitle = "Clients"
	}
	composer.removeHidden()
	composer.gotoScene( "clients", { effect = "flip", params = options } )
	return true
end

function mccapp.showScreenDonors()
	--reallyPrint( "Donors selected!" )
	mccapp.tabBar:setSelected(2)
	local options = {
		feedName = "Yahoo Finance",
		feedURL = "http://finance.yahoo.com/rss/industry?s=yhoo",
		icons = "fixed",
		displayMode = "webpage",
		pageTitle = "Donors"
	}
	composer.removeHidden()
	composer.gotoScene( "donors", { effect = "flip", params = options } )
	return true
end

function mccapp.showScreenVolunteers()
	--reallyPrint( "Volunteers selected!" )
	mccapp.tabBar:setSelected(3)
	local options = {
		feedName = "clientsfeed.xml",
		--feedURL = "https://coronalabs.com/feed",
		feedURL = "clientsfeed.xml",
		icons = "fixed",
		displayMode = "webpage",
		pageTitle = "Volunteers"
	}
	composer.removeHidden()
	composer.gotoScene( "volunteers", { effect = "flip", params = options } )
	return true
end

function mccapp.showScreenAbout()
	--reallyPrint( "About selected!" )
	mccapp.tabBar:setSelected(4)
	local options = {
		pageTitle = "About"
	}
	composer.removeHidden()
	composer.gotoScene( "about", { effect = "flip", params = options } )
	return true
end
--[[
function mccapp.refresh()
	reallyPrint( "Refresh!" )
end
]]--


--
--start defining objects on the screen
--
local optionButtons = {
	{
		id = clientsButton,
		label = "Clients",
		size = display.contentHeight / 60,
		defaultFile = tabBarDefault,
		overFile = tabBarOver,
		labelColor = {
			default = { 0.604, 0.714, 1 },
			over = { 0.051, 0.255, 1 },
		},
		width = display.contentWidth / 7,
		height = display.contentWidth / 7,
		onPress = mccapp.showScreenClients,
		selected = true,
	},
	{
		id = donorsButton,
		label = "Donors",
		size = display.contentHeight / 60,
		defaultFile = tabBarDefault,
		overFile = tabBarOver,
		labelColor = {
			default = { 0.604, 0.714, 1 },
			over = { 0.051, 0.255, 1 },
		},
		width = display.contentWidth / 7,
		height = display.contentWidth / 7,
		onPress = mccapp.showScreenDonors,
	},
	{
		id = volunteersButton,
		label = "Volunteers",
		size = display.contentHeight / 60,
		defaultFile = tabBarDefault,
		overFile = tabBarOver,
		labelColor = {
			default = { 0.604, 0.714, 1 },
			over = { 0.051, 0.255, 1 },
		},
		width = display.contentWidth / 7,
		height = display.contentWidth / 7,
		onPress = mccapp.showScreenVolunteers,
	},
	{
		id = aboutButton,
		label = "About",
		size = display.contentHeight / 60,
		defaultFile = aboutDefault,
		overFile = aboutOver,
		labelColor = {
			default = { 0.604, 0.714, 1 },
			over = { 0.051, 0.255, 1 },
		},
		width = display.contentWidth / 7,
		height = display.contentWidth / 7,
		onPress = mccapp.showScreenAbout,
	},
}

local tabBar = display.newGroup()

mccapp.tabBar = widget.newTabBar{
	id = "options",
	left = 0,
	top = display.contentHeight / 8 * 7,
	width = display.contentWidth,
	height = display.contentHeight / 8,
	backgroundFile = tabBarBackground,
	tabSelectedLeftFile = tabBarBackground,
	tabSelectedMiddleFile = tabBarBackground,
	tabSelectedRightFile = tabBarBackground,
	tabSelectedFrameWidth = display.contentWidth / 8,
	tabSelectedFrameHeight = display.contentHeight / 16,
	buttons = optionButtons,
}
tabBar:insert( mccapp.tabBar )
--[[
mccapp.refreshButton = widget.newButton{
	id = "refresh",
	left = display.contentWidth / 4 * 3 + ( display.contentWidth / 4 - display.contentHeight / 8 ) / 2,
	top = display.contentHeight / 8 * 7,
	onPress = mccapp.refresh,
	label = "Refresh",
	fontSize = display.contentHeight / 60,
	labelColor = {
		default = { 0.051, 0.255, 1 },
		over = { 0.051, 0.255, 1 },
	},
	width = display.contentHeight / 8,
	height = display.contentHeight / 8,
	defaultFile = "refresh.png",
	overFile = "refresh.png",
}
tabBar:insert( mccapp.refreshButton )]]--



--
--add stuff to screen, order as necessary
--
--local background = display.newImage( bglogo, display.contentCenterX, display.contentCenterY )
--local bgscalefactor = 1.1 * display.contentHeight / background.height
--background:scale( bgscalefactor, bgscalefactor )
local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
background:setFillColor( 1, 1, 1 )

local toplogo = display.newImage( logo, display.contentCenterX, 0 )
toplogo.anchorY = 0
local tlscalefactor = display.contentWidth / toplogo.width
toplogo.width = tlscalefactor * toplogo.width
toplogo.height = tlscalefactor * toplogo.height
mccapp.toplogo = toplogo

local tabBarTopLine = display.newRect( display.contentCenterX, display.contentHeight / 8 * 7, display.contentWidth, 3 )
tabBarTopLine:setFillColor( 0.604, 0.714, 1 )
tabBar:insert( tabBarTopLine )

local tabBarDivLine1 = display.newRect( display.contentWidth / 4, display.contentHeight / 16 * 15, 2, display.contentHeight / 8 )
tabBarDivLine1:setFillColor( 0.604, 0.714, 1, .75 )
tabBar:insert( tabBarDivLine1 )

local tabBarDivLine2 = display.newRect( display.contentWidth / 4 * 2, display.contentHeight / 16 * 15, 2, display.contentHeight / 8 )
tabBarDivLine2:setFillColor( 0.604, 0.714, 1, .75 )
tabBar:insert( tabBarDivLine2 )

local tabBarDivLine3 = display.newRect( display.contentWidth / 4 * 3, display.contentHeight / 16 * 15, 2, display.contentHeight / 8 )
tabBarDivLine3:setFillColor( 0.604, 0.714, 1, .75 )
tabBar:insert( tabBarDivLine3 )
--[[
local refreshLine = display.newRect( display.contentWidth / 4 * 3, display.contentHeight / 16 * 15, 3, display.contentHeight / 8 )
refreshLine:setFillColor( 0.604, 0.714, 1 )
tabBar:insert( refreshLine )]]--

local stage = display.getCurrentStage()
stage:insert( background )
stage:insert( composer.stage )
stage:insert( tabBar )
--stage:insert( toplogo )

local navBarHeight = toplogo.height
local contentHeight = display.contentHeight - navBarHeight - mccapp.tabBar.height

mccapp.navBarHeight = navBarHeight
mccapp.contentHeight = contentHeight

--actually loads the whole page
local function load()
	mccapp.showScreenClients()
	reallyPrint( "Loaded!" )
end

timer.performWithDelay(0, load)







