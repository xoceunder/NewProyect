' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "0x662D91"
    m.top.backgroundUri= "pkg:/images/darken.png"
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m
	
    InitScreenStack()
    m.MenuScreen = m.top.findNode("CollapsedMenu")
	m.MenuScreen.observeField("itemSelected", "OnMenuSelection")
    m.MenuScreen.visible = true
    m.MenuScreen.setFocus(true)
	
end sub


sub OnMenuSelection()
  Dbg("Menu item:", m.MenuScreen.itemSelected)
  if m.MenuScreen.itemSelected=0
    'ShowSearchScreen()
  else if m.MenuScreen.itemSelected=1
    'ShowHomeScreen()
  else if m.MenuScreen.itemSelected=2
    'ShowPlayScreen()
  else if m.MenuScreen.itemSelected=3
    'ShowRecentScreen()
  else if m.MenuScreen.itemSelected=4
    'ShowSeriesScreen()
    'RunSeriesTask() ' retrieving content
  else if m.MenuScreen.itemSelected=5
    ShowGridScreen()
    RunContentTask() ' retrieving content
  else if m.MenuScreen.itemSelected=6
    'ShowReadyScreen()
    'RunReadyTask() ' retrieving content
  end if
end sub


' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "left" and not m.MenuScreen.hasFocus() then
            m.MenuScreen.callFunc("expandMenu")
            result = true
        else if key = "right" then
            m.MenuScreen.callFunc("collapseMenu")
			m.top.setFocus(true)
            result = true
        ' handle "back" key press
        else if key = "replay" then
		    ?m.top.GetScene()
			m.top.rowList.SetFocus(true)
            result = true
        else if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' close top screen if there are two or more screens in the screen stack
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return result
end function
