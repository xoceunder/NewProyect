' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "0x662D91"
    m.top.backgroundUri= "pkg:/images/darken.png"
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m
	
    InitScreenStack()
    ShowMenuScreen()
	
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
